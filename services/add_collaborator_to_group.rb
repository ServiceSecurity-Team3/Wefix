# frozen_string_literal: true

module Wefix
  # Add a collaborator to another owner's existing group
  class AddCollaboratorToGroup
    def self.call(email:, group_id:)
      collaborator = Account.first(email: email)
      group = Group(id: group_id)
      return false if group_id.owner.id == collaborator.id
      group_id.add_collaborator
      collaborator
    end
  end
end