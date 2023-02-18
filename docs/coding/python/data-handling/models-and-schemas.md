Schemas and Models used in the context of data handling and interacting with your database:

* Schemas: classes that define the structure of the data you want to work with. You basically declare the shape of
  resources (i.e., data) as classes that have attributes (and each attribute has a type).
* Models: correspond to tables in a database. These models define the structure of the data, including the columns and
  data types of each column.*

Using this setup is based on the [repository pattern](repository-pattern.md).

!!! note

    Both Pydantic and SQLAlchemy work with `Models`. To differentiate between them, I'll refer to my Pydantic Models
    as **schemas** and my sqlalchemy models as **models**.

To recap, I use the following approach: `Schemas` (Pydantic Models) are used for validating data, while `Models`
(SQLAlchemy Models) are used for working with databases. Schemas define the structure of the data you want to work
with, while Models define the structure of the data stored in the database.

# Models (SQLAlchemy)

As mentioned earlier, with [SQLAlchemy](sqlalchemy.md), you can declare models that correspond to tables in a database.
These models define the structure of the data (and thus the tables in your db), including the columns and data types of
each column. SQLAlchemy also provides a high-level API for querying data, inserting data, and updating data in the
database.

## Base Classes

You can declare `Base` classes that form the basis of your interactions with the database. The classes that are
declared in the code block below, do the following:

* `BaseReadOnly` is a read-only base class that has an `id` attribute and a `__tablename__` attribute generated
  automatically based on the name of the class. The purpose of this class is to provide a basic structure for
  read-only models in a database, allowing for easy creation and management of these models by automatically generating
  table names and providing an id field.
* `Base` is a read-write base class that has the same attributes as `BaseReadOnly`, and also has three methods: `save`,
  `delete`, and `update`.
    * `save`: add the current instance of the model to the database session and commit the changes.
    * `delete`: delete the current instance of the model from the database and commit the changes.
    * `update`: update the attributes of the current instance of the model with the given keyword arguments, and then
      call the save method to commit the changes to the database.

```python
from typing import Any

from fastapi import HTTPException, status
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import as_declarative, declared_attr


@as_declarative()
class BaseReadOnly:
    id: Any
    __name__: str

    # Generate __tablename__ automatically
    @declared_attr
    def __tablename__(self) -> str:
        return self.__name__.lower()


@as_declarative()
class Base:
    id: Any
    __name__: str

    # Generate __tablename__automatically
    @declared_attr
    def __tablename__(self) -> str:
        return self.__name__.lower()

    async def save(self, db_session: AsyncSession):
        """

        :param db_session:
        :return:
        """
        try:
            db_session.add(self)
            return await db_session.commit()
        except SQLAlchemyError as e:
            raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=repr(e))

    async def delete(self, db_session: AsyncSession):
        """

        :param db_session:
        :return:
        """
        try:
            await db_session.delete(self)
            await db_session.commit()
            return True
        except SQLAlchemyError as e:
            raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=repr(e))

    async def update(self, db_session: AsyncSession, **kwargs):
        """

        :param db_session:
        :param kwargs:
        :return:
        """
        for k, v in kwargs.items():
            setattr(self, k, v)
        await self.save(db_session)

```

# Schemas
