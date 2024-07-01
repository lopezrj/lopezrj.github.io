---
layout: post
title:  "R - Basic Data Types and Vectors"
date:   2014-08-28 21:51:27
categories: r programming vectors
tags: [r, data types]
---

## A. Basic Data Types

### Numeric

Decimal values are called numerics.

{% highlight r %}
    x <- 10.5
{% endhighlight %}    
    
### Integers

{% highlight r %}
    y <- as.integer(3)
    y <- 3L
{% endhighlight %}    
    
TRUE has value 1, FALSE has value 0
    
### Complex

Are defined using the pure imaginary value `i`

{% highlight r %}
    z <- 1 + 2i
    
    z <- as.complex(-1)
{% endhighlight %}    

### Logical
 
{% highlight r %}
    z = x + y  
{% endhighlight %}    

Logical operators

- & and
- \| or
- ! negation


## B. Vectors

A vector is a sequence of data elements of the same basic type. Members are called components.

{% highlight r %}
    a <- c(1,3,5)
{% endhighlight %}    
    
To find number of components:

{% highlight r %}
    length(a)
{% endhighlight %}    
    
### 1. Combining Vectors

Vectors are combined using the function `c`

{% highlight r %}
    c(a,b)
{% endhighlight %}    

### 2. Vector Arithmetics

{% highlight r %}
a <- c(1,3,5,7)
b <- c(1,2,4,8)

5 * 1
a + b
{% endhighlight %}    

If two vectors are of unequal length, the shorter one will be recycled in order to match the longer vector.

### 3. Vector Index

We retrive values in a vector by declaring an index inside a single squera bracket `[]`. The result is other vector

{% highlight r %}
    s[3]
{% endhighlight %}    

If the index is negative, it would strip the member whose position has the same absoluite value as the negative index.

### 4. Numeric Index Vector

a new vector canb be sliced from a given vector with a numeric indes vector, which contains intended member positions of the original vector to be retrieved.

{% highlight r %}
    s[c(2,3)]
{% endhighlight %}    
    
An index vector allows duplicate values

{% highlight r %}
    s[c(2,3,3)]
{% endhighlight %}    

To produce a vector slice between two members, we can use the colon operator ":"

{% highlight r %}
    s[2:4]
{% endhighlight %}    

###5. Logical Index Vector

A new vector can be sliced from a given vector with a logical index vector, which has the same length as the original vector. Its members are TRUE if the corresponding members in the original vector are to be included in the slice, and FALSE if otherwise.

{% highlight r %}
s <- c("a","b","c","d")

s[c(FALSE, TRUE, FALSE, TRUE)]
{% endhighlight %}    


### 6. Named Vector Members

{% highlight r %}
v <- c("Peter","John")
names(v) <- c("First","Last")

v["First"]    # Outputs "Peter"

v["Last","First"]    # Outputs "John Peter"


{% endhighlight %}    

