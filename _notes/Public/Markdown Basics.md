---
title: Markdown Basics
feed: show
date: 01-07-2024
categories: markdown programming 
tags: [markdown]
---

{% highlight markdown %}
# A First Level Header

## A Second Level Header

Now is the time for all good men to come to
the aid of their country. This is just a
regular paragraph.

The quick brown fox jumped over the lazy
dog's back.

### Header 3
{% endhighlight %}


### Links

Inline-style links use parentheses immediately after the link text. For example:

{% highlight markdown %}
This is an [example link](http://example.com/).
{% endhighlight %}


Reference-style links allow you to refer to your links by names, which you define elsewhere in your document:

{% highlight markdown %}
I get 10 times more traffic from [Google][1] than from
[Yahoo][2] or [MSN][3].

[1]: http://google.com/        "Google"
[2]: http://search.yahoo.com/  "Yahoo Search"
[3]: http://search.msn.com/    "MSN Search"
{% endhighlight %}


### Code

To specify an entire block of pre-formatted code, indent every line of the block by 4 spaces or 1 tab. Just like with code spans, &, <, and > characters will be escaped automatically.

{% highlight markdown %}
    This is a blockquote.
     
    This is the second paragraph in the blockquote.
    
    ## This is an H2 in a blockquote
{% endhighlight %}


### Images
