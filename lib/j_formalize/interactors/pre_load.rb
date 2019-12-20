# frozen_string_literal: true

module JFormalize
  module Interactors
    # Simply verifies that incoming context is valid.
    # Checks max size, json_string and schema.
    class PreLoad
      include JFormalize::Interactor

      def call
        max_size_must_be_reasonable

        json_must_be_string
        json_must_not_be_empty
        json_must_not_be_too_big
        json_must_be_utf8
        json_must_match_regex

        schema_must_be_hash
        schema_value_must_be_hash
        schema_value_must_have_type
        schema_type_must_be_valid
      end

      private

      def max_size_must_be_reasonable
        context.max_size = 100_000 if context.max_size.nil?
        context.fail!(message: err(:max_size_invalid)) if context.max_size < 100 || context.max_size > 10_000_000
      end

      def json_must_be_string
        context.fail!(message: err(:json_not_string)) unless context.json_string.is_a?(String)
      end

      def json_must_not_be_empty
        context.fail!(message: err(:json_is_empty)) if context.json_string.strip.length <= 0
      end

      def json_must_not_be_too_big
        context.fail!(message: err(:json_too_long)) if context.json_string.strip.length > context.max_size
      end

      def json_must_be_utf8
        context.fail!(message: err(:json_not_utf8)) if context.json_string.encoding.name != 'UTF-8'
      end

      # rubocop:disable Layout/SpaceInsideBlockBraces, Style/SymbolProc
      def json_must_match_regex
        match_json = context.json_string.gsub(/^#{context.json_string.scan(/^(?!\n)\s*/).min_by {|l| l.length}}/u, '')
        result     = match_json.match(JFormalize::Constants::JSON_REGEX)
        context.fail!(message: err(:json_invalid)) if result.nil?
      end
      # rubocop:enable Layout/SpaceInsideBlockBraces, Style/SymbolProc

      def schema_must_be_hash
        context.fail!(message: err(:schema_not_hash)) unless context.schema.is_a?(Hash)
      end

      def schema_value_must_be_hash
        context.schema.each do |_, value|
          context.fail!(message: err(:schema_value_must_have_type)) unless value.is_a?(Hash)
        end
      end

      def schema_value_must_have_type
        context.schema.each do |_, value|
          context.fail!(message: err(:schema_value_must_have_type)) unless value.key?(:type)
        end
      end

      def schema_type_must_be_valid
        valid_types = JFormalize::Constants::METHOD_TABLE.keys
        context.schema.each do |_, value|
          context.fail!(message: err(:schema_type_must_be_valid)) unless valid_types.include?(value[:type])
        end
      end

      def err(key)
        JFormalize::Constants::MESSAGES[key]
      end
    end
  end
end
