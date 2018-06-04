# frozen_string_literal: true

module Wefix
  # Policy to determine if an account can view a particular group
  class GroupPolicy
    def initialize(account, group)
      @account = account
      @group = group
    end

    def can_view?
      account_is_owner? || account_is_collaborator?
    end

    # duplication is ok!
    def can_edit?
      account_is_owner? || account_is_collaborator?
    end

    def can_delete?
      account_is_owner?
    end

    def can_leave?
      account_is_collaborator?
    end

    def can_add_problems?
      account_is_owner? || account_is_collaborator?
    end

    def can_remove_problems?
      account_is_owner? || account_is_collaborator?
    end

    def can_add_collaborators?
      account_is_owner?
    end

    def can_remove_collaborators?
      account_is_owner?
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_leave: can_leave?,
        can_add_problems: can_add_problems?,
        can_remove_problems: can_remove_problems?,
        can_add_collaborators: can_add_collaborators?,
        can_remove_collaborators: can_remove_collaborators?
      }
    end

    private

    def account_is_owner?
      @group.owner == @account
    end

    def account_is_collaborator?
      @group.collaborators.include?(@account)
    end
  end
end
