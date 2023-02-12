Pydantic is a Python library for data validation and settings management using Python type annotations.

# Settings Management & Environment variables

## Settings class

The `BaseSettings` object is a base class in `Pydantic` that allows you to define your configuration settings as Python
classes. It makes it easier for you to store and maintain your central 'configuration' instead of spread out
throughout your application. For more information, see
[Pydantic Docs - Settings Management](https://docs.pydantic.dev/usage/settings/#dotenv-env-support).

These classes can be used to validate the data that you receive in your application, such as configuration files,
environment variables (e.g. those specified in the `.env` file), or certain command-line arguments.

Here's an example of how you might use the `BaseSettings` object to define your configuration settings:

```python
from pydantic import BaseSettings

class Settings(BaseSettings):
    app_name: str
    api_key: str
    debug: bool = False
```

In this example, we create a class called `Settings` that inherits from BaseSettings. We then define three configuration
settings: `app_name`, `api_key`, and `debug`. The data types for each setting are defined using Python type
annotations.

You can then use the `Settings` class to validate data and access the configuration settings in your application:

```python
settings = Settings()
```

However, we may want to create a function that returns the instantiated `settings` object and wrap this function in
the `@lru_cache` decorator. The `lru_cache` decorator ensures that the `Settings` object is created only once, at
the first time it's called. This prevents the `.env` file from being created and saved to disk every time that the
`Settings` object is called.

```python
@lru_cache
def get_settings() -> Settings:
    """
    decorator ensures that the Settings object is created only once,
    at the first time it's called. This prevents the .env file from being created and
    saved to disk every time that the Settings object is called.
    """
    logger.info("Loading env vars...")
    return Settings()


settings = get_settings()
```

## Loading env file

!!! note

    dotenv file parsing requires python-dotenv to be installed: `pip install python-dotenv`.

Pydantic supports loading your dotenv (`.env`) file in your `Settings` class, by adding the subclass `Config`:

```python
class Settings(BaseSettings):
    ...

    class Config:
        env_file = '.env'
        env_file_encoding = 'utf-8'
```

!!! info

    If a filename is specified for env_file (i.e., `.env`), Pydantic will only check the current working directory and
    won't check any parent directories for the .env file. This is important to consider, especially when running Python
    files locally: you typically set your `.env` file on the root level of your project. Thus, validation will fail if
    you want to run a Python file directly from the subdirectory where this Python file is located.
