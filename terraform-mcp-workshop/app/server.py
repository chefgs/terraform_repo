#!/usr/bin/env python3
"""Meeting Session Pulse: a one-question poll served from one process.

Standard library only. Votes are stored in a SQLite file.

The page (static/index.html) is served by GET / and calls GET /api/poll and
POST /api/votes on this same server. See "How the page is wired to the server"
in README.md.

    python3 app/server.py

Settings (environment variables, all optional):
    PULSE_HOST  address to listen on, default 127.0.0.1 (this computer only)
    PULSE_PORT  port to listen on, default 8000
    PULSE_DB    path of the SQLite file, default app/data/pulse.db

Only set PULSE_HOST to 0.0.0.0 inside a container whose published port is
limited to 127.0.0.1. On a normal computer it would open the poll to the network.
"""
import json
import os
import sqlite3
import sys
import traceback
from contextlib import contextmanager
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

HOST = "127.0.0.1"
DEFAULT_PORT = 8000
HERE = Path(__file__).resolve().parent
INDEX_FILE = HERE / "static" / "index.html"
DEFAULT_DB = HERE / "data" / "pulse.db"
MAX_BODY_BYTES = 1024

QUESTION = "How useful was this session?"
OPTIONS = {
    "very-useful": "Very useful",
    "useful": "Useful",
    "neutral": "Neutral",
    "not-useful": "Not useful",
}
CHOICES = ", ".join(OPTIONS)
ROUTES = {"/": "GET", "/api/health": "GET", "/api/poll": "GET", "/api/votes": "POST"}
OUR_SIDE = (
    "This is a problem on our side, not yours. Try again in a moment, "
    "and tell the workshop host if it keeps happening."
)
SCHEMA = """
CREATE TABLE IF NOT EXISTS votes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    option TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
)
"""


class ApiError(Exception):
    """A failure with a message the person using the page can act on."""

    def __init__(self, status, message, errors=None, headers=None):
        super().__init__(message)
        self.status = status
        self.body = {"message": message, "errors": errors or {}}
        self.headers = headers or {}


@contextmanager
def db(db_path):
    """One connection per request. Commits on success, always closes."""
    conn = sqlite3.connect(db_path, timeout=5)
    try:
        with conn:
            yield conn
    finally:
        conn.close()


def init_db(db_path):
    Path(db_path).parent.mkdir(parents=True, exist_ok=True)
    with db(db_path) as conn:
        conn.execute(SCHEMA)


def read_poll(db_path):
    try:
        with db(db_path) as conn:
            counts = dict(conn.execute("SELECT option, COUNT(*) FROM votes GROUP BY option"))
    except sqlite3.Error:
        traceback.print_exc()
        raise ApiError(500, "The results could not be loaded. " + OUR_SIDE)
    options = [{"id": key, "label": label, "votes": counts.get(key, 0)} for key, label in OPTIONS.items()]
    return {"question": QUESTION, "options": options, "total": sum(o["votes"] for o in options)}


