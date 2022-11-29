Everything in Python is an object. Each object has its own data attributes and methods associated with it. In order
to use an object efficiently and appropriately, we should know how to interact with them. Lists, tuples, and sets are 3
important types of objects. What they have in common is that they are used as data structures. In order to create robust
and well-performing products, one must know the data structures of a programming language very well.

Data structures that I use the most are:

* list
* tuple
* dict
* set
* array & bytes
* range
* dataclass

# Lists, tuples & sets

`list` is a built-in data structure in Python. It is represented as a collection of data points in square brackets.
Lists
can be used to store any data type or a mixture of different data types. Lists are mutable which is one of the reasons
why they are so commonly used.

`tuple` is a collection of values separated by comma and enclosed in parentheses. Unlike lists, tuples are immutable.
The immutability can be considered as the identifying feature of tuples.

`set` is an unordered collection of distinct immutable objects. A set contains unique elements. Although sets are
mutable, the elements of sets must be immutable. There is no order associated with the elements of a set. Thus, it
does not support indexing or slicing like we do with lists.

```python
my_list = [1, 2, "3"]
my_set = {1, 2, "3"}
my_tuple = (1, 2, "3")
```

Lists enable indexing and slicing. They can also be nested and have a variety of useful methods that can be
called off of them.

## Dict & Sets

# References

* [15 examples to master Python lists, sets and tuples](https://towardsdatascience.com/15-examples-to-master-python-lists-vs-sets-vs-tuples-d4ffb291cf07)
*
