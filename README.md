# Cocina [![Build Status](https://travis-ci.org/brandocorp/cocina.svg?branch=master)](https://travis-ci.org/brandocorp/cocina)

A thin wrapper around Test Kitchen allowing you to define dependencies for your
suites

## Usage

Assuming you have a `.kitchen.yml` which looks like the following

```yaml
---
driver:
  name: vagrant

provisioner:
  name: chef_zero

platforms:
  - name: ubuntu-14.04
  - name: centos-7.1

suites:
  - name: app
    run_list:
    attributes:

  - name: web
    run_list:
    attributes:
```

In the root directory of your cookbook, along side your `.kitchen.yml` add a
`Cochinafile`.

```ruby
instance 'web-ubuntu-1404' do
  depends 'db-ubuntu-1404'
  depends 'app-ubuntu-1404'
end
```

This tells Cochina that the `web` suite depends on the `app` suite. Now, wen you
run `cochina web-ubuntu-1404` it will first converge `db-ubuntu-1404`, followed
by `app-ubuntu-1404`, before continuing with `web-ubuntu-1404`.

By default the target instance is sent the `:verify` action, and each dependency
is sent the `:converge` action.

After all instances have finished running, each instance is destroyed.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cocina'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cocina

## Development

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/brandocorp/cocina.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
