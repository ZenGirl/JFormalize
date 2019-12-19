# frozen_string_literal: true

module JFormalize
  module Interactors
    # Simply parses JSON into a set of raw objects
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
