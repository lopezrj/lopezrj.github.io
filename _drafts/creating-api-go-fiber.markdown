---
layout: post
title:  "Fiber and GO"
date:   2021-10-29 21:51:27
categories: go
tags: [api fiber go]
---

# Creating Fast APIs In Go Using Fiber


Fiber is a web framework that is very similar to Express, which makes it a perfect choice for any Node.js developer that decides to delve into the land of gophers. The framework is a well-designed wrapper around another framework - Fasthttp - which is considered to be one of the fastest web frameworks written in Go. Overall, these are the main advantages of Fiber:

- Express-like syntax
- Highly performant, thanks to the underlying Fasthttp framework
- Zero memory allocation
- Easy to learn, especially if you've used Express or Koa before
- Easy to write unit tests for, thanks to the built-in Test method

We're gonna build the API for a todo app using Fiber and MongoDB.

## Prerequisites

The very first thing we need to make sure of is that we have all our dependencies ready. We're of course going to need to have Go (1.11 or later) installed on our machine. We'll also need a MongoDB server running on our machine (or you could use MongoDB Atlas). Make sure to create a database called todos. I'm not going to go into how to install and configure these, since it's pretty straightforward, so we can focus on the Go stuff!

Once we have our stuff ready, we're ready to Go! Let's first create a directory for our project and initialize a Go module:

{% highlight bash %}
mkdir tasks-api
cd tasks-api
go mod init github.com/yourusername/tasks-api
{% endhighlight %}

Once the module is ready, we need to install our project's Go dependencies. Since we've created a module, Go will add these dependencies to the go.mod file.

{% highlight bash %}
go get github.com/gofiber/fiber
go get github.com/Kamva/mgm/v2
go get go.mongodb.org/mongo-driver
{% endhighlight %}

The first dependency is obviously the Fiber web framework, the second one is a MongoDB ODM for Go, and the third one is the official MongoDB driver for Go. Once these steps are done, we can start writing some code!

## The Directory Structure

Our todo API will have the following directory structure:

{% highlight bash %}
.
├── controllers
│   └── TodoController.go
├── go.mod
├── go.sum
├── models
│   └── Todo.go
└── server.go

2 directories, 5 files
{% endhighlight %}

The controllers directory will contain the controllers for each route or middleware that we're going to define in our Fiber app. For the sake of organization, it's recommended that you separate your controllers based on the model you're working with. This doesn't really make sense now, since we only have one model - the Todo model, but our application might scale in the future and include things like users and sessions.

The models directory contains the definitions of our models. As I said in the previous paragraph, our application currently only has one model, but if our app also had authentication/users, that would require a separate model.

server.go is the main entry point of our application. This is where we define our routes, middlewares, initialize our MongoDB connection, and start the server. In larger applications, I'd split these steps in separate files, again, for the sake of organization, but I feel like that's not necessary for such a small application right now.

The controllers directory will contain the controllers for each route or middleware that we're going to define in our Fiber app. For the sake of organization, it's recommended that you separate your controllers based on the model you're working with. This doesn't really make sense now, since we only have one model - the Todo model, but our application might scale in the future and include things like users and sessions.

The models directory contains the definitions of our models. As I said in the previous paragraph, our application currently only has one model, but if our app also had authentication/users, that would require a separate model.

server.go is the main entry point of our application. This is where we define our routes, middlewares, initialize our MongoDB connection, and start the server. In larger applications, I'd split these steps in separate files, again, for the sake of organization, but I feel like that's not necessary for such a small application right now.

The Todo Model
MGM is a MongoDB object-document mapper, which means it contains object definitions and methods that make it easy to read and mutate data in our MongoDB database.

Our Todo model should be straightforward: it should contain the title of the todo, a description, and a boolean that specifies whether the todo is done or still pending.

In our models folder, create a file called Todo.go. Since this file is inside of the models folder, it means that the name of the Go package it belongs to will be models. Let's start by defining our package and importing the MGM dependency:

package models

import (
    "github.com/Kamva/mgm/v2"
)
Now, we can specify and export the Todo model by defining it as a struct-like type. Remember that in Go, a variable, type definition, or function will only be exported if it starts with a capital letter, so make sure to write Todo and not todo when defining your model!

// Todo is the model that defines a todo entry
type Todo struct {
    mgm.DefaultModel `bson:",inline"`
    Title            string `json:"title" bson:"title"`
    Description      string `json:"description" bson:"description"`
    Done             bool   `json:"done" bson:"done"`
}
At the beginning of the model's definition, we "inherit" from MGM's DefaultModel interface, which allows us to use the methods and properties that apply to any MongoDB model (such as the _id, created_at, and updated_at fields). Once that is done, we can define our fields.

To make things a bit cleaner, we can write a wrapper function that creates a new Todo object for us. We can use something like this:

// CreateTodo is a wrapper that creates a new todo entry
func CreateTodo(title, description string) *Todo {
    return &Todo{
        Title:       title,
        Description: description,
        Done:        false,
    }
}
This function takes a title and a description as parameters, and returns a pointer to a Todo struct that contains the specified data. You can go very creative and customize these wrappers as your application scales.

The Controllers
This is where we define functions that we can use as fallbacks in the Fiber route and middleware definitions. Our app doesn't have any middlewares, so here's a list of all the routes that we'll need:

GET /api/todos - lists all todos in the database
GET /api/todos/:id - retrieves a todo based on its ID
POST /api/todos - creates a Todo object and adds it to the database
PATCH /api/todos/:id - changes the Done property of a todo based on its ID
DELETE /api/todos/:id - deletes a todo based on its ID
Let's create a file called TodoController.go inside of the controllers directory and define the package as well as its imports:

package controllers

import (
    "github.com/Kamva/mgm/v2"
    "github.com/gofiber/fiber"
    "github.com/yourusername/tasks-api/models"
    "go.mongodb.org/mongo-driver/bson"
)
Don't forget to replace github.com/yourusername/tasks-api with the name of your module (that you provided when you ran go mod init).

Now that we have that out of the way, we can start defining the controllers for our routes. Let's start with the GET /api/todos route.

GET all todos
Since every controller will be a callback function that we'll pass as a second parameter to our route definitions, we need to make sure our function works like what Fiber expects in a route definition. Our function accepts one parameter (the request context) and should not return anything:

// GetAllTodos - GET /api/todos
func GetAllTodos(ctx *fiber.Ctx) {
    // TODO: implement
}
(note: the comment above the function's name doesn't have to look like that, I just think it makes it easier to instantly know what controller does what)

First we need to access our todos collection. We can do using mgm.Coll():

collection := mgm.Coll(&models.Todo{})
Then we need to initialize an empty array of type models.Todo to store our todos in:

todos := []models.Todo{}
Now we can use collection.SimpleFind() to fetch all entries in the database. The function takes two parameters: the first parameter is the memory address of the variable in which the result should be stored and the second is a filter. If the filter is empty, it will return all entries.

err := collection.SimpleFind(&todos, bson.D{})
if err != nil {
    ctx.Status(500).JSON(fiber.Map{
        "ok":    false,
        "error": err.Error(),
    })
    return // necessary, or else the controller will continue
}
You'll notice that we've done some error checking. If for some reason, the MongoDB driver can't access the collection's items (i.e. connection issues, non-existing database), it will set the HTTP status of the response to 500 (Internal Server Error) and will return a JSON object that contains the error message returned by the driver. Notice how we used fiber.Map to send a JSON response. This is very handy! Here's how the error handler would look like in Express:

return res.status(500).json({
    ok: false,
    error: err.message
});
You can see how similar they are!

Once the results have been stored, we can return it as JSON to the client:

ctx.JSON(fiber.Map{
    "ok":    true,
    "todos": todos,
})
So our controller looks like this:

// GetAllTodos - GET /api/todos
func GetAllTodos(ctx *fiber.Ctx) {
    collection := mgm.Coll(&models.Todo{})
    todos := []models.Todo{}

    err := collection.SimpleFind(&todos, bson.D{})
    if err != nil {
        ctx.Status(500).JSON(fiber.Map{
            "ok":    false,
            "error": err.Error(),
        })
        return
    }

    ctx.JSON(fiber.Map{
        "ok":    true,
        "todos": todos,
    })
}
GET todo by ID
Each MongoDB document has an automatically assigned, unique ID which we can use to fetch a specific document. Our route looks like this: /api/todos/:id, and thanks to Fiber, we can easily implement a controller for it:

// GetTodoByID - GET /api/todos/:id
func GetTodoByID(ctx *fiber.Ctx) {
    id := ctx.Params("id")

    todo := &models.Todo{}
    collection := mgm.Coll(todo)

    err := collection.FindByID(id, todo)
    if err != nil {
        ctx.Status(404).JSON(fiber.Map{
            "ok":    false,
            "error": "Todo not found.",
        })
        return
    }

    ctx.JSON(fiber.Map{
        "ok":   true,
        "todo": todo,
    })
}
It uses the ctx.Params() method to find the value of the :id parameter and searches in the collection using that ID. If it fails (i.e. doesn't find a document with that ID), it will return a JSON response telling you so, with a 404 HTTP status code.

POST todo to server
When POSTing stuff, there's one question that often crosses the mind of a web developer. How should I accept the incoming data? Using a form? A urlencoded body? JSON? Perhaps, raw text? Well, since we're talking about a REST API, the convention is to accept and send JSON data. Fiber makes it very easy to handle any kind of data however, depending on the Content-Type header:

application/json - parses the body as a JSON object
application/xml - parses an XML document
application/x-www-form-urlencoded - parses a urlencoded string in the body
multipart/form-data - parses a good old form
We want to create a new struct that contains the parameters we need to extract from the request's body. We only need the title and the description of the todo:

params := new(struct {
    Title       string
    Description string
})
This will be empty at first, so it will contain two empty strings. We can then use Fiber's ctx.BodyParser() method to parse the request's body and bind it to our params variable:

ctx.BodyParser(&params)
We can then check if both parameters were provided, and if any of them is missing, we can return an error with an HTTP status code of 400 (Bad Request):

if len(params.Title) == 0 || len(params.Description) == 0 {
    ctx.Status(400).JSON(fiber.Map{
        "ok":    false,
        "error": "Title or description not specified.",
    })
    return
}
Once that's done, we can create our todo using our helper function and then return it to the client:

todo := models.CreateTodo(params.Title, params.Description)
err := mgm.Coll(todo).Create(todo)
if err != nil {
    ctx.Status(500).JSON(fiber.Map{
        "ok":    false,
        "error": err.Error(),
    })
    return
}

ctx.JSON(fiber.Map{
    "ok":   true,
    "todo": todo,
})
Here's the controller in its entirety:

// CreateTodo - POST /api/todos
func CreateTodo(ctx *fiber.Ctx) {
    params := new(struct {
        Title       string
        Description string
    })

    ctx.BodyParser(&params)

    if len(params.Title) == 0 || len(params.Description) == 0 {
        ctx.Status(400).JSON(fiber.Map{
            "ok":    false,
            "error": "Title or description not specified.",
        })
        return
    }

    todo := models.CreateTodo(params.Title, params.Description)
    err := mgm.Coll(todo).Create(todo)
    if err != nil {
        ctx.Status(500).JSON(fiber.Map{
            "ok":    false,
            "error": err.Error(),
        })
        return
    }

    ctx.JSON(fiber.Map{
        "ok":   true,
        "todo": todo,
    })
}
PATCH a todo to change its status
The general idea behind the PATCH /api/todos/:id route is to get the todo by ID, change the value of the Done property to the opposite of the current value, save the document, and then return the modified document to the user.

You can pretty much copy and paste the contents of the GetTodoByID() controller and add this before the last step:

todo.Done = !todo.Done

err = collection.Update(todo)
if err != nil {
    ctx.Status(500).JSON(fiber.Map{
        "ok":    false,
        "error": err.Error(),
    })
    return
}
Here's the final controller:

// ToggleTodoStatus - PATCH /api/todos/:id
func ToggleTodoStatus(ctx *fiber.Ctx) {
    id := ctx.Params("id")

    todo := &models.Todo{}
    collection := mgm.Coll(todo)

    err := collection.FindByID(id, todo)
    if err != nil {
        ctx.Status(404).JSON(fiber.Map{
            "ok":    false,
            "error": "Todo not found.",
        })
        return
    }

    todo.Done = !todo.Done

    err = collection.Update(todo)
    if err != nil {
        ctx.Status(500).JSON(fiber.Map{
            "ok":    false,
            "error": err.Error(),
        })
        return
    }

    ctx.JSON(fiber.Map{
        "ok":   true,
        "todo": todo,
    })
}
DELETE a todo
The DELETE /api/todos/:id controller is also very similar, I don't think it needs any special explanation:

// DeleteTodo - DELETE /api/todos/:id
func DeleteTodo(ctx *fiber.Ctx) {
    id := ctx.Params("id")

    todo := &models.Todo{}
    collection := mgm.Coll(todo)

    err := collection.FindByID(id, todo)
    if err != nil {
        ctx.Status(404).JSON(fiber.Map{
            "ok":    false,
            "error": "Todo not found.",
        })
        return
    }

    err = collection.Delete(todo)
    if err != nil {
        ctx.Status(500).JSON(fiber.Map{
            "ok":    false,
            "error": err.Error(),
        })
        return
    }

    ctx.JSON(fiber.Map{
        "ok":   true,
        "todo": todo,
    })
}
And so, our controllers are done! We can move forward to the final step.

The Server
Like I said earlier, server.go will initialize the MongoDB driver and the MGM ODM, define the routes of the app, and start the server. First, let's define the package and its imports:

package main

import (
    "log"
    "os"

    "github.com/Kamva/mgm/v2"
    "github.com/gofiber/fiber"
    "github.com/jozsefsallai/fiber-todo-demo/controllers"
    "go.mongodb.org/mongo-driver/mongo/options"
)
Now we need to define an init() function in which we configure the MongoDB driver. This function will ever only be called once and will run before main(), so we can have all our stuff ready here.

func init() {
    connectionString := os.Getenv("MONGODB_CONNECTION_STRING")
    if len(connectionString) == 0 {
        connectionString = "mongodb://localhost:27017"
    }

    err := mgm.SetDefaultConfig(nil, "todos", options.Client().ApplyURI(connectionString))
    if err != nil {
        log.Fatal(err)
    }
}
We are going to use the MONGODB_CONNECTION_STRING environment variable to specify the connection string used to connect to the MongoDB server and database. If there is no such environment variable, it will default to the local instance of MongoDB.

Since we've already imported all of our controllers, we can just refer to them when defining our routes in the main() function:

func main() {
    app := fiber.New()

    app.Get("/api/todos", controllers.GetAllTodos)
    app.Get("/api/todos/:id", controllers.GetTodoByID)
    app.Post("/api/todos", controllers.CreateTodo)
    app.Patch("/api/todos/:id", controllers.ToggleTodoStatus)
    app.Delete("/api/todos/:id", controllers.DeleteTodo)

    app.Listen(3000)
}
Easy as that! As you can see from this example as well, Fiber really does look like Express, which is a nice touch! By now you should be ready to start your application. Run the following command:

go run server.go
And your server should be listening on port 3000.


[Source](https://dev.to/jozsefsallai/creating-fast-apis-in-go-using-fiber-59m9)