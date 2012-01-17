SSL Endpoint Heroku CLI Plugin
==============================

A plugin for the Heroku command line interface to perform operations against an app's SSL endpoints. SSL endpoints are Heroku's new unified SSL solution for the Heroku platform.

Installation
------------

Install this plugin:

    $ heroku plugins:install https://github.com/heroku/heroku-certs.git

Activate the `ssl:endpoint` addon:

    $ heroku addons:add ssl:endpoint

Usage
-----

Your app must be configured with a domain that will be protected by the SSL certificate you'll be adding:

    $ heroku domains:add example.org

Now you're ready to create an SSL endpoint right after you've acquired a certificate:

    $ heroku certs:add example.org.crt example.org.key

Check that your certificate was added successfully:

    $ heroku certs

Tests
-----

Run the test suite using:

    $ bundle install
    $ rake spec
