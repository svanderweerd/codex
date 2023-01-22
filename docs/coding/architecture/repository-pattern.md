This section draws heavily from [Martin Fowler's](https://martinfowler.com/eaaCatalog) Patterns of Enterprise
Architecture Applications, and _Domain Driven Design_.

A system with a complex domain model (the place where the business logic is put) often benefits from a layer, such
as the one provided by [Data Mapper](https://martinfowler.com/eaaCatalog/dataMapper.html), that isolates domain
objects from details of the database access code. In such systems it can be worthwhile to build another layer of
abstraction over the mapping layer where query construction code is concentrated. This becomes more important when
there are a large number of domain classes or heavy querying. In these cases particularly, adding this layer helps
minimize duplicate query logic.

A Repository mediates between the domain and data mapping layers, acting like an in-memory domain object collection.
Client objects construct query specifications declaratively and submit them to Repository for satisfaction. Objects can
be added to and removed from the Repository, as they can from a simple collection of objects, and the mapping code
encapsulated by the Repository will carry out the appropriate operations behind the scenes. Conceptually, a Repository
encapsulates the set of objects persisted in a data store and the operations performed over them, providing a more
object-oriented view of the persistence layer. Repository also supports the objective of achieving a clean separation
and one-way dependency between the domain and data mapping layers.

!!! info

    A repository can be considered an interface that serves as your apps's gateway to the database, in terms of
    object-relational mappings.
