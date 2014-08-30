---
layout: post
title:  "R Programming"
date:   2014-08-28 21:51:27
categories: r programming
---

## A. Basic Data Types

### Numeric

Decimal values are called numerics.

    x <- 10.5
    
### Integers

    y <- as.integer(3)
    y <- 3L
    
    TRUE has value 1, FALSE has value 0
    
### Complex

Are defined using the pure imaginary value `i`

    z <- 1 + 2i
    
    z <- as.complex(-1)
    
### Logical
 
    z = x + y  

Logical operators

- & and
- \| or
- ! negation


## B. Vectors

A vector is a sequence of data elements of the same basic type. Members are called components.

    a <- c(1,3,5)
    
To find number of components:

    length(a)
    
### 1. Combining Vectors

Vectors are combined using the function `c`

    c(a,b)
    
### 2. Vector Arithmetics

    a <- c(1,3,5,7)
    b <- c(1,2,4,8)
    
    5*1
    a+b
    
If two vectors are of unequal length, the shorter one will be recycled in order to match the longer vector.

### 3. Vector Index

We retrive values in a vector by declaring an index inside a single squera bracket `[]`. The result is other vector

    s[3]
    
If the index is negative, it would strip the member whose position has the same absoluite value as the negative index.

### 4. Numeric Index Vector

a new vector canb be sliced from a given vector with a numeric indes vector, which contains intended member positions of the original vector to be retrieved.

    s[c(2,3)]
    
An index vector allows duplicate values

    s[c(2,3,3)]

To produce a vector slice between two members, we can use the colon operator ":"

    s[2:4]
    
