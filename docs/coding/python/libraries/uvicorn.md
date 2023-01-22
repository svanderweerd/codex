Uvicorn is a fast, high-performance web server for ASGI (Asynchronous Server Gateway Interface) applications, built on
top of the UVLoop and httptools libraries. It is designed to handle a large number of concurrent connections efficiently
and performant. Uvicorn is often used to run web applications built using frameworks such as [FastAPI](fastapi.md),
Starlette and more. It can be used to serve both HTTP and WebSocket applications and can be configured using
command-line options, environment variables or configuration files.

# Using uvicorn to run a (local) server

To run a Unicorn server, you can use the following command:

```shell
uvicorn app.main:app  # (1)
--host 0.0.0.0 --port 8000
--use-colors --loop uvloop --http httptools
--reload
```

1. you let uvicorn execute your `app` function that is defined in the `main.py` file which is located in the `app`
   directory.

Options that have been included:

* `--user-colors` - Enable / disable colorized formatting of the log records, in case this is not set it will be
  auto-detected.
* `--loop <str>` - Set the event loop implementation. The uvloop implementation provides greater performance, but is not
  compatible with Windows or PyPy. Options: 'auto', 'asyncio', 'uvloop'. Default: 'auto'. We have set it to uvloop.
* `--http <str>` - Set the HTTP protocol implementation. The httptools implementation provides greater performance, but
  it's not compatible with PyPy. We have set uit to httptools.
* `--reload` - Enable auto-reload. Good for development purposes.

Other options:

* `lifespan` = The "lifespan" option in the uvicorn package in Python is used to configure the lifespan of worker
  processes. This option can be set to "auto" or "on", and it determines how long worker processes will stay alive
  before being terminated and replaced with new worker processes. When set to "auto", worker processes will be
  terminated and replaced after handling a certain number of requests. When set to "on", worker processes will stay
  alive indefinitely. This can be useful for applications that require long-lived connections or need to maintain state
  between requests.
* check out their [docs](https://www.uvicorn.org/settings/) for more.
