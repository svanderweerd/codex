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

```python
# logger_1.py
def get_logger(module_name):
    logger = logging.getLogger(module_name)
    handler = logging.StreamHandler()
    handler.setFormatter(logging.Formatter("%(levelname)s - %(message)s"))
    logger.addHandler(handler)
    logger.setLevel(logging.DEBUG)
    return logger

# logger_2.py
def get_logger(module_name):
    logger = logging.getLogger(module_name)
    handler = logging.StreamHandler()
    handler.setFormatter(logging.Formatter("%(levelname)s - %(message)s"))
    logger.addHandler(handler)
    logger.setLevel(logging.ERROR)
    return logger

# main.py
from logger_1 import get_logger

logger = get_logger(__name__)

logger.info("this is a log message from logger1")

# foo.py
from logger_2 import get_logger

logger = get_logger(__name__)

logger.error(msg="this is an error message from logger_2!")
```

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
