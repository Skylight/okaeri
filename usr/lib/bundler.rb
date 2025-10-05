ENV['BUNDLE_GEMFILE'] = File.realpath(File.join(__dir__, '..', '..', 'Gemfile'))

require 'bundler/setup'
require 'bundler'

Bundler.require(:default)