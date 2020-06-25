# Active Sanity

[![Build Status](https://circleci.com/gh/pcreux/active_sanity.svg?style=svg)](https://circleci.com/gh/pcreux/active_sanity)

Perform a sanity check on your database through active record
validation.

## Requirements

* ActiveSanity ~0.5 requires Rails ~5.0 or ~6.0
* ActiveSanity ~0.3 and ~0.4 requires Rails ~4.0
* ActiveSanity ~0.2 requires Rails ~3.1
* ActiveSanity ~0.1 requires Rails ~3.0

## Install

Add the following line to your Gemfile

    gem 'active_sanity'

If you wish to store invalid records in your database run:

    $ bin/rails generate active_sanity
    $ bin/rails db:migrate

## Usage

Just run:

    bin/rails db:check_sanity

ActiveSanity will iterate over every records of all your models to check
whether they're valid or not. It will save invalid records in the table
invalid_records if it exists and output all invalid records.

The output might look like the following:

    model       | id  | errors
    User        |   1 | { "email" => ["is invalid"] }
    Flight      | 123 | { "arrival_time" => ["can't be nil"], "departure_time" => ["is invalid"] }
    Flight      | 323 | { "arrival_time" => ["can't be nil"] }

By default, the number of records fetched from the database for validation is set to 500. If this causes any issues in your domain/codebase, you can configure it this way in `config\application.rb` (or `config\environments\test.rb`):

    class Application < Rails::Application
      config.after_initialize do
        ActiveSanity::Checker.batch_size = 439
      end
    end

If you want to ignore certain models from being verified, you can create a file named `active_sanity.ignore.yml` at the root of your project with the following structure

    models:
      - '<name of class to ignore>'
      - '<name of class to ignore>'


## Contribute & Dev environment

Usual fork & pull request.

This gem is quite simple so I experiment using features only. To run the
acceptance test suite, just run:

    bundle install
    RAILS_ENV=test bundle exec cucumber features

Using features only was kinda handsome until I had to deal with two
different database schema (with / without the table invalid_records) in
the same test suite. I guess that the same complexity would arise using
any other testing framework.
