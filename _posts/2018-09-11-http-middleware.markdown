---
layout: post
title:  "HTTP Middleware"
date:   2018-09-11 12:07
categories: go 
tags: go
---

When you're building a web application there's probably some shared functionality that you want to run for many (or even all) HTTP requests. You might want to log every request, gzip every response, or check a cache before doing some heavy processing.

One way of organising this shared functionality is to set it up as __middleware__ – self-contained code which independently acts on a request before or after your normal application handlers. In Go a common place to use middleware is between a `ServeMux` and your application handlers, so that the flow of control for a HTTP request looks like:

{% highlight %}
    ServeMux => Middleware Handler => Application Handler
{% endhighlight %}

### The Basic Principles

Making and using middleware in Go is fundamentally simple. We want to:

* Implement our middleware so that it satisfies the `http.Handler` interface.
* Build up a chain of handlers containing both our middleware handler and our normal application handler, which we can register with a http.ServeMux.
I'll explain how.

Hopefully you're already familiar with the following method for constructing a handler (if not, it's probably best to read this [primer](https://www.alexedwards.net/blog/a-recap-of-request-handling) before continuing).

{% highlight go %}
func messageHandler(message string) http.Handler {
  return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte(message)
  })
}
{% endhighlight %}

In this handler we're placing our logic (a simple `.Write`) in an anonymous function and closing-over the message variable to form a closure. We're then converting this closure to a handler by using the http.HandlerFunc adapter and returning it.

We can use this same approach to create a chain of handlers. Instead of passing a string into the closure we could pass the next handler in the chain as a variable, and then transfer control to this next handler by calling it's `ServeHTTP()` method.

This gives us a complete pattern for constructing middleware:

{% highlight go %}
func exampleMiddleware(next http.Handler) http.Handler {
  return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
    // Our middleware logic goes here...
    next.ServeHTTP(w, r)
  })
}
{% endhighlight %}

This middleware function has a `func(http.Handler) http.Handler` signature. It accepts a handler as a parameter and returns a handler. This is useful for two reasons:

* Because it returns a handler we can register the middleware function directly with the standard ServeMux provided by the net/http package.
* We can create an arbitrarily long handler chain by nesting middleware functions inside each other. For example:

{% highlight go %}
    http.Handle("/", middlewareOne(middlewareTwo(finalHandler)))
{% endhighlight %}

