---
title: Entity Relationship Modelling
tags: [db]
---

This post will cover my understanding on entity relationship modelling. There are several types of entity relations:

* one-to-many: a _Customer_ can have several _Orders_ whereas an Order can't have several Customers.
* many-to-many: an Author can have several Books, but a Book can have several Authors as well.

# One to Many

One-to-many (or many-to-one) relationships are the most common type of database relationships. A timeless example of how
such a relationship is applied is a business' relationship between _customers & orders_. Single customers have multiple
orders, but orders don't have multiple customers, hence the term.

Now, building on our Blog site, we can understand that authors might have multiple posts, and that posts might have
multiple comments. These are two typical one-to-many relationships.

# Many to Many

However, we might also have a data model where an Author might have multiple Post and a Post might have multiple
Authors.

# Foreign Keys
