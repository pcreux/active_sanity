# Generate some test models

BASE_MODEL_CLASS = Rails.version >= "5." ? "ApplicationRecord" : "ActiveRecord::Base"

# Post
generate :model, 'post title:string body:text published_at:datetime author_id:integer category_id:integer'
post_code = <<-CODE
  belongs_to :author, :class_name => 'User'
  belongs_to :category
  accepts_nested_attributes_for :author

  validates :author, :category, :title, :published_at, presence: true
CODE
inject_into_file 'app/models/post.rb', post_code, after: "class Post < #{BASE_MODEL_CLASS}\n"

# Category
generate :model, 'category name:string description:text'
category_code = <<-CODE
  has_many :posts

  validates :name, presence: true
CODE
inject_into_file 'app/models/category.rb', category_code, after: "class Category < #{BASE_MODEL_CLASS}\n"

# User
generate :model, 'user first_name:string last_name:string username:string type:string'
user_code = <<-CODE
  has_many :posts, :foreign_key => 'author_id'

  validates :first_name, :last_name, :username, presence: true
  validates :username, length: { minimum: 3 }
CODE
inject_into_file 'app/models/user.rb', user_code, after: "class User < #{BASE_MODEL_CLASS}\n"

# Author < User
create_file 'app/models/author.rb', 'class Author < User; end'
# Publisher < User
create_file 'app/models/publisher.rb', 'class Publisher < User; end'

# NotAModel
create_file 'app/models/not_a_model.rb', 'class NotAModel; end'

# Add active_sanity
append_file 'Gemfile', "gem 'active_sanity', :path => '../../'"

# Configure for custom batch_size
custom_batch_size_code = <<-CODE
  config.after_initialize do
    ActiveSanity::Checker.batch_size = 439
  end
CODE

inject_into_file 'config/application.rb', custom_batch_size_code, after: " < Rails::Application\n"

run 'bundle'
rake 'db:drop db:create db:migrate'
