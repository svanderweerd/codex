[SQLAlchemy](https://docs.sqlalchemy.org/en/14/) is an ORM built with Domain Driven Design in
mind [post](https://techspot.zzzeek.org/2012/02/07/patterns-implemented-by-sqlalchemy/). It can be used to perform ad
hoc querying on your database (db), but also used as an ORM for larger applications. SA has 2 components: **Core**
and **ORM**.

# Core concepts

## Declarative mapping

We want to define tables and columns from our Python classes using the ORM. In SQLAlchemy, this is enabled through
a [declarative mapping](https://docs.sqlalchemy.org/en/14/orm/mapping_styles.html#orm-declarative-mapping). The most
common pattern is constructing a base class using the SQLALchemy `declarative_base` function, and then having all DB
model classes inherit from this base class.

To enable us to create tables and columns from our data classes, we need to construct a mapping between a class (i.e.,
Model) and the table (and it's columns). Below features a declarative base which is then used in a declarative table
mapping:

```python
from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import declarative_base

# declarative base class
Base = declarative_base()
```

Above, we instantiate a base class with the return object provided by the `declarative_base` callable. We can then
use this Base class when constructing our Models (i.e., tables):

```python
# an example mapping using the base class
class User(Base):
    __tablename__ = "user"

    id = Column(Integer, primary_key=True)
    name = Column(String)
    fullname = Column(String)
    nickname = Column(String)
```

You can use a decorator as well (also provided by SA). This enables you to declare helper methods on the `Base`
class, like automatically creating a `__tablename__`. Using a decorator will look like the following:

```python
from sqlalchemy.orm import as_declarative

@as_declarative()
class Base(object):
    @declared_attr
    def __tablename__(cls):
        return cls.__name__.lower()
    id = Column(Integer, primary_key=True)
```

The decorator form of mapping is particularly useful when combining a SQLAlchemy declarative mapping with other
forms of class declaration, notably the Python `dataclasses` module or Pydantic.

## The engine

The start of any SQLAlchemy application is an object called
the [`Engine`](https://docs.sqlalchemy.org/en/14/core/future.html#sqlalchemy.future.Engine). This object acts as a
central source of connections to a particular database, providing both a factory and a holding space called
a [connection pool](https://docs.sqlalchemy.org/en/14/core/pooling.html) for these database connections. The engine
is typically a global object created just once for a particular database server.

The `Engine` is created by using `create_engine()` (see the
SA [docs](https://docs.sqlalchemy.org/en/14/core/engines.html#sqlalchemy.create_engine) as well); we also set the
flag `future` to `True`, since we want to make use of SA's new API version:

```python
from sqlalchemy import create_engine

engine = create_engine("sqlite+pysqlite:///:memory:", echo=True, future=True)
```

The main argument to `create_engine()` is our DB connection URI, which tells the engine what kind of db we have and
where the db is located.

## Session

Interacting directly with the engine might be okay for simple tasks, but when you are building a bigger application it
might be better to start with the ORM from the get-go. By using the ORM, you basically abstract away the SQL stuff.
You interact with the db using `Model` objects, i.e. data classes. In this case, Models represent your db's tables,
the attributes of Models represent the table's columns.

A Session is a persistent database connection that makes it easier to communicate with our database. The session
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

!!! Info "On sessionmaker"

    Session is a regular Python class which can be directly instantiated. However, to standardize how sessions are
    configured and acquired,the
    [`sessionmaker`](https://docs.sqlalchemy.org/en/14/orm/session_api.html#sqlalchemy.orm.sessionmaker) class is
    normally used to create a top level `Session` configuration which can then be used throughout an application without
    the need to repeat the configuration arguments.

## Models (i.e. tables)

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

!!! tip "Models & Schemas"

    When building Python api/crud apps, we often use both SQLAlchemy & [Pydantic](pydantic.md). Both packages use
    the concept of `Models` when referring to their data classes. To differentiate between them, I'll refer to my
    Pydanctic Models as **schemas** and my sqlalchemy models as **models**.

When you create an instance of a model (e.g., you create a user), you are effectively creating a new row in the
associated db table. But before you can do that, you first need to make sure that you have a table already. Now, you
can either create that by (i) accessing your database and create a table manually, (ii) use SA's built-in method on
your Base class that creates the tables for you (see code sample below); or (iii) make use of migration tool such as
[Alembic](alembic.md).

```python
# continues from above
Base.metadata.create_all(engine)
```

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

# Entity relationships in SQLAlchemy

SA provides several features that allow you to define [entity relations](entity-relationship.md) in your app's data
model. To understand [relationships in SA](https://docs.sqlalchemy.org/en/14/orm/relationships.html), imagine that
we build an app for blogging where we need three models:

```python
from sqlalchemy import declarative_base, Column, Integer, Text, String, DateTime, Boolean  # noqa
from sqlalchemy.sql import func  # noqa


class User():
    """User account."""
    __tablename__ = "user"

    id = Column(Integer, primary_key=True, autoincrement="auto")
    username = Column(String(255), unique=True, nullable=False)
    password = Column(Text, nullable=False)
    email = Column(String(255), unique=True, nullable=False)


class Comment():
    """User-generated comment on a blog post."""
    __tablename__ = "comment"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer)
    post_id = Column(Integer, index=True)
    body = Column(Text)
    upvotes = Column(Integer, default=1)
    removed = Column(Boolean, default=False)
    created_at = Column(DateTime, server_default=func.now())


class Post():
    """Blog post."""
    __tablename__ = "post"

    id = Column(Integer, primary_key=True, index=True)
    author_id = Column(Integer)
    slug = Column(String(255), nullable=False, unique=True)
    title = Column(String(255), nullable=False)
    summary = Column(String(400))
    feature_image = Column(String(300))
    body = Column(Text)
    status = Column(String(255), nullable=False, default="unpublished")
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now())
```

## One-to-many

We use the `relationship` function to provide a relationship between two mapped classes. Consider it some kind of
"magic" attribute that will contain the values from other tables related to this one. We update our `Post` and
`Comment` Models to implement the relationship accordingly:

```python
...


class Comment():
    """User-generated comment on a blog post."""
    __tablename__ = "comment"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("user.id"))  # ---- (1.i) ----
    post_id = Column(Integer, ForeignKey("post.id"), index=True)  # ---- (1.ii) ----
    body = Column(Text)
    upvotes = Column(Integer, default=1)
    removed = Column(Boolean, default=False)
    created_at = Column(DateTime, server_default=func.now())

    # Relationships
    user = relationship("User")  # ---- (2.i) ----


class Post():
    """Blog post."""
    __tablename__ = "post"

    id = Column(Integer, primary_key=True, index=True)
    author_id = Column(Integer, ForeignKey("user.id"))  # ---- (1.iii) ----
    slug = Column(String(255), nullable=False, unique=True)
    title = Column(String(255), nullable=False)
    summary = Column(String(400))
    body = Column(Text)
    status = Column(String(255), nullable=False, default="unpublished")
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now())

    # Relationships
    author = relationship("User")  # ---- (2.ii) ----
    comments = relationship("Comment")  # ---- (2.iii) ----
```

As shown above, we have added several one-to-many relationships using the (1) `ForeignKey` and (2) `relationship()`
concepts:

1. We've set some attributes (i.e., columns) as Foreign Keys with `ForeignKey` property.We basically tie data
   between our tables so that fetching one will allow us to get information about the other.
    1. Our `comment` table has a foreign key `user.id` linked to its `user_id` attribute, indicating that the
       commenter has a record in the `user` table.
    2. This table also has a foreign key `post.id` linked to its `post_id` attribute, indicating that a comment
       should have a relation to an existing post in the `post` table.
    3. Lastly, we note that our `post` table has a foreign key `user.id` linked to its `author_id` attribute,
       indicating a relation with the `user` table.
2. The other new concept here is relationships. Relationships complement foreign keys and are a way of telling our
   application (not our database) that we're building relationships between two `Models` (instead of db tables!).
    1. In our `Comment` Model we define a relationship with the `User` model and assign it to `user`.
    2. Similarly, in our `Post` Model we define a relationship between our `author` attribute and the `User` Model, and
    3. We define a relationship between our `comments` atttribute and the `Comment` Model.

!!! Info "On FKs and relationships()"

    Foreign keys tell our _database_ which relationships we're building, and relationships tell our _app_ which
    relationships we're building.

The point of all this is the ability to easily perform JOINs in our app. When using an ORM, we wouldn't be able to
say "join this `Model` with that `Model`", because our app would have no idea which columns (Model attributes) to join
on. When our relationships are specified in our Models, we can do things like join two tables together without
specifying any further detail: SQLAlchemy will know how to join tables/models by looking at what we set in our data
models (through foreign keys & relationships).

!!! tip

    SQLAlchemy only creates tables from data models if the tables don't already exist. In other words, if we have faulty
    relationships the first time we run our app, the error messages will persist the second time we run our app, even
    if we think we've fixed the problem. To deal with strange error messages, try deleting your SQL tables before
    running your app again whenever making changes to a model.

## Back references

Specifying relationships on a data model allows us to access properties of the linked model via a property on the
original model. If we were to join our `Comment` model with our `User` model, we'd be able to access the properties
of a comment's author via `Comment.user.username`, where `user` is the name of our relationship, and `username` is a
property of the associated model (the `User` model in this case).

Relationships created in this way are one-directional, in that the `Comment` model can access the `User` props through
its `user` prop, but the `User` model can't access the props of the `Comment` model. SA provides the `backref` param
to enable just that, making it a bidirectional relationship. Let's update our `Post` Model:

```python
author = relationship("User", backref="posts")
```

We can now access user details of a post by calling `Post.author`. Go to the section

# Code example - working with our models & SA

We are fist going to instantiate 1 `User` and 2 `Post` objects:

```python
# objects.py

admin_user = User(
    username="Bob-12",
    password="Please don't set passwords like this",
    email="Bob12@example.com",
)

post_1 = Post(
    author_id = admin_user.id,
    slug = "fake-post-slug",
    title = "fake title",
    summary = "a post example",
    body = "lorem ipsum blabla. This contains the actual text of the post",
    status = "published"
)

post_2 = Post(
    author_id=admin_user.id,
    slug="an-additional-post",
    title="Yet Another Post Title",
    summary="An in-depth exploration into writing your second blog post.",
    body="Smelly cheese cheese slices fromage",
    status="published",
)
```

Now we want to create functions that allow us to save our objects to the database:

```python
# orm.py

def create_user(session: Session, user: User) -> User:
    """
    Create a new user if username isn't already taken.

    :param session: SQLAlchemy database session.
    :type session: Session
    :param user: New user record to create.
    :type user: User

    :return: Optional[User]
    """
    try:
        existing_user = session.query(User).filter(User.username == user.username).first()
        if existing_user is None:
            session.add(user)  # Add the user
            session.commit()  # Commit the change
            LOGGER.success(f"Created user: {user}")
        else:
            LOGGER.warning(f"Users already exists in database: {existing_user}")
        return session.query(User).filter(User.username == user.username).first()
    except IntegrityError as e:
        LOGGER.error(e.orig)
        raise e.orig
    except SQLAlchemyError as e:
        LOGGER.error(f"Unexpected error when creating user: {e}")
        raise e


def create_post(session: Session, post: Post) -> Post:
    """
    Create a post.

    :param session: SQLAlchemy database session.
    :type session: Session
    :param post: Blog post to be created.
    :type post: Post

    :return: Post
    """
    try:
        existing_post = session.query(Post).filter(Post.slug == post.slug).first()
        if existing_post is None:
            session.add(post)  # Add the post
            session.commit()  # Commit the change
            LOGGER.success(
                f"Created post {post} published by user {post.author.username}"
            )
            return session.query(Post).filter(Post.slug == post.slug).first()
        else:
            LOGGER.warning(f"Post already exists in database: {post}")
            return existing_post
    except IntegrityError as e:
        LOGGER.error(e.orig)
        raise e.orig
    except SQLAlchemyError as e:
        LOGGER.error(f"Unexpected error when creating user: {e}")
        raise e
```

First we pass our objects to the crud functions to store them in our db, and subsequently we define a function that
allows us to retrieve the data from our db.

```python
# objects.py
...
admin_user = create_user(session, admin_user)
post_1 = create_post(session, post_1)
post_2 = create_post(session, post_2)

# orm.py
...
def get_all_posts(session: Session, admin_user: User):
    """
    Fetch all posts belonging to an author user.

    :param session: SQLAlchemy database session.
    :type session: Session
    :param admin_user: Author of blog posts.
    :type admin_user: User

    :return: None
    """
    posts = (
        session.query(Post)  # (1)
        .join(User, Post.author_id == User.id)  # (2)
        .filter_by(username=admin_user.username)  # (3)
        .all()
    )

```

In our `get_all_posts` function, we:

1. query our db table associated with the `Post` model (i.e., the `post` table).
2. We then JOIN `posts` with `user` using the `.join(User, Post.author_id == User.id)` param. Here, we basically
   'paste' the columns of the `user` table "behind" the columns of the `post` table. To ensure that the values are
   associated with the correct record (i..e, author), you _tie_ both data fields together by assigning
   the `Post.author_id` to `User.id`.
3. Lastly, we fetch all posts in our database belonging to our user `admin_user`: we tell the db to only get the
   data where the `username` attribute in our `user` table equal the `admin_user.username` value (Bob-12 in our
   example).

# References

**General:**

* [Hackers & Slackers](https://hackersandslackers.com/python-database-management-sqlalchemy)

**Data relationships in SQLAlchemy:**
