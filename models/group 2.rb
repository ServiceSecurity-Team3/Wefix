# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative 'init'

module Wefix
  # Models a Group
  class Group < Sequel::Model
    one_to_many :problems
    plugin :association_dependencies, problems: :destroy

    plugin :timestamps

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'group',
            attributes: {
              id: id,
              name: name,
              description: description,
            }
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end