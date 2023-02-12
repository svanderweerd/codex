Python has built-in [logging](https://docs.python.org/3/howto/logging.html) capabilities that allow you to set up
extensive logging throughout your application. Usually I enhance the logging with
the [Rich](https://rich.readthedocs.io/en/stable/logging.html) library. This library allows for more extensive
logging capabilities and formatting.

There are 2 approaches that I have used in my apps: factory function vs single object.

* **Factory function:** You define a function that returns a `logger` object every time that function is called
  throughout your other application modules.
* **Single object:** You create a 'global' `logger` object and you import the object throughout your other
  application modules.

Both options are valid and the one you choose depends on your requirements and use case. Using a factory function
allows you to create separate loggers for different modules with different names, which can be useful if you want to
configure logging differently for each module. Using a single logger object and importing it into your modules can
simplify your code and reduce repetition if you want to use a consistent logging configuration across all modules.

# Factory function

This is helpful when:

* You have different modules with different logging requirements.
* You want to configure the logger for each module differently.
* You want to keep the logging information separate for each module.

You could add a `lru_cache` decorator on top of your `get_logger` function, to increase performance. See code sample
below from one of my apps (which uses `Rich` package as well):

```python
# logger.py

import os
import logging
from functools import lru_cache

from rich.console import Console
from rich.logging import RichHandler

_console = Console(color_system="256", width=180, style="blue")  # (1)

@lru_cache  # (2)
def get_logger(module_name):
    logger = logging.getLogger(module_name)
    if not logger.handlers:  # (3)
        handler = RichHandler(rich_tracebacks=True, console=_console, tracebacks_show_locals=True)
        handler.setFormatter(logging.Formatter("[ %(threadName)s:%(funcName)s:%(pathname)s:%(lineno)d ] - " "%(message)s"))
        logger.addHandler(handler)
        logger.setLevel(os.getenv('LOG_LEVEL', 'DEBUG'))
    return logger

logger = get_logger(__name__)  # (4)
```

1. By starting the `console` object with an underscore, the code is indicating that the console object should not be
   used directly by external code, but rather through the get_logger function. This helps to make the code more
   maintainable and reduces the risk of bugs caused by incorrect usage of the console object.
2. The `lru_cache` decorator helps to avoid creating new logger objects and handlers every time the get_logger function
   is called.
3. The `if not logger.handlers` check is used to avoid adding the same handler to a logger multiple times. By checking
   `if not logger.handlers` before adding the handler, the code ensures that the handler is only added to the logger
   once. This reduces the number of log messages recorded and makes the logging more efficient.
4. If you want to have a single logger for the entire application, you can add `logger = get_logger(__name__)` in the
   logging module and then import `logger` from the logging module in other parts of your application. This way, all log
   messages from different parts of the application will be recorded by the same logger, which can simplify the log
   analysis and management.

!!! note "single vs individual loggers"

    In our code example above, we have set 1 logger object for our entire application. On the other hand, if you want to
    have separate loggers for different parts of the application, you can call the `get_logger` function in each
    individual module. This way, you can have separate log files or separate loggers with different logging levels
    for each module, which can be useful for debugging or troubleshooting specific parts of the application.

# Single object

This option is more suited when:

* You have a single logging configuration for all modules.
* You want to keep the logging information centralized.
* You want to avoid repetitive code.

```python
# logger.py
logger = logging.getLogger(__name__)
handler = logging.StreamHandler()
handler.setFormatter(logging.Formatter("%(levelname)s - %(message)s"))
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)

# module1.py
from logger import logger

logger.info("this is a log message from logger_1")


# module2.py
from logger import logger

logger.info("this is a log message from logger_1")
```
