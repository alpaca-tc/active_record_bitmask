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

```ruby
class Post < ApplicationRecord
  # bitmask attribute is integer column.
  # `t.integer :roles, null: false, default: 0`
  bitmask(roles: [:administrator, :provider, :guest])
end
```

You can then modify the column using the declared values.

```ruby
post = Post.create(roles: [:provider, :guest])
post.roles #=> [:provider, :guest]
post.roles += [:administrator]
post.roles #=> [:administrator, :provider, :guest]
```

You can check bitmask

```ruby
post = Post.create(roles: [:provider, :guest])
post.roles?(:provider) #=> false
post.roles?(:guest, :provider) #=> true
```

You can get the definition of bitmask

```ruby
map = Post.bitmask_for(:rules)
map.keys   #=> [:administrator, :provider, :guest]
map.values #=> [1, 2, 4]
```

### Scopes

Named scopes are defined when you call `.bitmask(attribute)`.

#### `.with_attribute`

```ruby
# all users with roles
User.with_roles

# all administrators
User.with_roles(:administrator)

# all users who are both administrator and partner
User.with_roles(:administrator, :partner)
```

#### `.with_any_attribute`

```ruby
# all users who are administrator or partner
User.with_any_roles(:administrator, :partner)
```

#### `.without_attribute`, `.no_attribute`

```ruby
# all users without role
User.without_roles
User.no_roles

# all users who are not administrator
User.without_roles(:administrator)
```

#### `.with_exact_attribute`

```ruby
# all users who are both administrator and partner and nothing else
User.with_exact_roles(:administrator, :partner)
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rake` to run the tests. 

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alpaca-tc/active_record_bitmask.
