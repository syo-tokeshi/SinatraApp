require 'sinatra'
require 'sinatra/reloader'

get '/' do
  redirect '/memos'
end

get '/memos' do
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  redirect '/memos'
end

get '/memos/:id' do
  erb :show
end

patch '/memos/:id' do
  redirect "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  redirect '/memos'
end

get '/memos/:id/edit' do
  erb :edit
end