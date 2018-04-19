require 'roda'
require 'json'
require 'base64'

require_relative 'models/location'

module Project
  # Web controller for Credence API
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
          routing.on 'documents' do
            # POST api/v1/documents/[ID]
            routing.get String do |id|
                Location.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Document not found' }.to_json
            end

            # GET api/v1/documents
            routing.get do
              output = { document_ids: Location.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/documents
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_doc = Location.new(new_data)

              if new_doc.save
                response.status = 201
                { message: 'Document saved', id: new_doc.id }.to_json
              else
                routing.halt 400, { message: 'Could not save document' }.to_json
              end
            end
          end
        end
      end
    end
  end
end