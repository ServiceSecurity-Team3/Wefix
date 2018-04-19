# frozen_string_literal: true

require 'roda'
require 'json'
require 'base64'

require_relative 'models/location'

module Project
  # Web controller for Location API
  class Api < Roda
    plugin :environments
    plugin :halt

    configure do
      Location.setup
    end

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'Location up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'locations' do
            routing.get String do |id|
              Location.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Location not found' }.to_json
            end

            # GET api/v1/locations
            routing.get do
              output = { location_ids: Location.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/locations
            routing.post do
              data = JSON.parse(routing.body.read)
              location = Location.new(data)
              if location.save
                response.status = 201
                { message: 'Location saved', id: location.id }.to_json
              else
                routing.halt 400, { message: 'Could not save Location' }.to_json
              end
            rescue StandardError
              routing.halt 400, { message: 'Error: Invalid request' }.to_json
            end
          end
        end
      end
    end
  end
end
