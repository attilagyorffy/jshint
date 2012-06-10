# JSHint on Rails

**JSHint on Rails** is a Ruby library which lets you run the [JSHint JavaScript code checker](https://jshint.com) on your Javascript code easily.
It was originally forked from the [JSLint on Rails](http://github.com/psionides/jslint_on_rails) package.
It can be installed either as a gem (the recommended method), or as a Rails plugin (legacy method).

Note: to run JSHint on Rails, you need to have **Java** available on your machine - it's required because JSHint is
itself written in JavaScript, and is run using the [Rhino](http://www.mozilla.org/rhino) JavaScript engine (written in
Java). Any decent version of Java will do (and by decent I mean 5.0 or later).


## Compatibility

Latest version should be compatible with Ruby 1.9 and Rails 3 (and also with Ruby 1.8 and Rails 2, of course).
It has been tested on the following Ruby versions:

* ruby 1.8.7 (2010-01-10 patchlevel 249)
* ruby 1.9.2p180 (2011-02-18 revision 30909)

## Installation (as gem)

The recommended installation method (for Rails and for other frameworks) is to install JSHint on Rails as a gem. The
advantage is that it's easier to update the library to newer versions later, and you keep its code separate from your
own code.

To use JSHint as a gem in Rails 3, you just need to do one thing:

* add `gem 'jshint'` to bundler's Gemfile

And that's it. On first run, JSHint on Rails will create an example config file for you in config/jshint.yml, which
you can then tweak to suit your app.

In Rails 2 and in other frameworks JSHint on Rails can't be loaded automatically using a Railtie, so you have to do a
bit more work. The procedure in this case is:

* install the gem in your application using whatever technique is recommended for your framework (e.g. using bundler,
or by installing the gem manually with `gem install jshint` and loading it with `require 'jshint'`)
* in your Rakefile, add a line to load the JSHint tasks:

        require 'jshint/tasks'

* below that line, set JSHint's config_path variable to point it to a place where you want your JSHint configuration
file to be kept - for example:

        JSHint.config_path = "config/jshint.yml"
    
* run a rake task which will generate a sample config file for you:

        rake jshint:copy_config


## Installation (as Rails plugin)

Installing libraries as Rails plugins was popular before Rails 3, but now gems with Railties can do everything that
plugins could do, so plugins are getting less and less popular. But if you want to install JSHint on Rails as a plugin
anyway, here's how you do it:

    ./script/plugin install git://github.com/liquid/jshint_on_rails.git

This will also create a sample `jshint.yml` config file for you in your config directory.


## Installation (custom)

If you wish to write your own rake task to run JSHint, you can create and execute the JSHint object manually:

    require 'jshint'
    
    lint = JSHint::Lint.new(
      :paths => ['public/javascripts/**/*.js'],
      :exclude_paths => ['public/javascripts/vendor/**/*.js'],
      :config_path => 'config/jshint.yml'
    )
    
    lint.run


## Configuration

Whatever method you use for installation, a YAML config file should be created for you. In this file, you can:

* define which Javascript files are checked by default; you'll almost certainly want to change that, because the default
is `public/javascripts/**/*.js` which means all Javascript files, and you probably don't want JSHint to check entire
jQuery, Prototype or whatever other vendored libraries you use - so change this so that only your scripts are checked (you can
put multiple entries under "paths:" and "exclude_paths:")
* tweak JSHint options to enable or disable specific checks - I've set the defaults to what I believe is reasonable,
but what's reasonable for me may not be reasonable for you


## Running

To start the check, run the rake task:

    [bundle exec] rake jshint

You will get a result like this (if everything goes well):

    Running JSHint:
    
    checking public/javascripts/Event.js... OK
    checking public/javascripts/Map.js... OK
    checking public/javascripts/Marker.js... OK
    checking public/javascripts/Reports.js... OK
    
    No JS errors found.

If anything is wrong, you will get something like this instead:

    Running JSHint:
    
    checking public/javascripts/Event.js... 2 errors:
    
    Lint at line 24 character 15: Use '===' to compare with 'null'.
    if (a == null && b == null) {
    
    Lint at line 72 character 6: Extra comma.
    },
    
    checking public/javascripts/Marker.js... 1 error:
    
    Lint at line 275 character 27: Missing radix parameter.
    var x = parseInt(mapX);
    
    
    Found 3 errors.
    rake aborted!
    JSHint test failed.

If you want to test specific file or files (just once, without modifying the config), you can pass paths to include
and/or paths to exclude to the rake task:

    rake jshint paths=public/javascripts/models/*.js,public/javascripts/lib/*.js exclude_paths=public/javascripts/lib/jquery.js

For the best effect, you should include JSLint check in your Continuous Integration build - that way, you'll get
immediate notification when you've committed JS code with errors.


## Additional options

I've added some additional options to JSHint to get rid of some warnings which I thought didn't make sense. They're all
disabled by default, but feel free to enable any or all of them if you feel abused by JSHint.

Here's a documentation for all the extra options:


### lastsemic

If set to true, this will ignore warnings about missing semicolon after a statement, if the statement is the last one in
a block or function, and the whole block is on the same line. I've added this because I like to omit the semicolon in
one-liner anonymous functions, in situations like this:

    var ids = $$('.entry').map(function(e) { return e.id });

Note: in versions up to 1.0.3, this option also disabled the warning in blocks that span multiple lines, but I've
changed that in 1.0.4, because removing a last semicolon in a multi-line block doesn't really affect the readability
(while removing the only semicolon in a one-liner like above does, IMHO).


### newstat

Allows you to use a call to 'new' as a whole statement, without assigning the result anywhere. Sometimes you want to
create an instance of a class, but you don't need to assign it anywhere - the call to constructor starts the action
automatically. This includes calls like `new Ajax.Request(...)` or `new Effect.Highlight(...)` used when working with
Prototype and Scriptaculous.


### statinexp

JSHint has a warning that says "Expected an assignment or function call and instead saw an expression" - you get it
when you write an expression and you don't use it for anything, like if you wrote such line:

    $$('.entry').length;

Just checking the length without assigning it anywhere or passing to any function doesn't make any sense, so it's good
that JSHint complains. However, there are some cases where the code makes perfect sense, but JSHint still thinks it
doesn't. Examples:

    element && element.show();  // call show only if element is not null
    selected ? element.show() : element.hide();  // more readable than if & else with brackets

So I've tweaked the code that creates this warning so that it doesn't print it if the code makes sense. Specifically:

* expressions joined with && or || are accepted if the last one in the line is a statement
* expressions with ?: are accepted if both alternatives (before and after the colon) are statements


## Credits

* The original JSLint on Rails package was created by [Jakub Suder](http://psionides.jogger.pl), licensed under MIT License
* JSHint is an open-source project that is supported and maintained by the [JavaScript developer community](https://github.com/jshint/jshint).
* JSLint was created by [Douglas Crockford](http://jslint.com)
