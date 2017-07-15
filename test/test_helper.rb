ENV['RAILS_ENV'] = 'test'
require_relative './custom_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
# require "minitest/rails"
require 'database_cleaner'
require 'maxitest/autorun'
require 'mocha/mini_test'

module AroundEach
  def before_setup
    super
    DatabaseCleaner.start
  end

  def after_teardown
    DatabaseCleaner.clean
    # $redis.db.keys.each {|key| $redis.db.del(key) if key.include?($redis_key_prefix) }
    $redis.db.flushdb
    super
  end

  def stub_user
    @admin ||= create(:admin)
    ApplicationController.any_instance.stubs(:current_user).returns(@admin)
  end
end

DatabaseCleaner.strategy = :transaction

class Minitest::Test
  include FactoryGirl::Syntax::Methods
  include AroundEach
  include CustomHelper
end

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!
end

# # Only use it when need it
require 'simplecov'
# SimpleCov.start
