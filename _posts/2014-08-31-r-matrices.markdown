---
layout: post
title:  "R - Matrices and Lists"
date:   2014-08-31 11:44:27
categories: r programming matrices
---

## C. Matrices

A matrix is a collection of data elements arranged in a two-dimensional rectangular layout.

### 1. Matrix Elements

The elements i a matrix must be all of the same basic type. By default, matrix elements are arranged along the column direction.

{% highlight r %}
    a <- matrix(c(2,1,4,5,3,7), nrow =2)
{% endhighlight %}



## D. Lists

A list is a generic vector containing other objects. It allows objects of differente data type to reside together in the same container.

### 1. List Index

{% highlight r %}
n <- c(2,3,5)
s <- c("a","b","c","d")
b <- c(TRUE,FALSE,TRUE,FALSE)

x <- list(n,s,b,3>
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

