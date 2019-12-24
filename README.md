# ActiveRecordBitmask

Transparent manipulation of bitmask attributes for ActiveRecord

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_record_bitmask'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_record_bitmask

## Usage

Simply declare an existing integer column as a bitmask.

```
class ApplicationRecord < ActiveRecord::Base
  include ActiveRecordBitmask::BitmaskAccessor
end

class Post < ApplicationRecord
  bitmask :roles, as: [:administrator, :provider, :guest]
end
```

You can then modify the column using the declared values.

```
post = Post.create(roles: [:provider, :guest])
post.roles # => [:provider, :guest]
post.roles += [:administrator]
post.roles # => [:administrator, :provider, :guest]
```

### What the difference between `active_record_bitmask` and [bitmask](https://github.com/joelmoss/bitmask)?

#### 1. `bitmask` is no longer supported.

`active_record_bitmask` is supported latest Rails.

#### 2. `bitmask` executes slow query

```
# bitmask executes slow query
Post.with_roles(:provider).to_sql
#=> SELECT `variations`.* FROM `variations` WHERE (variations.permitted & 2 > 0)

# active_record_bitmask executes fast query
Post.with_roles(:provider).to_sql
#=> SELECT "posts".* FROM "posts" WHERE "posts"."bitmask" IN (2, 3, 6, 7)
```

#### 3. `bitmask` is complex

`active_record_bitmask` is supported only minimum interfaces.
Also, you need to include `ActiveRecordBitmask::BitmaskAccessor` manually.

### Scopes

#### `with_#{attribute_name}` Filter by bitmask attributes

```
# The following scope matches [:administrator], [:administrator, :provider], [:administrator, :guest] or [:administrator, :provider, :guest]
Post.with_roles(:administrator).to_sql
#=> SELECT "posts".* FROM "posts" WHERE "posts"."bitmask" IN (1, 3, 5, 7)

# The following scope matches [:administrator, :provider] or [:administrator, :provider, :guest]
Post.with_roles(:administrator, :provider).to_sql
#=> SELECT "posts".* FROM "posts" WHERE "posts"."bitmask" IN (3, 7)
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rake` to run the tests. 

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alpaca-tc/active_record_bitmask.
