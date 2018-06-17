# frozen_string_literal: true

module Wefix
  # Add a collaborator to another owner's existing group
  class AddCollaboratorToGroup
    def self.call(email:, group_id:)
      collaborator = Account.first(email: email)
      group = Group.first(id: group_id)
      return false if group.owner.id == collaborator.id
      group.add_collaborator(collaborator)
      collaborator
    end
  end
end
