Junla
=====

Junla is an anti-procrastination proxy.

<img src="http://i.imgur.com/0qhnn.png" />

Synopsis
--------

The concept is very simple: before browsing the Web you will be redirected to
a form allowing you to set up a timeout after which the session will be over.
When the form is sent, you will be redirected to the Web page you initially
wanted to open. And that is all, you can now freely use the Web... But only
during the fixed amount of time! No more endless procrastination.

Junla is a HTTP proxy. You can use HTTPS (via HTTP CONNECT Tunneling) but
there is no timeout for this protocol. This is a design choice, if an
encrypted communication is needed then you probably don't want to be
interrupted.


Installation
------------

Before building junla, the following software should be installed:

* [git](http://git-scm.com/)
* [node](http://nodejs.org/)
* [npm](http://npmjs.org/)
* [coffee](http://coffeescript.org/)

To download, build and install junla:

    $ git clone git://github.com/vinc/junla.git
    $ cd junla
    $ npm install --global


Usage
-----

To use junla, just do:

    $ junla

And configure your browser to use the proxy, for example:

    $ chromium --proxy-server="127.0.0.1:8888"

The form is accessible at any time by going to: [http://junla/](http://junla/)

See `junla -h` for advanced options.


License
-------

Copyright (C) 2012 Vincent Ollivier. Released under GNU GPL License v3.
