# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:problems) do
      primary_key :id
      foreign_key :group_id, table: :groups

      String :description, null: false
      String :latitude, null: false
      String :longitude, null: false
      String :date, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end