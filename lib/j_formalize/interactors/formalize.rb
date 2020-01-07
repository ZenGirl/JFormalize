# frozen_string_literal: true

module JFormalize
  module Interactors
    # Formalize
    # Iterates over objects adding missing keys and ignoring unknown key/value pairs
    class Formalize
      include JFormalize::Interactor

      # rubocop:disable Metrics/AbcSize
      def call
        context.formalized_objects = []
        context.raw_objects.each do |obj|
          formalized = iterate_pairs(obj)
          context.fail!(message: context.errors.join("\n")) if context.errors.count.positive?
          context.formalized_objects << formalized
        end
      end
      # rubocop:enable Metrics/AbcSize

      private

      # rubocop:disable Metrics/AbcSize
      def iterate_pairs(object)
        context.errors = []
        formal         = {}
        context.schema.each_pair do |key, props|
          value             = object.key?(key) ? object[key] : props[:default]
          method_type       = props[:type]
          validation_method = JFormalize::Constants::METHOD_TABLE[method_type]
          result            = send(validation_method, key, value)
          if result
            formal[key] = value
          else
            context.errors << "key [#{key}] value [#{value}] is not a valid #{method_type}"
          end
        end
        formal
      end
      # rubocop:enable Metrics/AbcSize

      def must_be_string(_, value)
        value.is_a?(String)
      end

      def must_be_guid(_, value)
        !value.to_s.match(JFormalize::Constants::GUID_RE).nil?
      end

      def must_be_integer(_, value)
        value.is_a?(Integer)
      end

      def must_be_url(_, value)
        value.to_s.match(JFormalize::Constants::URL_RE)
      end

      def must_be_datetime(_, value)
        Time.parse(value.to_s)
      rescue ArgumentError
        nil
      end

      def must_be_boolean(_, value)
        # !! is the quickest way to handling nils as false
        # rubocop:disable Style/DoubleNegation
        !!value == value
        # rubocop:enable Style/DoubleNegation
      end

      def must_be_locale(_, value)
        value.is_a?(String)
      end

      def must_be_timezone(_, value)
        value.is_a?(String)
      end

      def must_be_email(_, value)
        !value.to_s.match(JFormalize::Constants::EMAIL_RE).nil?
      end

      def must_be_regex(key, value)
        !value.to_s.match(context.schema[key][:match]).nil?
      end

      def must_be_array(key, value)
        success = value.is_a?(Array)
        subtype = context.schema[key][:subtype]
        if success && subtype
          value.each do |val|
            err_msg = "key [#{key}] array value [#{val}] is not a #{subtype}"
            subtype_case(err_msg, subtype, val)
            success = false if context.errors.size.positive?
          end

        end
        success
      end

      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      def subtype_case(err_msg, subtype, val)
        context.errors ||= []
        case subtype
        when :string
          context.errors << err_msg unless must_be_string(nil, val)
        when :guid
          context.errors << err_msg unless must_be_guid(nil, val)
        when :integer
          context.errors << err_msg unless must_be_integer(nil, val)
        when :url
          context.errors << err_msg unless must_be_url(nil, val)
        when :datetime
          context.errors << err_msg unless must_be_datetime(nil, val)
        when :boolean
          context.errors << err_msg unless must_be_boolean(nil, val)
        when :locale
          context.errors << err_msg unless must_be_locale(nil, val)
        when :timezone
          context.errors << err_msg unless must_be_timezone(nil, val)
        when :email
          context.errors << err_msg unless must_be_email(nil, val)
        else
          context.errors << "subtype [#{subtype}] is not supported"
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    end
  end
end
