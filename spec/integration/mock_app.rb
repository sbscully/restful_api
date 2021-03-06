require 'sinatra/base'
require 'redis'

require_relative '../../lib/sinatra/restful_api'
require_relative '../../lib/virtual_properties'
require_relative '../support/mock_model'
require_relative '../support/mock_model_restful_api'

class Resource < MockModel
  include SuperModel::Redis::Model
  include VirtualProperties

  has_many :nested_resources

  attributes  :name
  indexes     :name

  virtual_properties :name_with_id

  def self.recent(offset=nil, limit=nil)
    all.last(5)
  end

  def friend
    self.class.last
  end

  def name_with_id
    "#{id}|#{name}"
  end
end

class NestedResource < MockModel
  include SuperModel::Redis::Model

  belongs_to :resource

  attributes  :name, :resource_id
  indexes     :name, :resource_id
end

class App < Sinatra::Base
  register Sinatra::RestfulApi

  set :environment, :production
  set :restful_api_adapter, MockModelRestfulApi

  restful_api :resources do
    member      { get :friend }
    collection  { get :recent }
  end

  not_found do
    "404: NOT FOUND"
  end

  error do
    error = env['sinatra.error']
    "#{error.message}\n#{error.backtrace.join("\n")}"
  end

  # start the server if ruby file executed directly
  # allows for manual testing
  run! if app_file == $0
end