# frozen_string_literal: true

require "roda"

module Wefix
  # Web controller for Wefix API
  class Api < Roda
    route("groups") do |routing|
      @grp_route = "#{@api_root}/groups"

      routing.on String do |grp_id|

        # POST api/v1/groups/[grp_id]/problems
        routing.post "problems" do
          account = Account.first(username: @auth_account["username"])
          prb_data = JSON.parse(routing.body.read)

          new_prb = Wefix::CreateProblemForGroup.call(
            group_id: grp_id, problem_data: prb_data,
          )

          raise("Could not save problem") unless new_prb.save
          response.status = 201
          response["Location"] = "#{@grp_route}/#{grp_id}/problems/#{new_prb.id}"
          {message: "Problem saved", data: new_prb}.to_json
        rescue Sequel::MassAssignmentRestriction
          routing.halt 400, {message: "Illegal Request"}.to_json
        rescue StandardError => error
          routing.halt 500, {message: error.message}.to_json
        end

        # POST api/v1/groups/[grp_id]/add_collabotors
        routing.post "add_collaborator" do
          data = JSON.parse(routing.body.read)
          add_collaborator = Wefix::AddCollaboratorToGroup.call(
            email: data["email"], group_id: grp_id,
          )
          raise("Could not add the collaborator") unless add_collaborator.save
          response.status = 200
          response["Location"] = "#{@grp_route}/#{grp_id}"
          {message: "Collaborator added"}.to_json
        rescue Sequel::MassAssignmentRestriction
          routing.halt 400, {message: "Illegal Request"}.to_json
        rescue StandardError => error
          routing.halt 500, {message: error.message}.to_json
        end

        # GET api/v1/groups/[grp_id]
        routing.get do
          account = Account.first(username: @auth_account["username"])
          group = Group.first(id: grp_id)
          policy = GroupPolicy.new(account, group)
          raise unless policy.can_view?

          group.full_details
               .merge(policies: policy.summary)
               .to_json
        rescue StandardError
          routing.halt 404, {message: "Group not found"}.to_json
        end
      end

      # GET api/v1/groups
      routing.get do
        account = Account.first(username: @auth_account["username"])
        groups_scope = GroupPolicy::AccountScope.new(account)
        viewable_groups = groups_scope.viewable

        JSON.pretty_generate(viewable_groups)
      rescue StandardError
        routing.halt 403, {message: "Could not find groups"}.to_json
      end

      # POST api/v1/groups
      routing.post do
        account = Account.first(username: @auth_account["username"])
        group_data = JSON.parse(routing.body.read)
        new_group = Wefix::CreateGroupForOwner.call(
          owner_id: account.id, group_data: group_data,
        )
        raise("Could not save group") unless new_group.save

        response.status = 201
        response["Location"] = "#{@grp_route}/#{new_group.id}"
        {message: "Group saved", data: new_group}.to_json
      rescue Sequel::MassAssignmentRestriction
        routing.halt 400, {message: "Illegal Request"}.to_json
      rescue StandardError => error
        routing.halt 500, {message: error.message}.to_json
      end
    end
  end
end
