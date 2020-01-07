# frozen_string_literal: true

require 'j_formalize/constants'
require 'j_formalize/interactors/common_context'
require 'j_formalize/interactors/pre_load'
require 'j_formalize/interactors/objectify'
require 'j_formalize/interactors/formalize'
require 'j_formalize'

module JFormalize
  # Main engine organizer
  class Engine
    include JFormalize::Interactor::Organizer

    organize JFormalize::Interactors::PreLoad,
             JFormalize::Interactors::Objectify,
             JFormalize::Interactors::Formalize
  end
end
