require 'bundler'
Bundler.require
require 'yaml'
require 'json'
require 'digest/sha1'

set :bind, '0.0.0.0'
class Database
  def initialize(path)
    data_loaded = Dir[File.join(path, '*.yaml')].map do |yaml_path|
      hash = YAML.load_file(yaml_path)
      id = File.basename(yaml_path, '.yaml')
      hash.merge(id: id)
    end
    @data = data_loaded.sort_by do |entry|
      Digest::SHA1.digest(entry[:id])
    end
  end

  attr_reader :data
end

#module Rubyistokei
#  class Application < Sinatra::Application
    configure do
      set :protection, :except => :frame_options

      DATA_PATH = File.join(__dir__, 'data')
    end

    get '/' do
      haml :index
    end

    get '/css/screen.css' do
      scss :screen
    end

    get '/data.json' do
      content_type :json
      database = Database.new(DATA_PATH)
      JSON.dump(database.data)
    end

    # POST Form
    get '/new' do
      haml :new
    end

    # POST url, name, title, bio必須.
    post '/create' do
      data = 
      {
        'url' => params[:url]? params['url'].to_s : nil,
        'tokei' => {
          'top' => params[:top]? params[:top].to_s : '100',
          'left' => params[:left]? params[:left].to_s : '200',
          'color' => params[:color]? params[:color] : '#fefefe',
          'font' => params[:font].to_s
        },
        'name' => params[:name].to_s,
        'title' => params[:title].to_s,
        'bio'=> params[:bio].to_s,
        'taken_by' => params[:taken_by]? params[:taken_by] : 'somebody',
      }
      
      # 必須項目ないとエラー
      return 'error' unless data['url'] && data['name'] && data['title'] && data['bio']

      # nameでvalidation
      return 'already exists' if File.exists?("./data/#{data['name']}.yaml")

      # yaml書き込み
      File.open("./data/#{params[:name]}.yaml",'w'){|f|
        f.write YAML.dump(data)
      }
      return 'Completed image upload!!'
    end

#  end
#end
