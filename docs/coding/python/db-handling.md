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

## Reuse database connections

Now, you might consider using connection pooling to reuse database connections, instead of creating a new connection
for each session. This can help improve the performance of your application, especially if you have a high volume of
database queries.

To allow reusing database connections, you can use connection pooling. SQLAlchemy's async support provides an async
connection pool by default. To optimize the code, you can keep the connection open for the duration of the request and
reuse it for multiple operations.

To implement this, we can update the `get_session()` function as shown in the code block below.
