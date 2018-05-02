# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative 'init'

module Wefix
  # Models a secret Problem
  class Problem < Sequel::Model
    many_to_one :group

    plugin :timestamps

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'problem',
            attributes: {
              id: id,
              description: description,
              latitude: latitude,
              longitude: longitude,
              date: date,
            }
          },
          included: {
            group: group,
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end