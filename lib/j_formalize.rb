# frozen_string_literal: true

module JFormalize
  # Main engine organizer
  class Engine
    include JFormalize::Interactor::Organizer

    organize JFormalize::Interactors::PreLoad,
             JFormalize::Interactors::Objectify,
             JFormalize::Interactors::Formalize
  end
end