class Handler(BaseHTTPRequestHandler):
    server_version = "MeetingSessionPulse"
    timeout = 10  # a stalled client cannot hold a thread forever

    def do_GET(self):
        self._dispatch()

    do_POST = do_PUT = do_PATCH = do_DELETE = do_HEAD = do_OPTIONS = do_GET

    def _dispatch(self):
        try:
            path = self.path.split("?", 1)[0]
            allowed = ROUTES.get(path)
            if allowed is None:
                raise ApiError(404, "That address does not exist. Open / for the poll or /api/poll for the results.")
            if self.command != allowed:
                raise ApiError(
                    405,
                    f"This address does not accept {self.command}. Use {allowed} for {path}.",
                    headers={"Allow": allowed},
                )
            {"/": self._page, "/api/health": self._health, "/api/poll": self._poll, "/api/votes": self._vote}[path]()
        except ApiError as err:
            self._send_json(err.status, err.body, err.headers)
        except Exception:
            traceback.print_exc()
            self._send_json(500, {"message": "The request failed. " + OUR_SIDE, "errors": {}})

    def _page(self):
        try:
            body = INDEX_FILE.read_bytes()
        except OSError:
            traceback.print_exc()
            raise ApiError(500, "The poll page is missing on the server. " + OUR_SIDE)
        self._send(200, body, "text/html; charset=utf-8")

    def _health(self):
        try:
            with db(self.server.db_path) as conn:
                conn.execute("SELECT 1")
        except sqlite3.Error:
            traceback.print_exc()
            raise ApiError(503, "The poll database is not reachable. " + OUR_SIDE)
        self._send_json(200, {"status": "ok", "service": "meeting-session-pulse-app"})

    def _poll(self):
        self._send_json(200, read_poll(self.server.db_path))

    def _vote(self):
        data = self._read_json()
        option = data.get("option")
        if option is None or option == "":
            raise ApiError(400, "Choose an option before voting.", {"option": f"Choose one of: {CHOICES}."})
        if not isinstance(option, str) or option not in OPTIONS:
            raise ApiError(400, "That option is not on the poll.", {"option": f"Choose one of: {CHOICES}."})
        try:
            with db(self.server.db_path) as conn:
                conn.execute("INSERT INTO votes (option) VALUES (?)", (option,))
        except sqlite3.Error:
            traceback.print_exc()
            raise ApiError(500, "Your vote was not saved. " + OUR_SIDE)
        try:
            poll = read_poll(self.server.db_path)
        except ApiError:
            poll = None  # the vote is saved, so do not report a failure; the page reloads the results
        self._send_json(201, {"message": "Vote recorded. Thank you.", "poll": poll})

    def _read_json(self):
        example = 'Send a JSON object such as {"option": "useful"}.'
        content_type = self.headers.get("Content-Type", "").split(";")[0].strip().lower()
        if content_type != "application/json":
            raise ApiError(415, "Send the vote as JSON with the header Content-Type: application/json.")
        length_header = self.headers.get("Content-Length")
        if length_header is None:
            raise ApiError(411, "Send the vote with a Content-Length header.")
        try:
            length = int(length_header)
        except ValueError:
            length = -1
        if length < 0:
            raise ApiError(400, "The Content-Length header must be a whole number of bytes.")
        if length > MAX_BODY_BYTES:
            raise ApiError(413, f"The vote is too large. Send only the option field, under {MAX_BODY_BYTES} bytes.")
        try:
            raw = self.rfile.read(length)
        except OSError:
            raw = b""
        if len(raw) < length:
            raise ApiError(400, "The vote was cut off before it finished arriving. Send it again.")
        try:
            data = json.loads(raw)
        except ValueError:
            raise ApiError(400, "The vote could not be read as JSON. " + example, {"body": example})
        if not isinstance(data, dict):
            raise ApiError(400, "The vote must be a JSON object. " + example, {"body": example})
        return data

    def _send_json(self, status, payload, headers=None):
        self._send(status, json.dumps(payload).encode(), "application/json", headers)

    def _send(self, status, body, content_type, headers=None):
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Content-Type-Options", "nosniff")
        for name, value in (headers or {}).items():
            self.send_header(name, value)
        self.end_headers()
        self.wfile.write(body)


def make_server(db_path, port=DEFAULT_PORT, host=HOST):
    init_db(db_path)
    server = ThreadingHTTPServer((host, port), Handler)
    server.db_path = str(db_path)
    return server


def main():
    db_path = os.environ.get("PULSE_DB", str(DEFAULT_DB))
    host = os.environ.get("PULSE_HOST", HOST)
    try:
        port = int(os.environ.get("PULSE_PORT", DEFAULT_PORT))
    except ValueError:
        sys.exit("PULSE_PORT must be a whole number such as 8000.")
    try:
        init_db(db_path)
    except (OSError, sqlite3.Error) as err:
        sys.exit(f"Could not open the database at {db_path} ({err}). Set PULSE_DB to a writable path.")
    try:
        server = make_server(db_path, port, host)
    except OSError as err:
        sys.exit(
            f"Could not listen on http://{host}:{port} ({err.strerror}). "
            "Stop whatever else uses that port or set PULSE_PORT to a free one, for example PULSE_PORT=8001. "
            "If PULSE_HOST is set, check that it is an address of this computer."
        )
    print(f"Meeting Session Pulse: http://{host}:{port}  (database: {db_path})  Ctrl+C to stop", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopped.")
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
