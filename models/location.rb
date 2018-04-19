# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

module Project
  # Location model
  class Location
    STORE_DIR = 'db/'.freeze

    # Create a new location data by passing in hash of data
    def initialize(new_file)
      @id = new_file['id'] || new_id
      @username = new_file['username']
      @latitude = new_file['latitude']
      @longitude = new_file['longitude']
      @date = new_file['date']
      @description = encode_content(new_file['description'])
    end

    attr_reader :id, :username, :latitude, :longitude, :date

    def description
      decode_content(@content)
    end

    def save
      File.open(STORE_DIR + id + '.txt', 'w') do |file|
        file.write(to_json)
      true
      rescue StandardError
        false
      end
    end

    def to_json(options = {})
      JSON({ type: 'location',
             username: @username,
             latitude: @latitude,
             longitude: @longitude,
             date: @date,
             description: description }, options)
    end

    def self.setup
      Dir.mkdir(STORE_DIR) unless Dir.exist? STORE_DIR
    end

    def self.find(find_id)
      document_file = File.read(STORE_DIR + find_id + '.txt')
      Location.new JSON.parse(document_file)
    end

    def self.all
      Dir.glob(STORE_DIR + '*.txt').map do |filename|
        filename.match(/#{Regexp.quote(STORE_DIR)}(.*)\.txt/)[1]
      end
    end

    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end

    def encode_content(content)
      Base64.strict_encode64(content)
    end

    def decode_content(encoded_content)
      Base64.strict_decode64(encoded_content)
    end
  end
end
