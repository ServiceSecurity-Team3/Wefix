# frozen_string_literal: true

require 'roda'

module Wefix
  # Web controller for Wefix API
  class Api < Roda
    route('problems') do |routing|
      @doc_route = "#{@api_root}/problems"

      routing.get(String) do |prb_id|
        account = Account.first(username: @auth_account['username'])
        problem = Problem.where(id: prb_id).first
        policy = ProblemPolicy.new(account, problem)
        raise unless policy.can_view?

        doc ? problem.to_json : raise
      rescue StandardError
        routing.halt 404, { message: 'Problem not found' }.to_json
      end
    end
  end
end
