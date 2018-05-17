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
    _(result.count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single group' do
    group_data = DATA[:groups][1]
    Wefix::Group.create(group_data).save
    id = Wefix::Group.first.id

    get "/api/v1/groups/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['id']).must_equal id
    _(result['name']).must_equal group_data['name']
  end

  it 'SAD: should return error if unknown group requested' do
    get '/api/v1/groups/foobar'
    _(last_response.status).must_equal 404
  end

  describe 'Creating New Groups' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @group_data = DATA[:groups][1]
    end

    it 'HAPPY: should be able to create new groups' do
      post 'api/v1/groups', @group_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']
      grp = Wefix::Group.first

      _(created['id']).must_equal grp.id
      _(created['name']).must_equal @group_data['name']
      _(created['description']).must_equal @group_data['description']
    end

    it 'BAD: should not create groups with illegal attributes' do
      bad_data = @group_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/groups', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
