# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'debug'

def memos_divided_per_column
  memos = File.open('asset/memos.txt', 'r') do |f|
    f.read.split("\n")
  end
  memos.map do |a|
    a.split(',')
  end
end

def search_for_memos_by_id(params_id)
  memos = memos_divided_per_column
  memos.each do |memo|
    return memo if memo[0].to_i == params_id
  end
end

def remake_memos_add_number(memos_with_added_id)
  File.open('asset/memos.txt', 'w') do |text|
    memos_with_added_id.each do |memo|
      text.puts("#{memo[0]},#{memo[1]},#{memo[2]}")
    end
  end
end

def add_id_to_memos
  memos = memos_divided_per_column
  memos[-1].unshift(memos[-2][0].to_i + 1) if memos.count > 1
  memos[-1].unshift(1) if memos.count == 1
  remake_memos_add_number(memos)
end

def write_memos(title, content)
  File.open('asset/memos.txt', 'a') do |file|
    file.puts("#{title},#{content}")
  end
end

def read_memos
  memos = File.open('asset/memos.txt', 'r') do |f|
    f.read.split("\n")
  end
  memos.map do |a|
    a.split(',')
  end
end

def overwrite_file_with_memos(memos)
  File.open('asset/memos.txt', 'w') do |file|
    memos.each do |memo|
      file.puts("#{memo[0]},#{memo[1]},#{memo[2]}")
    end
  end
end

def update_memos(id, title, content)
  memos = read_memos
  edited_memo = memos.each do |memo|
    break memo if memo[0].to_i == id
  end
  edited_memo[1..2] = title, content

  overwrite_file_with_memos(memos)
end

def memo_specified_by_id(params_id)
  # put_key_for_displayメソッドに渡す値は配列でなければならない。なので一時的な配列を追加した
  display_plain_memo = [search_for_memos_by_id(params_id)] << ["tmp"]
  # 最初の要素のメモだけ渡す
  put_key_for_display(display_plain_memo).first
end

def put_key_for_display(plain_memos)
  keys = %i(id title content)
  plain_memos.map do |memo|
    keys.zip(memo).to_h
  end
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  plain_memos = read_memos
  @memos = put_key_for_display(plain_memos)
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  title = params[:title]
  content = params[:content]
  write_memos(title, content)
  add_id_to_memos
  redirect '/memos'
end

get '/memos/:id' do
  params_id = params[:id].to_i
  @memo = memo_specified_by_id(params_id)
  erb :show
end

get '/memos/:id/edit' do
  params_id = params[:id].to_i
  @memo = memo_specified_by_id(params_id)
  erb :edit
end

patch '/memos/:id' do
  @id = params[:id].to_i
  @title = params[:title]
  @content = params[:content]
  update_memos(@id, @title, @content)
  redirect '/memos'
end

delete '/memos/:id' do
  id = params[:id].to_i
  memos = read_memos

  memos.each do |memo|
    memos.delete(memo) if memo[0].to_i == id
  end

  overwrite_file_with_memos(memos)
  redirect '/memos'
end
