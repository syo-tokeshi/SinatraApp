# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'cgi'
require 'csv'
require 'pg'

before do
  @connected_db = PG.connect(dbname: 'mydb')
end

helpers do
  def escape(memo)
    CGI.escapeHTML(memo)
  end
end

def write_memos(title, content)
  @connected_db.exec_params('INSERT INTO memos(title, content) VALUES ($1, $2);', [title, content])
end

def read_memos
  @connected_db.exec('SELECT * FROM memos')
end

def memo_specified_by_id(params_id)
  @connected_db.exec_params('SELECT * FROM memos WHERE id = $1;', [params_id])
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
  @memo = memo_specified_by_id(params[:id].to_i)[0]
  erb :edit
end

patch '/memos/:id' do
  id = params[:id].to_i
  title = params[:title]
  content = params[:content]
  @connected_db.exec_params('UPDATE memos SET title = $1, content = $2 WHERE id = $3;', [title, content, id])
  redirect '/memos'
end

delete '/memos/:id' do
  params_id = params[:id].to_i
  @connected_db.exec_params('DELETE FROM memos WHERE id = $1;', [params_id])
  redirect '/memos'
end
