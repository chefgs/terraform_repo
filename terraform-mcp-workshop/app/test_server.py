"""Tests for the poll server. Run: python3 -m unittest app/test_server.py -v

Each test starts the server on a free port with a temporary database.
"""
import json
import socket
import sys
import tempfile
import threading
import unittest
from http.client import HTTPConnection
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import server  # noqa: E402

BANNED = ("error", "invalid inputs", "internal server", "required", "expected string", "traceback", "unexpected")
OPTION_HINT = "Choose one of: very-useful, useful, neutral, not-useful."
JSON_HEADERS = {"Content-Type": "application/json"}


class PollServerTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.db_path = Path(self.tmp.name) / "pulse.db"
        self.start()

    def tearDown(self):
        self.stop()
        self.tmp.cleanup()

    def start(self):
        self.srv = server.make_server(self.db_path, port=0)
        self.port = self.srv.server_address[1]
        self.thread = threading.Thread(target=self.srv.serve_forever, daemon=True)
        self.thread.start()

    def stop(self):
        self.srv.shutdown()
        self.srv.server_close()
        self.thread.join()

    def call(self, method, path, body=None, headers=None):
        conn = HTTPConnection("127.0.0.1", self.port, timeout=5)
        try:
            conn.request(method, path, body=body, headers=headers or {})
            res = conn.getresponse()
            return res.status, dict(res.getheaders()), res.read()
        finally:
            conn.close()

    def post_vote(self, payload):
        return self.call("POST", "/api/votes", json.dumps(payload), JSON_HEADERS)

    def raw(self, request_bytes, cut_off=False):
        with socket.create_connection(("127.0.0.1", self.port), timeout=5) as sock:
            sock.sendall(request_bytes)
            if cut_off:
                sock.shutdown(socket.SHUT_WR)  # the client goes away before sending the whole body
            chunks = []
            while chunk := sock.recv(4096):
                chunks.append(chunk)
        head, _, body = b"".join(chunks).partition(b"\r\n\r\n")
        return int(head.split()[1]), body

    def assert_failure(self, status, body, expected_status, message, errors=None):
        self.assertEqual(status, expected_status)
        data = json.loads(body)
        self.assertEqual(data["message"], message)
        if errors is not None:
            self.assertEqual(data["errors"], errors)
        text = " ".join([data["message"], *data["errors"].values()]).lower()
        for phrase in BANNED:
            self.assertNotIn(phrase, text)

    # happy paths

    def test_listens_on_this_computer_only_by_default(self):
        self.assertEqual(self.srv.server_address[0], "127.0.0.1")

    def test_health(self):
        status, _, body = self.call("GET", "/api/health")
        self.assertEqual(status, 200)
        self.assertEqual(json.loads(body), {"status": "ok", "service": "meeting-session-pulse-app"})

    def test_page_is_served(self):
        status, headers, body = self.call("GET", "/")
        self.assertEqual(status, 200)
        self.assertTrue(headers["Content-Type"].startswith("text/html"))
        self.assertIn(b"Meeting Session Pulse", body)

    def test_poll_starts_at_zero(self):
        _, _, body = self.call("GET", "/api/poll")
        poll = json.loads(body)
        self.assertEqual(poll["question"], "How useful was this session?")
        self.assertEqual(poll["total"], 0)
        self.assertEqual([o["id"] for o in poll["options"]], ["very-useful", "useful", "neutral", "not-useful"])

    def test_vote_is_counted_and_survives_restart(self):
        status, _, body = self.post_vote({"option": "useful"})
        self.assertEqual(status, 201)
        reply = json.loads(body)
        self.assertEqual(reply["message"], "Vote recorded. Thank you.")
        self.assertEqual(reply["poll"]["total"], 1)
        self.post_vote({"option": "useful"})
        self.post_vote({"option": "neutral"})
        self.stop()
        self.start()
        poll = json.loads(self.call("GET", "/api/poll")[2])
        votes = {o["id"]: o["votes"] for o in poll["options"]}
        self.assertEqual(votes, {"very-useful": 0, "useful": 2, "neutral": 1, "not-useful": 0})
        self.assertEqual(poll["total"], 3)

    def test_sql_text_in_option_is_just_rejected(self):
        status, body = self.post_vote({"option": "useful'); DROP TABLE votes;--"})[::2]
        self.assert_failure(status, body, 400, "That option is not on the poll.", {"option": OPTION_HINT})
        self.assertEqual(json.loads(self.call("GET", "/api/poll")[2])["total"], 0)

    # bad input

    def test_missing_option(self):
        status, _, body = self.post_vote({})
        self.assert_failure(status, body, 400, "Choose an option before voting.", {"option": OPTION_HINT})

    def test_empty_option(self):
        status, _, body = self.post_vote({"option": ""})
        self.assert_failure(status, body, 400, "Choose an option before voting.", {"option": OPTION_HINT})

    def test_unknown_option(self):
        status, _, body = self.post_vote({"option": "great"})
        self.assert_failure(status, body, 400, "That option is not on the poll.", {"option": OPTION_HINT})

    def test_option_of_wrong_type(self):
        for value in (5, ["useful"], {"a": 1}, True):
            status, _, body = self.post_vote({"option": value})
            self.assert_failure(status, body, 400, "That option is not on the poll.", {"option": OPTION_HINT})

    def test_malformed_json(self):
        status, _, body = self.call("POST", "/api/votes", "{not json", JSON_HEADERS)
        example = 'Send a JSON object such as {"option": "useful"}.'
        self.assert_failure(status, body, 400, "The vote could not be read as JSON. " + example, {"body": example})

    def test_json_that_is_not_an_object(self):
        status, _, body = self.call("POST", "/api/votes", '["useful"]', JSON_HEADERS)
        example = 'Send a JSON object such as {"option": "useful"}.'
        self.assert_failure(status, body, 400, "The vote must be a JSON object. " + example, {"body": example})

    def test_wrong_content_type(self):
        status, _, body = self.call("POST", "/api/votes", "option=useful", {"Content-Type": "text/plain"})
        self.assert_failure(
            status, body, 415, "Send the vote as JSON with the header Content-Type: application/json."
        )

    def test_missing_content_length(self):
        status, body = self.raw(
            b"POST /api/votes HTTP/1.1\r\nHost: x\r\nContent-Type: application/json\r\n\r\n"
        )
        self.assert_failure(status, body, 411, "Send the vote with a Content-Length header.")

    def test_bad_content_length(self):
        status, body = self.raw(
            b"POST /api/votes HTTP/1.1\r\nHost: x\r\nContent-Type: application/json\r\nContent-Length: abc\r\n\r\n"
        )
        self.assert_failure(status, body, 400, "The Content-Length header must be a whole number of bytes.")

    def test_oversized_body(self):
        status, body = self.raw(
            b"POST /api/votes HTTP/1.1\r\nHost: x\r\nContent-Type: application/json\r\nContent-Length: 5000\r\n\r\n"
        )
        self.assert_failure(
            status, body, 413, "The vote is too large. Send only the option field, under 1024 bytes."
        )

    def test_body_shorter_than_declared(self):
        status, body = self.raw(
            b"POST /api/votes HTTP/1.1\r\nHost: x\r\nContent-Type: application/json\r\n"
            b"Content-Length: 40\r\n\r\n{\"option\"",
            cut_off=True,
        )
        self.assert_failure(status, body, 400, "The vote was cut off before it finished arriving. Send it again.")

    # routing

    def test_unknown_path(self):
        status, _, body = self.call("GET", "/admin")
        self.assert_failure(
            status, body, 404, "That address does not exist. Open / for the poll or /api/poll for the results."
        )

    def test_path_traversal_is_just_unknown(self):
        status, body = self.raw(b"GET /../server.py HTTP/1.1\r\nHost: x\r\n\r\n")
        self.assertEqual(status, 404)
        self.assertNotIn(b"import", body)

    def test_wrong_method(self):
        status, headers, body = self.call("GET", "/api/votes")
        self.assert_failure(status, body, 405, "This address does not accept GET. Use POST for /api/votes.")
        self.assertEqual(headers["Allow"], "POST")
        status, headers, body = self.call("DELETE", "/api/poll")
        self.assert_failure(status, body, 405, "This address does not accept DELETE. Use GET for /api/poll.")

    # failures on our side

    def test_database_failure_is_reported_as_ours(self):
        self.srv.db_path = self.tmp.name  # a directory, so SQLite cannot open it
        ours = "This is a problem on our side, not yours. Try again in a moment, and tell the workshop host if it keeps happening."
        status, _, body = self.post_vote({"option": "useful"})
        self.assert_failure(status, body, 500, "Your vote was not saved. " + ours)
        status, _, body = self.call("GET", "/api/poll")
        self.assert_failure(status, body, 500, "The results could not be loaded. " + ours)
        status, _, body = self.call("GET", "/api/health")
        self.assert_failure(status, body, 503, "The poll database is not reachable. " + ours)


if __name__ == "__main__":
    unittest.main()
