# アプリ概要
Sinatraを利用したメモアプリになります
# 著者の環境

- Bundler：2.4.1
- Ruby：3.2.0
- macOS Big Sur  バージョン11.2.3

# 実行手順

## 1. PostgreSQLの準備(MacOS)
```
brew install postgresql

brew services start postgresql

psql postgres

postgres=# create database mydb;

postgres=# \q

psql mydb

mydb=# create table memos(id serial primary key, title varchar(255), content text);

mydb=# insert into memos (title, content) values ('勉強をする','30分でもいいので');


```
## 2. Sinatraプログラムの準備
```
git clone https://github.com/syo-tokeshi/SinatraApp/tree/develop

cd SinatraApp

bundle install

bundle exec ruby app.rb
```

2. ブラウザから以下のURLにアクセスします  
http://localhost:4567