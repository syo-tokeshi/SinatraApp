require 'sinatra'
require 'sinatra/reloader'

def write_memos(title,content)
  File.open("asset/memos.txt","a") do |text|
    text.puts("#{title},#{content}")
  end
end

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
  @title = params[:title]
  @content = params[:content]
  logger.info @title
  logger.info @content
  write_memos(@title,@content)
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