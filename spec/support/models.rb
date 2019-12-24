# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.integer :bitmask
  end

  create_table :variations, force: true do |t|
    t.integer :bitmask
    t.string :type
  end
end

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class Post < ApplicationRecord; end

class Variation < ApplicationRecord; end

class SubVariation < Variation; end
