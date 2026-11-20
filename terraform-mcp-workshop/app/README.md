# Meeting Session Pulse (poll app)

A one-question poll. People pick an answer, vote, and see the live counts. One Python process serves the page and a small JSON API, and votes are stored in a SQLite file.

The question is "How useful was this session?" with four fixed answers: Very useful, Useful, Neutral, Not useful.

This app is separate from the static web lab in `infra/` and `site/`. It is also the example application for [terraform-mcp-flow.md](terraform-mcp-flow.md), which explains how to go from an application to an architecture to Terraform using MCP.

## Requirements

- Python 3.8 or newer. It was tested on Python 3.15.2 only. Older versions were not tested.
- A terminal and a web browser.

Nothing else. There is nothing to install: no `pip install`, no virtual environment, no database server. SQLite ships inside Python.

Tested on macOS. Linux should behave the same. On Windows, use `python` where this page says `python3`; that was not tested.

## Install

There is no install step. Get the folder (clone the repository or copy the workshop folder), then check Python is available:

```bash
python3 --version
```

## Run

From the workshop folder (the one that contains `CLAUDE.md`):

```bash
python3 app/server.py
```

You should see:

```text
Meeting Session Pulse: http://127.0.0.1:8000  (database: .../app/data/pulse.db)  Ctrl+C to stop
```

Open http://127.0.0.1:8000 in your browser, choose an answer and press **Vote**. The results update straight away.

Stop it with `Ctrl+C`. The server keeps running in that terminal until you do, so use a second terminal for anything else.

You can also run it from inside the `app/` folder with `python3 server.py`. The result is the same.

### Settings

All three are optional environment variables.

| Variable | Default | Meaning |
|---|---|---|
| `PULSE_HOST` | `127.0.0.1` | Address to listen on. Leave it alone unless you run the server in a container (see below). |
| `PULSE_PORT` | `8000` | Port to listen on. The default avoids port 8080, which the static lab uses. |
| `PULSE_DB` | `app/data/pulse.db` | Path of the SQLite file. The folder is created if it does not exist. |

Example:

```bash
PULSE_PORT=8001 PULSE_DB=/tmp/my-poll.db python3 app/server.py
```

By default the server listens on `127.0.0.1`, so only your own computer can reach it. `PULSE_HOST` exists for one reason: inside a container the server must listen on `0.0.0.0` for a published port to reach it (see `infra/main.tf.reference`, where the published port is itself limited to `127.0.0.1`). On a normal computer, do not set `PULSE_HOST=0.0.0.0`: it opens the poll to everyone on your network, and the poll has no sign-in.

## How the page is wired to the server

The page (`static/index.html`) is plain HTML with a script. It has no build step and no framework. `server.py` serves the page and answers the page's two API calls, using the same address, so the page calls relative paths such as `/api/poll` and there is nothing to configure. Opening `index.html` directly from disk does not work, because there would be no server behind those paths.

```text
Browser (index.html)                server.py                       SQLite file
  GET /                  ------->   Handler._page: sends static/index.html
  page script runs load()
  GET /api/poll          ------->   Handler._poll -> read_poll()  -> SELECT option, COUNT(*) FROM votes GROUP BY option
                         <-------   200 JSON: question, options, total
  render(poll) draws the answers and the result bars
  you pick an answer and press Vote (submit handler)
  POST /api/votes        ------->   Handler._vote: _read_json() checks the body,
   {"option": "useful"}             then                           -> INSERT INTO votes (option) VALUES (?)
                         <-------   201 JSON: message, poll       (or 4xx / 5xx JSON: message, errors)
  render(poll) updates the counts, or the message is shown in the page
```

Where each part of the page connects to the code:

| In the page (`static/index.html`) | Does | Connects to (`server.py`) |
|---|---|---|
| `load()` | Calls `GET /api/poll` on page load | `Handler._poll`, then `read_poll()` |
| `#vote-form` submit handler | Calls `POST /api/votes` with `{"option": "<id>"}` | `Handler._vote` and `_read_json()`, then the `INSERT` |
| `render(poll)` | Fills `#question`, `#choices` (the answers) and `#results` (the bars) from the poll JSON | Reads the JSON that `read_poll()` builds |
| `call(path, options)` | The only `fetch()` in the page. Returns the data, or a message if the server is unreachable, the reply is not JSON, or the server sent an error | The error JSON built from `ApiError` |
| `say(text, bad)` | Shows the success or failure text in `#message` | The `message` and `errors` fields of the reply |

