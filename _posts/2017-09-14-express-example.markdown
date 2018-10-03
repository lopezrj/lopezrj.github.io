---
layout: post
title:  "ExpressJS Example"
date:   2017-09-14 22:21:27
categories: javascript programming
tags: javascript express
---

## 5. Example of a books catalog

### Create server

To generate app exbooks:

{% highlight javascript %}
express-generator --pug -s stylus -v pug --git exbooks
{% endhighlight %}

This creates a file structure as this:

{% highlight bash %}
exbook
|-- app.js
|-- bin
|-- package.json
|-- public
|-- routes
`-- views
{% endhighlight %}

{% highlight bash %}
cd <appname>
git init   // if version control is needed
npm install  // install modules
npm install --save bookshelf knex sqlite3  //A dd sqlite3 database support
DEBUG=exbooks:* nodemon  // start application in debug ode
{% endhighlight %}

In `app.js` add:
{% highlight javascript %}
var booksRouter = require('./routes/books');  // at line 10
app.use('/books', booksRouter);               // at line 27
{% endhighlight %}

To get collection of books in json format. Create `./routes/books.js` and add:
{% highlight javascript %}
var express = require('express');
var Book = require('../models/book');
var router = express.Router();

/* GET Books. */
router.route('/')
  .get(function(req, res) {
    Book
      .fetchAll()
      .then(function(books) {
        res.json({ books });
      });
  });

module.exports = router;
{% endhighlight %}

Create folder `./models` and file `./models/book.js` and write:
{% highlight javascript %}
'use strict';
var bookshelf = require('../data/bookshelf');
var Book = bookshelf.Model.extend({
  tableName: 'books',
});
module.exports = Book;
{% endhighlight %}

Create folder `./data` and file `./data/bookshelf.js` and write:
{% highlight javascript %}
'use strict';
var knex = require('knex')(require('./knexfile'));
var bookshelf = require('bookshelf')(knex);
module.exports = bookshelf;
{% endhighlight %}

Create file `./data/knexfile.js` and write:
{% highlight javascript %}
'use strict';
module.exports = {
  client: 'sqlite3',
  connection: {
    filename: './data/books.sqlite3',
  },
  useNullAsDefault: true,
};
{% endhighlight %}

To create the database file, you can use migrations: Create folder `./migrations` and file `./migrations/books.js` and write:
{% highlight javascript %}
'use strict';
exports.up = function(knex) {
  return knex.schema
    .createTable('books', function(table) {
      table.increments('id').primary();
      table.string('title');
      table.string('author');
      table.string('isbn');
      table.string('publication_date');
      table.string('acquired_date');
      table.string('tags');
    });
};
exports.down = function(knex) {
  return knex.schema
    .dropTable('books');
};
{% endhighlight %}

Then add to package.json the following script:
{% highlight json %}
...
"scripts": {
  ... ,
  "migrate": "knex migrate:latest"
},
...
{% endhighlight %}

Now you can run `npm run migrate` to create the database file.

To create a query of the table, add to `.\routes\books.js`

{% highlight javascript %}
...
router.route('/')
  .get(function(req, res) {
    Book
      .where(req.query)    // Add this one line
      .fetchAll()
      .then(function(books) {
        res.json({ books });
      });
  })
  ...
...
{% endhighlight %}

With the simple addition of a where() function/clause we can now send GET requests like http://127.0.0.1:3000/book?id=1 and it will only return records that match the query.

To parse parameters like:

http://127.0.0.1:3000/title/Linux


{% highlight javascript %}
router.route('/title/:title')
  .get(function(req, res) {  
    Book
      .where('title', 'like' , '%'+req.params.title + '%')   // this looks if title contains parameter title
      .fetchAll()
      .then(function(books) {
        res.json({ books });
    });
});

{% endhighlight %}

##### Create frontend in express

Instead of responding with a JSON structure. Express can render template files in `./views` directory.

To render the template `./views/books.pug` change .get(function) as follows:

{% highlight javascript %}
...
router.route('/')
  .get(function(req, res) {
    Book
      .where(req.query) 
      .fetchAll()
      .then(function(books) {
        // render ./views/books.pug file with JSON collection books
        res.render({books, books.toJSON()});  // add this line
      });
  })
  ...
...
{% endhighlight %}

