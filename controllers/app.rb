# frozen_string_literal: true

require 'roda'
require 'json'

# require_relative 'lib/init'
# require_relative 'config/environments'
# require_relative 'models/init'

module Wefix
  # Web controller for Wefix API
  class Api < Roda
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'Wefix API up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          @api_root = 'api/v1'

          routing.on 'groups' do
            @proj_route = "#{@api_root}/groups"

            routing.on String do |group_id|
              routing.on 'problems' do
                @doc_route = "#{@api_root}/groups/#{group_id}/problems"
                # GET api/v1/groups/[group_id]/problems/[pro_id]
                routing.get String do |pro_id|
                  pro = Problem.where(group_id: group_id, id: pro_id).first
                  pro ? pro.to_json : raise('Problem not found')
                rescue StandardError => error
                  routing.halt 404, { message: error.message }.to_json
                end

                # GET api/v1/groups/[group_id]/problems
                routing.get do
                  output = { data: Group.first(id: group_id).problems }
                  JSON.pretty_generate(output)
                rescue StandardError
                  routing.halt 404, message: 'Could not find problems'
                end

                # POST api/v1/groups/[ID]/problems
                routing.post do
                  new_data = JSON.parse(routing.body.read)
                  group = Group.first(id: group_id)
                  new_doc = group.add_problem(new_data)

                  if new_doc
                    response.status = 201
                    response['Location'] = "#{@doc_route}/#{new_doc.id}"
                    { message: 'Problem saved', data: new_doc }.to_json
                  else
                    routing.halt 400, 'Could not save the problem'
                  end

                rescue Sequel::MassAssignmentRestriction
                  routing.halt 400, { message: 'Illegal Request' }.to_json
                rescue StandardError
                  routing.halt 500, { message: 'Database error' }.to_json
                end
              end

              # GET api/v1/groups/[ID]
              routing.get do
                group = Group.first(id: group_id)
                group ? group.to_json : raise('Group not found')
              rescue StandardError => error
                routing.halt 404, { message: error.message }.to_json
              end
            end

            # GET api/v1/groups
            routing.get do
              output = { data: Group.all }
              JSON.pretty_generate(output)
            rescue StandardError
              routing.halt 404, { message: 'Could not find groups' }.to_json
            end

            # POST api/v1/groups
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_group = Group.new(new_data)
              raise('Could not save the group') unless new_group.save

              response.status = 201
              response['Location'] = "#{@proj_route}/#{new_group.id}"
              { message: 'Group saved', data: new_group }.to_json
            rescue Sequel::MassAssignmentRestriction
              routing.halt 400, { message: 'Illegal Request' }.to_json
            rescue StandardError => error
              routing.halt 400, { message: error.message }.to_json
            end
          end
        end
      end
    end
  end
end
