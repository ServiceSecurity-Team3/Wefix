# frozen_string_literal: true

# Policy to determine if account can view a problem
class ProblemPolicy
  def initialize(account, problem)
    @account = account
    @problem = problem
  end

  def can_view?
    account_owns_group? || account_collaborates_on_group?
  end

  def can_edit?
    account_owns_group? || account_collaborates_on_group?
  end

  def can_delete?
    account_owns_group? || account_collaborates_on_group?
  end

  def summary
    {
      can_view:   can_view?,
      can_edit:   can_edit?,
      can_delete: can_delete?
    }
  end

  private

  def account_owns_group?
    @document.group.owner == @account
  end

  def account_collaborates_on_group?
    @document.group.collaborators.include?(@account)
  end
end
