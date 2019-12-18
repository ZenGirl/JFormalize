# frozen_string_literal: true

require 'ostruct'

module JFormalize
  # Cut down version of Interactor code
  #
  # See https://github.com/collectiveidea/interactor for full codebase
  # I **LOVE** this gem, and Collective Idea have some great gems.
  # Show them some love at https://collectiveidea.com/
  #
  # Normally I would simply include the complete gem, but I'm avoiding
  # having any external run time dependencies.
  # As such, I messed about pulling some code in but not others.
  # Tests exist for this.
  #
  # Note that I've had to use rubocop directives so that the original
  # code is as close to Collective Ideas code.
  # Apologies.
  #
  # rubocop:disable Style/CaseEquality, Layout/SpaceInsideBlockBraces, Style/Documentation
  module Interactor
    class Failure < StandardError
      attr_reader :context

      def initialize(context = nil)
        @context = context
        super
      end
    end

    class Context < OpenStruct
      def self.build(context = {})
        self === context ? context : new(context)
      end

      def success?
        !failure?
      end

      def failure?
        @failure || false
      end

      def fail!(context = {})
        context.each {|key, value| modifiable[key.to_sym] = value}
        @failure = true
        raise Failure, self
      end

      def fail(context = {})
        context.each {|key, value| modifiable[key.to_sym] = value}
        @failure = true
        self
      end
    end

    def self.included(base)
      base.class_eval do
        extend ClassMethods

        attr_reader :context
      end
    end

    module ClassMethods
      def call(context = {})
        new(context).tap(&:run).context
      end

      def call!(context = {})
        new(context).tap(&:run!).context
      end
    end

    def initialize(context = {})
      @context = Context.build(context)
    end

    # rubocop:disable Lint/HandleExceptions
    def run
      run!
    rescue Failure
      # Swallows exceptions
    end

    # rubocop:enable Lint/HandleExceptions

    # rubocop:disable Style/RescueStandardError
    def run!
      call
    rescue
      raise
    end

    # rubocop:enable Style/RescueStandardError

    module Organizer
      def self.included(base)
        base.class_eval do
          include Interactor

          extend ClassMethods
          include InstanceMethods
        end
      end

      module ClassMethods
        def organize(*interactors)
          @organized = interactors.flatten
        end

        def organized
          @organized ||= []
        end
      end
      module InstanceMethods
        def call
          self.class.organized.each do |interactor|
            interactor.call!(context)
          end
        end
      end
    end
  end
  # rubocop:enable Style/CaseEquality, Layout/SpaceInsideBlockBraces, Style/Documentation
end
