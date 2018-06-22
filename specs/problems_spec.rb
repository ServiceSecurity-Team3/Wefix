# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Problem Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][1]
    Wefix::EmailAccount.create(@account_data)
    credentials = {
      username: @account_data['username'],
      password: @account_data['password']
    }
    auth_account = Wefix::AuthenticateEmailAccount.call(credentials).to_json
    @data_user = JSON.parse(auth_account)

    account = Wefix::Account.first(username: @account_data['username'])
    DATA[:groups].each do |group_data|
      Wefix::CreateGroupForOwner.call(
        owner_id: account.id, group_data: group_data
      )
    end
  end

  describe 'Getting Problem' do
    before do
      @grp = Wefix::Group.first
      DATA[:problems].each do |prob_data|
        Wefix::CreateProblemForGroup.call(
          group_id: @grp.id,
          problem_data: prob_data
        )
      end
    end

    it 'HAPPY: should be able to get list of all problems' do
      header 'AUTHORIZATION', "Bearer #{@data_user['auth_token']}"
      get "api/v1/groups/#{@grp.id}/problems"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)

      _(result['problems'].count).must_equal DATA[:problems].count
    end

    it 'HAPPY: should be able to get details of a single problem' do
      prob = Wefix::Problem.first

      header 'AUTHORIZATION', "Bearer #{@data_user['auth_token']}"
      get "/api/v1/groups/#{@grp.id}/problems/#{prob.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)

      _(result['problems'].first['id']).must_equal prob.id
    end

    it 'SAD: should return error if unknown problem requested' do
      group = Wefix::Group.first
      get "/api/v1/groups/#{group.id}/problems/foobar"

      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating problems' do
    before do
      @group = Wefix::Group.first
      @prob_data = DATA[:problems][1]
    end

    it 'HAPPY: should be able to create new problems' do
      header 'AUTHORIZATION', "Bearer #{@data_user['auth_token']}"
      post "api/v1/groups/#{@group.id}/problems",
           @prob_data.to_json

      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']
      prob = Wefix::Problem.first

      _(created['id']).must_equal prob.id
      _(created['description']).must_equal @prob_data['description']
      _(created['latitude']).must_equal @prob_data['latitude']
      _(created['longitude']).must_equal @prob_data['longitude']
    end

    it 'BAD: should not create problems with illegal attributes' do
      bad_data = @prob_data.clone
      bad_data['created_at'] = '1900-01-01'

      header 'AUTHORIZATION', "Bearer #{@data_user['auth_token']}"
      post "api/v1/groups/#{@group.id}/problems",
           bad_data.to_json

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
