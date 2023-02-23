# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'cgi'
require 'csv'
require 'pg'

before do
  @connected_db ||= PG.connect(dbname: 'mydb')
end

helpers do
  def escape(memo)
    CGI.escapeHTML(memo)
  end
end

def find(params_id)
  memo = @connected_db.exec_params('SELECT * FROM memos WHERE id = $1;', [params_id])
  memo[0]
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @memos = @connected_db.exec('SELECT * FROM memos ORDER BY id DESC')
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  title = params[:title]
  content = params[:content]
  @connected_db.exec_params('INSERT INTO memos(title, content) VALUES ($1, $2);', [title, content])
  redirect '/memos'
end

get '/memos/:id' do
  @memo = find(params[:id].to_i)
  erb :show
end

get '/memos/:id/edit' do
  @memo = find(params[:id].to_i)
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
