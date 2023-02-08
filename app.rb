require 'sinatra'
require 'sinatra/reloader'
require 'debug'

def remake_memos_add_number(memos_with_added_id)
  File.open("asset/memos.txt","w") do |text|
    memos_with_added_id.each { |memo|
      text.puts("#{memo[0]},#{memo[1]},#{memo[2]}")
    }
  end
end

def add_id_to_memos
  memos = File.open("asset/memos.txt", "r") do |f|
    f.read.split("\n")
  end
  @memos_divided_per_column = memos.map{ |a|
    a.split(",")
  }
  @memos_divided_per_column[-1].unshift(@memos_divided_per_column[-2][0].to_i + 1) if @memos_divided_per_column.count > 1
  @memos_divided_per_column[-1].unshift(1) if @memos_divided_per_column.count == 1
  remake_memos_add_number(@memos_divided_per_column)
end

def write_memos(title,content)
  File.open("asset/memos.txt","a") do |text|
    text.puts("#{title},#{content}")
  end
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  memos = File.open("asset/memos.txt", "r") do |f|
    f.read.split("\n")
  end
  @memos_divided_per_column = memos.map{ |a|
    a.split(",")
  }
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  @title = params[:title]
  @content = params[:content]
  write_memos(@title,@content)
  add_id_to_memos
  redirect '/memos'
end

get '/memos/:id' do
  erb :show
end

get '/memos/:id/edit' do
  erb :edit
end

patch '/memos/:id' do
  redirect "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  redirect '/memos'
end
