---
title: SQLAlchemy
tags: [db]
---

SQLAlchemy is an ORM. See the library's
author [post](https://techspot.zzzeek.org/2012/02/07/patterns-implemented-by-sqlalchemy/) on the design principles
behind it. For instance, it is designed with keeping the Repository pattern in mind.

# Introducing SQLAlchemy

[SQLAlchemy](https://docs.sqlalchemy.org/en/14/) (SA hereafter) is a library that helps you interact with databases
in python. It can be used to perform ad hoc querying on your database (db), but also used as an ORM for larger
applications.

However you use it, the `engine` object is necessary in order to initiate a connection between your code and the
database. You create it once, up front, by passing in the db's connection URI. The engine acts as your central
source of connections to your database. This engine is initiated using `create_engine()`. You pass in the db URI and
other, optional, arguments (e.g., we used `echo=True` during our dev work, as it shows every action on your db).

After creating the engine, you can already start interacting with the database, for instance by executing the
`engine.execute()` method. This method enables you to pass SQL queries to the database and perform ad hoc SQL
querying.

!!! warning "Be careful when interacting with the engine directly"

    When you do decide to interact with the engine directly, make sure to wrap any SQL query in the text() method
    provided by SQLAlchemy. This escapes dangerous characters found in queries that may break your db.

[Hackers & Slackers](https://hackersandslackers.com/python-database-management-sqlalchemy) made a good post on the
basics of SA and interacting with the engine directly and parsing the results. For instance, the post describes how
you can parse results as a `list` of dictionaries using:

```python
from sqlalchemy import create_engine, text  # noqa

# create engine
engine = create_engine(
    "mysql+pymysql://user:password@host:3306/database",
    echo=True,
)

# perform ad hoc query and assign to 'results' object
results = engine.execute(
    text(
        "SELECT job_id, agency, business_title, \
        salary_range_from, salary_range_to \
        FROM nyc_jobs ORDER BY RAND() LIMIT 10;"
    )
)

# contents of results are converting to a list. Each db entry will be a dictionary.
# The list will be assigned to the rows variable.
rows = [dict(row) for row in results.fetchall()]

# the result is printed
print(rows)
```

# SQLAlchemy's ORM module

Interacting directly with the engine might be okay for simple tasks, but when you are building an application is
might be better to start with the ORM from the get-go. By using the ORM, you basically abstract away the SQL stuff.
You interact with the db using `Model` objects, i.e. data classes. In this case, Models represent your db's tables,
the attributes of Models represent the table's columns.

## Declarative mapping

To enable us to create tables and columns from our data classes, we eed to construct a mapping between a class (i.e.,
Model) and the table (and it's columns). This concept is
called [declarative mapping](https://docs.sqlalchemy.org/en/14/orm/mapping_styles.html#orm-declarative-mapping). The
most common pattern is to construct a base class, which will apply the declarative mapping process to all subclasses
that are derived from the baseclass. SA provides the `declarative_base()` function to do just that. Example of using
it:

```python
from sqlalchemy import declarative_base  # noqa

Base = declarative_base()
```

The new base class will be given a metaclass that produces appropriate Table objects and makes the
appropriate `mapper()` calls based on the information provided declaratively in the class and any subclasses of the
class. For more on mapping patterns supported by SA, see
their [docs](https://docs.sqlalchemy.org/en/14/orm/mapping_styles.html).

!!! info "Data Mapper pattern & how SA applies it"

    Data Mapper - The key to this pattern is that object-relational mapping is applied to a user-defined class in a
    transparent way, keeping the details of persistence separate from the public interface of the class. SQLAlchemy's
    classical mapping system, which is the usage of the mapper() function to link a class with table metadata, implemented
    this pattern as fully as possible. In modern SQLAlchemy, we use the Declarative pattern which combines table metadata
    with the class' declaration as a shortcut to using mapper(), but the persistence API remains separate.

## Models

The `User` class example that is shown below, is a `Model` that is used to represent a `users` table in our database.
You can see that we have imported several SQLAlchemy _types_, which we see getting passed into each `Column`. Each type
corresponds to a SQL data type. Thus, our SQL table columns' data types would be `integer`, `varchar(255)`, and `text`,
respectively. Columns can also accept optional parameters to things like keys or column constraints:

* primary_key: Designates a column as the table's "primary key," a highly recommended practice that serves as a
  unique identifier as well as an index for SQL to search on.
* autoincrement: Only relevant to columns that are both the `primary_key` and have the type `Integer`. Each user we
  create will automatically be assigned an `id`, where our first user will have an id of 1, and subsequent users
  would increment accordingly.
* unique: Places a constraint where no two records/rows share the same value for the given column (we don't want two
  users to have the same username).
* nullable: When set to `True`, adds a constraint that the column is mandatory, and no row will be created unless a
  value is provided.
* key: Places a secondary `key` on the given column, typically used in tandem with another constraint such as `index`.
* index: Designates that a column's values are sortable in a non-arbitrary way in the interest of improving query
  performance.
* server_default: A default value to assign if a value is not explicitly passed.

!!! info "Specifying tablename"

    In our example, we set the optional attribute __tablename__ to explictly specify what model's corresponding SQL
    table should be named. When not present, SQL will use the name of the class to create the table.

Next to specifying our attributes and associated columns, and __tablename__, we can also define a `__repr__` method:
it's best practice to set the value of __repr__ on data models (and Python classes in general) for the purpose of
logging or debugging our class instances. The value returned by __repr__ is what we'll see when we print() an instance
of User. If you've ever had to deal with [object Object] in Javascript, you're already familiar with how obnoxious it is
to debug an object's value and receive nothing useful in return. See example below:

```python
"""models.py"""
from sqlalchemy import declarative_base, Column, Integer, Text, String, DateTime  # noqa
from sqlalchemy.sql import func  # noqa

Base = declarative_base()


class User(Base):
    """User account."""

    __tablename__ = "user"

    id = Column(Integer, primary_key=True, autoincrement="auto")
    username = Column(String(255), unique=True, nullable=False)
    password = Column(Text, nullable=False)
    email = Column(String(255), unique=True, nullable=False)

    def __repr__(self):
        return f"<User {self.username}>"
```

Now, when you create an instance of a model (e.g., you create a user), you are effectively creating a new row in the
associated db table. But before you can do that, you first need to make sure that you have a table already. Now, you
can either create that by accessing your database and create a table manually, but that would be quite inefficient.
Luckily SA provides a method on your `declarative_base()` class that creates the tables for you:

```python
# continues from above
Base.metadata.create_all(engine)  # noqa
```

Once that runs, SQLAlchemy handles everything on the database side to create a table matching our model.

## Creating a session

A session is a persistent database connection that makes it easier to communicate with our database. The session
begins in a mostly stateless form; once the session object is called, it requests a connection resource from the
`engine` that it is _bound_ to.

[Sessions](https://docs.sqlalchemy.org/en/14/orm/session_api.html#sqlalchemy.orm.Session) are created by binding them to
an SQLAlchemy engine, which we covered in the previous part. With an engine created, all we need is to use
SQLAlchemy's `sessionmaker` to define a session and bind it to our engine:

```python
"""database.py"""
"""Database engine & session creation."""
from sqlalchemy import create_engine  # noqa
from sqlalchemy.orm import sessionmaker  # noqa

engine = create_engine(
    'mysql+pymysql://user:password@host:3600/database',
    echo=True
)
Session = sessionmaker(bind=engine)
session = Session()
```

### On sessionmaker

Session is a regular Python class which can be directly instantiated. However, to standardize how sessions are
configured and acquired,
the [`sessionmaker`](https://docs.sqlalchemy.org/en/14/orm/session_api.html#sqlalchemy.orm.sessionmaker) class is
normally used to create a top level `Session` configuration which can then be used throughout an application without the
need to repeat the configuration arguments.

## Storing data using Models & Sessions

With a model defined and session created, we have the luxury of adding and modifying data purely in Python. SQLAlchemy
refers to this as _function-based query construction_. To create a record in our `users` db table, we need to create
an instance of our `User` model, and use our `session` to pass our instance to the engine:

```python
from models import User  # noqa
from database import session  # noqa

user = User(
    username="Bob-12",
    password="Please don't set passwords like this",
    email="Bob12@example.com",
)

session.add(user)  # add the user
session.commit()  # commit the change

```

With an instance of `User` created, all it takes to create this user in our database are two calls to our session:
`add()` queues the item for creation, and `commit()` saves the change. We should now see a row in our database's
user table!

Working with session is as easy as four simple methods:

* `session.add()`: We can pass an instance of a data model into add() to quickly create a new record to be added to
  our database.
* `session.delete()`: Like the above, delete() accepts an instance of a data model. If that record exists in our
  database, it will be staged for deletion.
* `session.commit()`: Changes made within a session are not saved until explicitly committed.
* `session.close()`: Unlike SQLAlchemy engines, sessions are connections that remain open until explicitly closed.

# References

Check out the following references that I've used to increase my understanding of SA:

* [Databases in Python made easy with SQLAlchemy](https://hackersandslackers.com/python-database-management-sqlalchemy/)
  is a 4-part introduction to SQLAlchemy. It's from 2019, so some stuff might be outdated. Overall though, the
  tutorial helped me understand the syntax and workings of SA better.