The data passed between them is JSON:

```json
GET /api/poll -> {"question": "How useful was this session?",
                  "options": [{"id": "useful", "label": "Useful", "votes": 1}, ...],
                  "total": 1}

POST /api/votes with {"option": "useful"} -> {"message": "Vote recorded. Thank you.", "poll": { same shape as above }}
```

The answers on the page are not hard-coded in the HTML. They come from `OPTIONS` in `server.py` through `/api/poll`, so changing the question or the answers means editing `server.py` only. The page keeps what you selected, and after each vote it redraws the counts from the server's reply.

## Try the API

With the server running, in a second terminal:

```bash
curl http://127.0.0.1:8000/api/health
curl http://127.0.0.1:8000/api/poll
curl -X POST -H 'Content-Type: application/json' -d '{"option":"useful"}' http://127.0.0.1:8000/api/votes
```

| Method and path | What it does | Success |
|---|---|---|
| `GET /` | The poll page | 200 |
| `GET /api/health` | Checks the server and the database | 200, `{"status": "ok", ...}` |
| `GET /api/poll` | The question, each answer and its vote count, and the total | 200 |
| `POST /api/votes` | Records one vote. Body: `{"option": "<id>"}` | 201 |

The valid option ids are `very-useful`, `useful`, `neutral` and `not-useful`.

Failures return JSON in one shape, with a message you can act on and, for bad input, the field it concerns:

```json
{"message": "That option is not on the poll.", "errors": {"option": "Choose one of: very-useful, useful, neutral, not-useful."}}
```

A vote body must be JSON with the header `Content-Type: application/json`, and at most 1024 bytes.

## Data

- Votes live in one SQLite file, by default `app/data/pulse.db`. It is created on first start and is ignored by git.
- Votes survive restarts.
- **Reset the poll:** stop the server, delete the file, start again.

  ```bash
  rm app/data/pulse.db
  ```

- **Back up the poll:** stop the server and copy the file.

## Run the tests

From the workshop folder:

```bash
python3 -m unittest app/test_server.py -v
```

The 21 tests start the server on a free port with a temporary database, so they never touch your real poll data and do not need the server to be running.

## Troubleshooting

| What you see | Cause and fix |
|---|---|
| `Could not listen on http://127.0.0.1:8000 (Address already in use)...` | Something else uses the port, possibly an earlier copy of this server. Stop it, or run with `PULSE_PORT=8001`. |
| `PULSE_PORT must be a whole number such as 8000.` | The `PULSE_PORT` value is not a number. |
| `Could not open the database at ... Set PULSE_DB to a writable path.` | The database folder or file cannot be created or written. Point `PULSE_DB` at a writable path. |
| The page says "Could not reach the poll server..." | The server is not running or was stopped. Start it again and reload the page. |
| The page says "This is on our side, not yours..." | The server hit a problem, such as the database file being unreadable. Read the terminal where the server runs, which prints the details. |
| `python3: command not found` | Python is not installed or not on your path. Install Python 3 from https://www.python.org/downloads/. |

## Limits

- No sign-in, and no check on who votes or how often. One person can vote many times. Do not expose it to the internet as it is.
- One process, one SQLite file, one fixed question. It is a workshop example, not a production poll.
- Several copies on one machine can share one database file. We ran two against one file, 40 votes each at the same time, and all 80 votes were counted. Putting the file on a network share or on separate volumes is not safe.

## Files

| File | Purpose |
|---|---|
| `server.py` | The server: page, API and SQLite storage |
| `static/index.html` | The poll page |
| `test_server.py` | The 21 tests |
| `infra/main.tf.reference` | Reference Terraform for running the poll in a local Docker container, as a dry-run plan only. It is ignored by Terraform until you rename it, so it never runs by accident. See `terraform-mcp-flow.md`, step 5. |
| `infra/.terraform.lock.hcl` | The provider lock file, kept on purpose so everyone gets the same provider build |
| `terraform-mcp-flow.md` | Application first, then Terraform with MCP: brief, architecture, IaC approach |
| `.gitignore` | Keeps the database file and Python cache out of git |
