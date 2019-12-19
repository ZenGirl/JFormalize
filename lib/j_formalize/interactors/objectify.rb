# frozen_string_literal: true

module JFormalize
  module Interactors
    # Simply verifies that incoming context is valid.
    # Checks max size, json_string and schema.
    class Objectify
      include JFormalize::Interactor

      def call
        context.raw_objects = JSON.parse(context.json_string, symbolize_names: true)
      rescue JSON::JSONError => e
        context.fail!(message: "JSONError: #{e.message}: #{e.backtrace.join("\n")}")
      end
    end
  end
end
