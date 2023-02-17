# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'cgi'
require 'csv'
require 'pg'
require 'debug'

before do
  @connected_db = PG::connect(dbname: "mydb")
end

helpers do
  def escape(memo)
    CGI.escapeHTML(memo)
  end
end

def search_for_memos_by_id(params_id)
  memos = read_memos
  # 受け取るidは1からはじまるため、-1するとindex検索が上手くいく
  memos[params_id - 1]
end

def write_memos(title, content)
  @connected_db.exec_params('INSERT INTO memos(title, content) VALUES ($1, $2);', [title, content])
end

def read_memos
  @connected_db.exec("SELECT * FROM memos" )
end

def overwrite_file_with_memos(memos)
  File.open('asset/memos.csv', 'w') do |file|
    memos.each do |memo|
      file.puts(memo.join(','))
    end
  end
end

def update_memos(id, title, content)
  memos = read_memos
  memos[id - 1] = title, content
  overwrite_file_with_memos(memos)
end

def memo_specified_by_id(params_id)
  @connected_db.exec_params('SELECT * FROM memos WHERE id = $1;', [params_id])
end

def put_key_for_display(plain_memos)
  keys = %i[title content]
  plain_memos.map do |memo|
    keys.zip(memo).to_h
  end
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @memos = read_memos
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  title = params[:title]
  content = params[:content]
  write_memos(title, content)
  redirect '/memos'
end

get '/memos/:id' do
  @memo = memo_specified_by_id(params[:id].to_i)[0]
  erb :show
end

get '/memos/:id/edit' do
  @params_id, @memo = memo_specified_by_id(params[:id].to_i)
  erb :edit
end

patch '/memos/:id' do
  id = params[:id].to_i
  title = params[:title]
  content = params[:content]
  update_memos(id, title, content)
  redirect '/memos'
end

delete '/memos/:id' do
  params_id = params[:id].to_i
  memos = read_memos
  # 受け取るidは1からはじまるため、-1するとindex検索が上手くいく
  memos.delete_at(params_id - 1)
  overwrite_file_with_memos(memos)
  redirect '/memos'
end
