# frozen_string_literal: true
module Wefix
    # Service object to create a new group for an owner

    class CreateGroupForOwner
        def self.call(owner_id:, group_data:)
            Account.find(id: owner_id).add_owned_group(group_data)
        end
    end
end
