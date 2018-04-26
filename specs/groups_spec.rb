# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Group Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all groups' do
    Wefix::Group.create(DATA[:groups][0]).save
    Wefix::Group.create(DATA[:groups][1]).save

    get 'api/v1/groups'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single group' do
    existing_grp = DATA[:groups][1]
    Wefix::Group.create(existing_grp).save
    id = Wefix::Group.first.id

    get "/api/v1/groups/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal id
    _(result['data']['attributes']['name']).must_equal existing_grp['name']
  end

  it 'SAD: should return error if unknown group requested' do
    get '/api/v1/groups/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new groups' do
    existing_grp = DATA[:groups][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/groups', existing_grp.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    grp = Wefix::Group.first

    _(created['id']).must_equal grp.id
    _(created['name']).must_equal existing_grp['name']
    _(created['description']).must_equal existing_grp['description']
  end
end