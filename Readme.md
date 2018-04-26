# Wefix API
API to store and retrieve problem location

## Routes
All routes return Json

- GET /: Root route shows if Web API is running
- GET api/v1/location/: returns all locations IDs
- GET api/v1/location/[ID]: returns details about a single location with given ID
- POST api/v1/location/: creates a new location 

## Install
Install this API by cloning the relevant branch and installing required gems from Gemfile.lock:

<pre>
bundle install
</pre>

## Test
Run the test script:
<pre>
ruby spec/location_api_spec.rb
</pre>

## Execute
Run this API using:
<pre>
rackup
</pre>

## Assests
## Logo

<p align="center">
  <<a href="https://ibb.co/keXa1x"><img src="https://preview.ibb.co/mLq68c/Logo.png" alt="Logo" border="0"></a>
  
</p>