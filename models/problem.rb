# frozen_string_literal: true

require 'json'
require 'sequel'
require_relative 'init'

module Wefix
  # Models a secret Problem
  class Problem < Sequel::Model
    many_to_one :group

    plugin :uuid, field: :id

    plugin :whitelist_security
    set_allowed_columns :description, :latitude, :longitude, :date

    plugin :timestamps, update_on_create: true

    def latitude
      SecureDB.decrypt(latitude_secure)
    end

    def latitude=(decimal)
      self.latitude_secure = SecureDB.encrypt(decimal)
    end

    def longitude
      SecureDB.decrypt(longitude_secure)
    end

    def longitude=(decimal)
      self.longitude_secure = SecureDB.encrypt(decimal)
    end

    def to_json(options = {})
      JSON(
        {
          type: problem
          id: id,
          description: description,
          latitude: latitude,
          longitude: longitude,
          date: date,
          group: group
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
