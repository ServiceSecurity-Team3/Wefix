# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative 'init'
module Wefix
  # Models a Group
  class Group < Sequel::Model
    many_to_one :owner, class: :'Wefix::Account'

    many_to_many :collaborators,
                 class: :'Credence::Account',
                 join_table: :accounts_groups,
                 left_key: :group_id, right_key: :collaborator_id

    one_to_many :problems
    plugin :association_dependencies
    add_association_dependencies documents: :problems, collaborators: :nullify

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :name, :description

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'group',
          id: id,
          name: name,
          description: description
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
