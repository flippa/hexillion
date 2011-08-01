Hexillion API Client Gem for Ruby
=================================

This gem provides a basic Ruby wrapper for the [Hexillion Whois API](http://hexillion.com/whois/). 
It was developed for use on [Flippa.com](http://flippa.com/) and is largely based
on the [Quova gem](http://github.com/d11wtq/quova/) by Chris Corbyn.

Installation
------------

`gem install hexillion`

Usage
-----

The core class is Hexillion::Client. Create a new instance, passing in your Hexillion API 
username and password:

`hex = Hexillion::Client.new(:username => 'MYUSERNAME', :password => 'MYPASSWORD')`

Then, use the `whois` method on the instance to query Whois records for a given domain:

`hex.whois('example.com')`

The return value is a hash with all the Whois data returned by the API.