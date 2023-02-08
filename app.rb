require 'sinatra'
require 'sinatra/reloader'
require 'debug'
require 'cgi'

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
  File.open("asset/memos.txt","a") do |file|
    file.puts("#{title},#{content}")
  end
end

def read_memos
  memos = File.open("asset/memos.txt", "r") do |f|
    f.read.split("\n")
  end
  memos.map{ |a|
    a.split(",")
  }
end

def overwrite_file_with_memos(memos)
  File.open("asset/memos.txt","w") do |file|
    memos.each { |memo|
      file.puts("#{memo[0]},#{memo[1]},#{memo[2]}")
    }
  end
end

def update_memos(id,title,content)
  memos = read_memos
  edited_memo = memos.each do |memo|
    break memo if memo[0].to_i == id
  end
  edited_memo[1..2] = title,content

  # 編集されたメモを、既存のmemosオブジェクトに反映させる
  fix_memos = File.open("asset/memos.txt","r") do |file|
     memos.each do |memo|
      if memo[0].to_i == id
        memo[1..2] = edited_memo[1..2]
      end
    end
  end

  # 編集されたメモで、memos.txtファイルを上書きする
  overwrite_file_with_memos(memos)
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
  @title = CGI.escapeHTML(params[:title])
  @content = CGI.escapeHTML(params[:content])
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
  params_id = params[:id].to_i
  @memo = search_for_memos_by_id(params_id)
  erb :edit
end

patch '/memos/:id' do
  @id = params[:id].to_i
  @title = CGI.escapeHTML(params[:title])
  @content = CGI.escapeHTML(params[:content])
  update_memos(@id,@title,@content)
  redirect '/memos'
end

delete '/memos/:id' do
  id = params[:id].to_i
  memos = read_memos

  memos.each do |memo|
    if memo[0].to_i == id
      memos.delete(memo)
    end
  end

  overwrite_file_with_memos(memos)
  redirect '/memos'
end
