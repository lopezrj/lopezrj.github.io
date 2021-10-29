---
layout: post
title:  "Building a Simple CRUD app with Node, Express, and MongoDB"
date:   2022-08-28 21:51:27
categories: express node mongodb
tags: [crud express]
---

[Source:](https://zellwk.com/blog/crud-express-mongodb/)

# Building a Simple CRUD app with Node, Express, and MongoDB
9th apr 2020
I finally understood how to work with Node, Express, and MongoDB. I want to write a comprehensive tutorial so you won’t have to go through the same headache I went through.
CRUD, Express and MongoDB
CRUD, Express and MongoDB are big words for a person who has never touched any server-side programming in their life. Let’s quickly introduce what they are before we diving into the tutorial.
Express is a framework for building web applications on top of Node.js. It simplifies the server creation process that is already available in Node. In case you were wondering, Node allows you to use JavaScript as your server-side language.
MongoDB is a database. This is the place where you store information for your websites (or applications).
CRUD is an acronym for Create, Read, Update and Delete. It is a set of operations we get servers to execute (POST, GET, PUT and DELETE requests respectively). This is what each operation does:
Create (POST) - Make something
Read (GET)- Get something
Update (PUT) - Change something
Delete (DELETE)- Remove something
POST, GET, PUT, and DELETE requests let us construct Rest APIs.
If we put CRUD, Express and MongoDB together into a single diagram, this is what it would look like:

Does CRUD, Express and MongoDB makes more sense to you now?
Great. Let’s move on.