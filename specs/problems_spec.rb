# frozen_string_literal: true
  
require_relative './spec_helper'

describe 'Test Problem Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:groups].each do |group_data|
      Wefix::Group.create(group_data)
    end
  end

  it 'HAPPY: should be able to get list of all problems' do
    grp = Wefix::Group.first
    DATA[:problems].each do |prob|
      grp.add_problem(prob)
    end

    get "api/v1/groups/#{grp.id}/problems"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 3
  end

  it 'HAPPY: should be able to get details of a single problem' do
    prob_data = DATA[:problems][1]
    grp = Wefix::Group.first
    prob = grp.add_problem(prob_data).save

    get "/api/v1/groups/#{grp.id}/problems/#{prob.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal prob.id
    _(result['data']['attributes']['description']).must_equal prob_data['description']
  end

  it 'SAD: should return error if unknown problem requested' do
    grp = Wefix::Group.first
    get "/api/v1/groups/#{grp.id}/problems/foobar"

    _(last_response.status).must_equal 404
  end




  it 'HAPPY: should be able to create new problems' do
    grp = Wefix::Group.first
    prob_data = DATA[:problems][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "api/v1/groups/#{grp.id}/problems",
    prob_data.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    prob = Wefix::Problem.first

    _(created['id']).must_equal prob.id
    _(created['description']).must_equal prob_data['description']
    _(created['latitude']).must_equal prob_data['latitude']
    _(created['longitude']).must_equal prob_data['longitude']
    _(created['date']).must_equal prob_data['date']
  end

    it 'BAD: should not create problems with illegal attributes' do 
      bad_data = @prob_data.clone 
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/groups/#{grp.id}/problems",
          bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
     end
  end
end
