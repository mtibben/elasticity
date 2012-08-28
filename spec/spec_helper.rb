require 'rubygems'
require 'bundler/setup'
require 'elasticity'

require 'timecop'

ENV['RAILS_ENV'] ||= 'test'

Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each { |f| require f }
