# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'debug'
require 'cgi'
require 'csv'

helpers do
  def escape_html(memo)
    CGI.escapeHTML(memo)
  end
end

def search_for_memos_by_id(params_id)
  memos = memos_divided_per_column
  selected_memo = memos.select do |memo|
    memo[0].to_i == params_id
  end
  selected_memo.flatten
end

def write_memos(title, content)
  CSV.open('asset/memos.csv', 'a') do |file|
    file << [title, content]
  end
end

def read_memos
  CSV.read("asset/memos.csv")
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
  display_plain_memo = [search_for_memos_by_id(params_id)] << ['tmp']
  # 最初の要素のメモだけ渡す
  put_key_for_display(display_plain_memo).first
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

  memos.delete_if do |memo|
    memo[0].to_i == id
  end

  overwrite_file_with_memos(memos)
  redirect '/memos'
end
