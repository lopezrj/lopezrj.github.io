---
layout: Post
title:  "R -  Matrices and Lists"
date:   2014-08-29 11:44:27
categories: r programming matrices
tags: [r, data science, data types]
---

## A. Matrices

A matrix is a collection of data elements arranged in a two-dimensional rectangular layout.

### 1. Matrix Elements

The elements in a matrix must be all of the same basic type. By default, matrix elements are arranged along the column direction.

{% highlight r %}
    a <- matrix(c(2,1,4,5,3,7), nrow =2)
{% endhighlight %}

We can input matrix elements along the row direction by enabling the by row option.
{% highlight r %}
    b <- matrix(c(2,1,4,5,3,7), nrow =2, byrow = TRUE)
{% endhighlight %}

A matrix of M rows and N columns is called a M x N matrix. An element at the m<sup>th</sup> row and n<sup>th</sup> column can be accessed via
{% highlight r %}
    a[m,n]
{% endhighlight %}

The entire m<sup>th</sup> row can be extracted as a[m,].
The entire n<sup>th</sup> column can be extracted as a[,n]
These return a vector. To return a matrix use `drop=False` 
as argument.

If we assign names to the rows and columns, then we can access matrix elements by names instead of coordinates
{% highlight r %}
a["row2","col3"]
{% endhighlight %}

### 2. Matrix Construction

#### a) Transpose
We construct the transpose of a matrix by interchanging its columns and rows using the function `t`
{% highlight r %}
t(a)
{% endhighlight %}

#### b) Combining Matrices

To combine two matrices with same numbres of rows use `cbind`
{% highlight r %}
cbind(b,c)
{% endhighlight %}

To combine two matrices having same numbers of columns use the function `rbind`
{% highlight r %}
rbind(b,d)
{% endhighlight %}

### 3. Matrix Arithmetics

#### a) Addition and substraction

We can add or substract two matrices when they have the same dimensions
{% highlight r %}
a+b
{% endhighlight %}

#### b) Multiplication

We can multiply two matrices together if the column dimension of the firt matrix is the same as the row dimension of the second madtrx.
{% highlight r %}
a%*%b
{% endhighlight %}

___Useful links:___

* [UCLA - R Library: Matrices and matrix computations in R](http://www.ats.ucla.edu/stat/r/library/matrix_alg.htm "R Library: Matrices and matrix computations in R")


## B. Lists

A list is a generic vector containing other objects. It allows objects of differente data type to reside together in the same container.

### 1. List Index

{% highlight r %}
n <- c(2,3,5)
s <- c("a","b","c","d")
b <- c(TRUE,FALSE,TRUE,FALSE)

x <- list(n,s,b,3)
{% endhighlight %}    


####List Slicing

To retrieve a list slice use the single square bracket "[]" operator.

{% highlight r %}
    x[2]
{% endhighlight %}    

With an index vector, we can retrieve a slice with multiple list members.

{% highlight r %}
    x[c(2,4)]
{% endhighlight %}    

#### Member access

To directly access a list member, we have to use the double square bracket "[[]]" operator.

{% highlight r %}
    x[[2]]
{% endhighlight %}    

### 2. Named Members

We can assign names to list members and reference them by names instead of numeric indexes.

{% highlight r %}
    v <- list(peter = c(2,3,5), john= c("aa", "bb"))
{% endhighlight %}    

#### List Slicing

We retrieve a list slice with the single square bracket "[]" operator.

{% highlight r %}
    v["peter"]
{% endhighlight %}    

With an index vector, we can retrive a slice with multiple members

{% highlight r %}
   v[c("peter","john")]
{% endhighlight %}    

#### Member Access

{% highlight r %}
v <- [["peter"]]

v$peter
{% endhighlight %}    


We can attach a list to the R search path and access its members without explicitly mentioning the list.

{% highlight r %}
attach(v)
    peter  ## output: c(2,3,5)
detach(v)  ## should be explicitly detached for cleanup
{% endhighlight %}    
