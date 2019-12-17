# frozen_string_literal: true
require 'simplecov'
SimpleCov.start

require 'awesome_print'

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'j_formalize'

require 'minitest/autorun'

