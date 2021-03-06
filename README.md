# Hexillion API Client Gem for Ruby

[![Build Status](https://travis-ci.org/flippa/hexillion.svg?branch=master)](https://travis-ci.org/flippa/hexillion)

This gem provides a basic Ruby wrapper for the
[Hexillion Whois API](http://hexillion.com/whois/).
It is largely based on the [Quova gem](http://github.com/d11wtq/quova/) by Chris Corbyn.

## Installation

    gem install hexillion

## Usage

The core class is `Hexillion::Client`. Create a new instance, passing in your Hexillion API
username and password:

    hex = Hexillion::Client.new(:username => 'MYUSERNAME', :password => 'MYPASSWORD')

Then, use the `whois` method on the instance to query Whois records for a given domain:

    hex.whois('example.com')

The return value is a hash with all the Whois data returned by the API.

## Resources

  - [Source](https://github.com/flippa/hexillion)
  - [Issues](https://github.com/flippa/hexillion/issues)

## Disclaimer

The official maintainer of this Gem, Flippa.com is no way affiliated with, nor
representative of Hexillion.  This code is provided free of charge and shall be used
at your own risk.

Copyright (c) 2011 Flippa.com Pty. Ltd.
