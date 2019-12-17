# frozen_string_literal: true

module JFormalize
  # Main runner
  class Runner
    attr_reader :file_name, :schema, :max_size

    def initialize(file_name, max_size = 100_000, schema = {})
      @file_name = file_name
      @max_size  = max_size
      @schema    = schema
    end

    def run
      JFormalize::Engine.new(@file_name, @max_size, @schema).run
    end
  end
end
