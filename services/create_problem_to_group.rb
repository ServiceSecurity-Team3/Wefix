# frozen_string_literal: true

module Wefix
  # Create new problem for a group
  class CreateProblemForGroup
    def self.call(group_id:, problem_data:)
      Group.first(id: group_id).add_problem(problem_data)
    end
  end
end
