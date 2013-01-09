# coderdojowebstorage

Minimal app to upload/edit html and image files.

Developed to be used by CoderDojo Malmö to enable the kids to upload their own home page and show of their projects.

## How to run

### Compile

    bundle install

### Start the server

    rackup

## Initial setup

## Make first user admin

    irb
    > require './coderdojowebstorage'
    > u = User.first
    > u.auth_level = 10
    > u.save
