# coderdojowebstorage

Minimal app to upload/edit html and image files.

Developed to be used by CoderDojo Malmö to enable the kids to upload their own home page and show of their projects.

## Preparations

### If using osx

First, install the latest ruby using `rvm` according to these instructions:

https://rvm.io/

Then,

    brew install libmagic

### Create config

    cp config.example.yml config.yml

Replace values in `config.yml` with different values. Use for example [random.org](http://random.org/) for some random data.

## How to run

### Compile

    bundle install

### Start the server

    rackup

## Initial setup

### Register the first user

Browse to [http://localhost:9292/](http://localhost:9292/)

Register a user using the webapp.

### Make the first user admin

    irb
    > require './coderdojowebstorage'
    > u = User.first
    > u.auth_level = 10
    > u.save
