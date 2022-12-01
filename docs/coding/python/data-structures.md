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

## List vs Sets

Consider the following:

```python
text = "Hello World!"

print(list(text))
['H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd', '!']

print(set(text))
{'H', 'W', 'o', ' ', 'l', 'r', '!', 'e', 'd'}
```

As you can see above, the first `print` statement returns a `list` (i) with all the characters in the `text`
variable and (ii) ordered based on the order of the chars in the `text` string. The second statement returns a `set`
(i) containing only unique characters, as a `set` doesn't allow duplicate values. Secondly, (ii) a set is unordered,
hence the random positions of the chars in the set.

In the previous example, we saw that sets do not possess an order. Thus, we cannot do slicing or indexing on sets like
we do with lists. The example below demonstrates this:

```python
text = "Hello World!"

list_a = list(text)

print(list_a[:2])  # print item in list from index position 0 up until (but excluding) 2
['H', 'e']

set_a = set(text)
print(set_a[:2])  # returns a TypeError: 'set' object is not subscriptable
```

## List vs Tuples

The difference between list and tuple is the mutability. Unlike lists, tuples are immutable. For instance, we can add
items to a list but cannot do it with tuples. The methods that change a collection (e.g. append, remove, extend, pop)
are not applicable to tuples, as shown below:

```python
list_a: list[int] = [1,2,3,4]  # apply type specification
list_a.append(5)

print(list_a)
[1,2,3,4,5]

tuple_a = (1,2,3,4)
tuple_a.append(5)  # AttributeError: 'tuple' object has no attribute 'append'
```

The immutability might be the most identifying feature of tuples. We cannot (re)assign a value to an item of a
tuple:

```python
tuple_a = (3, 5, 'x', 5)
tuple_a[0] = 7  # will generate an error
```

Although tuples are immutable, they can contain mutable elements such as lists or sets:

```python
tuple_a = ([1,3], 'a', 'b', 8)  # this tuple contains a list with 2 items
tuple_a[0][0] = 99  # we reassign our first item in the list from value 1 to 99

print(tuple_a)
([99, 3], 'a', 'b', 8)
```

## Working with lists, sets, and tuples

# References

* [15 examples to master Python lists, sets and tuples](https://towardsdatascience.com/15-examples-to-master-python-lists-vs-sets-vs-tuples-d4ffb291cf07)
* [Difference between del, remove, and pop](https://www.stechies.com/difference-between-del-remove-pop-lists/)
*
