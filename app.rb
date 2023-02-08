require 'sinatra'
require 'sinatra/reloader'
require 'debug'

def memos_divided_per_column
  memos = File.open("asset/memos.txt", "r") do |f|
    f.read.split("\n")
  end
  memos.map{ |a|
    a.split(",")
  }
end

def search_for_memos_by_id(params_id)
  memos = memos_divided_per_column
  memos.each do |memo|
    return memo if memo[0].to_i == params_id
  end
end

def remake_memos_add_number(memos_with_added_id)
  File.open("asset/memos.txt","w") do |text|
    memos_with_added_id.each { |memo|
      text.puts("#{memo[0]},#{memo[1]},#{memo[2]}")
    }
  end
end

def add_id_to_memos
  memos = memos_divided_per_column
  memos[-1].unshift(memos[-2][0].to_i + 1) if memos.count > 1
  memos[-1].unshift(1) if memos.count == 1
  remake_memos_add_number(memos)
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
  params_id = params[:id].to_i
  @memo = search_for_memos_by_id(params_id)
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
