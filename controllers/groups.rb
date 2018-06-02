# frozen_string_literal: true

require 'roda'

module Wefix
  # Web controller for Wefix API
  class Api < Roda
    route('groups') do |routing|
      @grp_route = "#{@api_root}/groups"

      routing.on String do |grp_id|
        routing.on 'problems' do
          @prb_route = "#{@api_root}/groups/#{grp_id}/problems"
          # GET api/v1/groups/[grp_id]/problems/[prb_id]
          routing.get String do |prb_id|
            prob = Problem.where(group_id: grp_id, id: prb_id).first
            prob ? prob.to_json : raise('Problem not found')
          rescue StandardError => error
            routing.halt 404, { message: error.message }.to_json
          end

          # GET api/v1/groups/[grp_id]/problems
          routing.get do
            output = Group.first(id: grp_id).problems
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, message: 'Could not find problems'
          end

          # POST api/v1/groups/[ID]/problems
          routing.post do
            new_data = JSON.parse(routing.body.read)

            new_prob = CreateProblemForGroup.call(
              group_id: grp_id, problem_data: new_data
            )

            response.status = 201
            response['Location'] = "#{@prb_route}/#{new_prob.id}"
            { message: 'Problem saved', data: new_prob }.to_json
          rescue Sequel::MassAssignmentRestriction
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError
            routing.halt 500, { message: 'Database error' }.to_json
          end
        end

        # GET api/v1/groups/[ID]
        routing.get do
          grp = Group.first(id: grp_id)
          grp ? grp.to_json : raise('Group not found')
        rescue StandardError => error
          routing.halt 404, { message: error.message }.to_json
        end
      end

      # GET api/v1/groups
      routing.get do
        output = Group.all
        JSON.pretty_generate(output)
      rescue StandardError
        routing.halt 404, { message: 'Could not find projects' }.to_json
      end

      # POST api/v1/groups
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_grp = Group.new(new_data)
        raise('Could not save Group') unless new_grp.save

        response.status = 201
        response['Location'] = "#{@grp_route}/#{new_grp.id}"
        { message: 'Group saved', data: new_grp }.to_json
      rescue Sequel::MassAssignmentRestriction
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError => error
        routing.halt 500, { message: error.message }.to_json
      end
    end
  end
end
