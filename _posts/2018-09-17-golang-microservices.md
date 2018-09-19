---
layout: post
title:  "Go Microservices"
date:   2018-09-16 12:07
categories: go 
tags: go
---

This post is based on the EXCELENT blog [Go Microservices Blog Series](http://callistaenterprise.se/blogg/teknik/2017/02/17/go-blog-series-part1/).


All of these are things must be taken into account
 when deciding to go for a microservice architecture regardless 
 if it is going to be code in Go, Java, js, python or  C# .

* Centralized configuration
* Service Discovery
* Logging
* Distributed Tracing
* Circuit Breaking
* Load balancing
* Edge
* Monitoring
* Security

Another perspective are things within your actual microservice 
implementation. Regardless of where you’re coming from, you probably 
have worked with libraries that provides things such as:

* HTTP / RPC / REST / SOAP / Whatever APIs
* Persistence APIs (DB clients, JDBC, O/R mappers)
* Messaging APIs (MQTT, AMQP, JMS)
* Testability (Unit / Integration / System / Acceptance)
* Build tools / CI / CD

## Create a Go Microservice

## Testing Microservices

One should keep the principles of the
 [testing piramid](https://testing.googleblog.com/2015/04/just-say-no-to-more-end-to-end-tests.html)
 in mind.

Unit test should form the bulk of your test as integragion, e2e,
system and acceptaance tests are increasingly expensive to develop
and mantain.

Unit test as usual - there is nothing magic with your business
logic, converters, validation, etc. just because they are running
int the context of a microservice.

Integration componentes such as clients for communicating with
other sercies, sending messages, accessing databases, etc., should be designed
with dependency injection and mockability taken into account.

A lost of the microservice specifics - accessing configuration, talking to 
other services, resilience testing, etc. can be quite difficult to
unit test without spending ridiculous amounts of time writing mocks for 
a rather small value. Save those kind of tests to integration-like tests where you actually 
boot dependent services as Docker containers in your test code. It will
provide greater value and will probably be easier to get up and running
as well.

## Mocking

There are a numbers of strategies on how to do mocking in Go. One is implemented using the
 [stretch/testify/mock](https://github.com/stretchr/testify#mock-package)
package.

If you dislike writing boilerplate code for your mocks, take a look at 
[Mockery](https://github.com/vektra/mockery) which can generate mocks for any Go interface.

We’ll start with a sad path test that asserts that we get a HTTP 404 if we request an unknown path:

{% highlight go %}
package service

import (
    . "github.com/smartystreets/goconvey/convey"
    "testing"
    "net/http/httptest"
)

func TestGetAccountWrongPath(t *testing.T) {

    Convey("Given a HTTP request for /invalid/123", t, func() {
        req := httptest.NewRequest("GET", "/invalid/123", nil)
            resp := httptest.NewRecorder()

        Convey("When the request is handled by the Router", func() {
            NewRouter().ServeHTTP(resp, req)

            Convey("Then the response should be a 404", func() {
                So(resp.Code, ShouldEqual, 404)
            })
        })
    })
}
{% endhighlight %}

This test shows the “Given-When-Then” Behaviour-driven structure of GoConvey and also the “So A ShouldEqual B” assertion style. It also introduces usage of the httptest package where we use it to declare a request object as well as a response object we can perform asserts on in a convenient manner.


### PROGRAMMING THE MOCK

Let’s create another test function in handlers_test.go:

{% highlight go %}
func TestGetAccount(t *testing.T) {
        // Create a mock instance that implements the IBoltClient interface
        mockRepo := &dbclient.MockBoltClient{}

        // Declare two mock behaviours. For "123" as input, return a proper Account struct and nil as error.
        // For "456" as input, return an empty Account object and a real error.
        mockRepo.On("QueryAccount", "123").Return(model.Account{Id:"123", Name:"Person_123"}, nil)
        mockRepo.On("QueryAccount", "456").Return(model.Account{}, fmt.Errorf("Some error"))
        
        // Finally, assign mockRepo to the DBClient field (it's in _handlers.go_, e.g. in the same package)
        DBClient = mockRepo
        ...
}
{% endhighlight %}

Next, replace the … above with another GoConvey test:

{% highlight go %}
Convey("Given a HTTP request for /accounts/123", t, func() {
        req := httptest.NewRequest("GET", "/accounts/123", nil)
        resp := httptest.NewRecorder()

        Convey("When the request is handled by the Router", func() {
                NewRouter().ServeHTTP(resp, req)

                Convey("Then the response should be a 200", func() {
                        So(resp.Code, ShouldEqual, 200)

                        account := model.Account{}
                        json.Unmarshal(resp.Body.Bytes(), &account)
                        So(account.Id, ShouldEqual, "123")
                        So(account.Name, ShouldEqual, "Person_123")
                })
        })
})
{% endhighlight %}

This test performs a request for the known path /accounts/123 which our mock knows about. In the “When” block, we assert HTTP status, unmarshal the returned Account struct and asserts that the fields match what we asked the mock to return.

What I like about GoConvey and the Given-When-Then way of writing tests is that they are really easy to read and have great structure.

[GoConvey](http://goconvey.co/) actually has an interactive GUI that can execute all tests everytime we save a file. 


### Health Check