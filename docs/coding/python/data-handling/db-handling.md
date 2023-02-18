To interact with databases in Python, I often make use of [SQLAlchemy](sqlalchemy.md), which is an ORM library for
interacting with relational databases such as postgres.

# Setting up connection

If you are using SQLAlchemy as an ORM, and want to set up an asynchronous interface to your database, consider the
following setup:

```python
from collections.abc import AsyncGenerator
from http.client import HTTPException

from fastapi.encoders import jsonable_encoder
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker

from app.core.config import settings
from app.core.logger import logger

engine = create_async_engine(settings.postgres_url, future=True, echo=settings.debug, json_serializer=jsonable_encoder)
async_session_factory = sessionmaker(engine, autoflush=False, expire_on_commit=False, class_=AsyncSession)


async def get_session() -> AsyncGenerator[AsyncSession, None]:  # (1)
    """
    Initiates a db session.

    :return: an asynchronous session to interact with your db
    """
    async with async_session_factory() as session:  # (2)
        try:  # (3)
            logger.debug(f"ASYNC Pool: {engine.pool.status()}")
            yield session
        except SQLAlchemyError as sql_e:  # (4)
            await session.rollback()
            raise sql_e
        except HTTPException as http_e:
            await session.rollback()
            raise http_e
        else:  # (5)
            await session.commit()
        finally:  # (6)
            await session.close()

```

1. The `get_session` function is an asynchronous function that returns an asynchronous generator of type `AsyncSession`.
2. It initiates a database session using the `async_session_factory` as a context manager.
3. In the `try` block, it logs the status of the database connection pool using the `logger.debug` method. The generator
   yields the session, allowing you to interact with the database.
4. In the `except` blocks, it rolls back the session in case of either a `SQLAlchemyError` or an `HTTPException`.
5. In the `else` block, it commits the session if no exceptions have been raised.
6. Finally, in the `finally` block, it closes the session.

# Synchronous vs Asynchronous db connections

In SQLAlchemy ORM, a `session` is a way of accessing the database and running database operations (such as querying,
updating, or deleting data). A session acts as a bridge between your application and the database.

A synchronous session is a session that blocks your application's main thread while it's waiting for a database
operation to complete. This means that while your application is waiting for the database operation to complete, it
cannot perform any other operations or respond to any user requests. This can cause your application to become
unresponsive or slow.

An asynchronous session, on the other hand, does not block the main thread of your application. Instead, it runs the
database operation in a separate thread, allowing your application to continue processing other tasks while the database
operation is being performed. This can make your application more responsive and faster, especially when running slow
database operations.

When choosing between a synchronous session and an asynchronous session, you should consider the specific needs of your
application. If you have an application that requires fast response times and does not perform many database operations,
a synchronous session may be sufficient. However, if your application performs many database operations or if some of
those operations are slow, an asynchronous session may be a better choice. This is because an asynchronous session can
continue processing other tasks while a database operation is being performed, which can result in a more responsive and
faster application.
