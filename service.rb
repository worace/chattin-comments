require 'logger'
require 'active_record'
require 'sinatra/base'

require 'models/comment.rb'
require 'helpers'
require 'config'

class Service < Sinatra::Base
  helpers  Helpers

  configure do

    set :haml, { :ugly=>true }
    set :clean_trace, true
    Dir.mkdir('log') unless File.exist?('log')

    $logger = Logger.new('log/common.log','weekly')
    $logger.level = Logger::WARN

    # Spit stdout and stderr to a file during production
    # in case something goes wrong
    $stdout.reopen("log/output.log", "w")
    $stdout.sync = true
    $stderr.reopen($stdout)


    databases = YAML.load_file("config/database.yml")
    ActiveRecord::Base.establish_connection(databases[Config.env])

    ActiveRecord::Base.logger = Logger.new(STDOUT)
  end

  mime_type :json, "application/json"

  before do
    content_type :json
  end

  get '/comments/:id' do
    id = params[:id].to_i
    Comment.where(id: id).first.to_json
  end

  get '/comments/presentation/:id' do
    presentation_id = params[:id].to_i
    Comment.where(presentation_id: presentation_id).to_json
  end

  post '/comments/presentation/:id' do
    presentation_id = params[:id].to_i
    Comment.create!(json_body).to_json
  end
end
