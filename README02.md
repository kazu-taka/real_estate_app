# 目次
- [物件管理アプリ(1)](http://qiita.com/mohira/private/6471442a7585cfb911f0)
  - 基本のCRUD
  - バリデーション
  - パーシャル
  - 日本語化
  - リファクタリング
- [物件管理アプリ(2)](http://qiita.com/mohira/private/00c8046afa69cd3d6d48) ← イマココ
  - ページネーション(kaminari)
  - アソシエーション
  - ログイン機能(devise)
- [物件管理アプリ(3)](http://qiita.com/mohira/private/2ea0420c7108f0f6a78a)
  - コメントの追加と削除

## 目的
- `kaminari`によるページング機能実装
- Sellerモデルとのアソシエ―ション
- `devise`による認証/承認機能実装

# ページネーション
## 出発点: 現状のアプリの問題点
- 一覧画面においては全ての物件情報が表示されている
- 単純に見づらいうえに、
- また、毎回全ての物件情報を読み込まないといけないのでユーザーに負荷を翔ける

## 対策: ページネーションを実装
- 9件ごとにページを分割する

## `kaminari`の導入
- ページネーションを簡単に実装できるgem
- Gemfileに記述して`bundle install`
- **サーバーの再起動も行う**

```rb:Gemfile(デフォルトのコメントは削除しています)
source 'https://rubygems.org'

gem 'rails', '4.2.6'
gem 'sqlite3'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'

gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc

### ここから追加
gem 'kaminari'
### ここまで追加

group :development, :test do
  gem 'byebug'
  gem 'faker'
  gem 'forgery_ja'
end

group :development do
  gem 'web-console', '~> 2.0'

  gem 'spring'
end
```

```bash:
$ bundle install
$ gem list # インストール済みのgemを確認できる
```

## コントローラ開発
- indexアクションを修正
- これで9件表示になる

```rb:app/controllers/houses_controller.rb(indexアクション以外は省略)
class HousesController < ApplicationController
  def index
    # @houses = House.all
    @houses = House.page(params[:page]).per(9)
  end
end
```

## ビュー開発
- ページを表示する
- `<%= paginate @houses %>`を追加すればいいだけ

```html+erb:app/views/layouts/application.html.erb
<div class="row">
  <div class="houses">
    <% @houses.each do |house| %>
      <div class="col-xs-6 col-md-4">
        <div class="house-box">
          <p class="house-name"><%= house.name %></p>
          <img class="house-image" src="http://www.itamichintai.com/01zoom.jpg" width="200" height="200">
          <p class="house-address">所在地: <%= house.address %></p>
          <p class="house-price"><%= number_to_currency(house.price) %></p>
          <%= link_to 'Read More', house_path(house), class: "btn btn-default" %>
        </div>
      </div>
    <% end %>
  </div>
  <!-- ここから追加 -->
  <%= paginate @houses %>
  <!-- ここまで追加 -->
</div>```


## ビューをきれいにする
- ここまででページネーションは実装されたがViewがいまいち
- kaminariにはデザイン機能もあり、下記コマンド実行でBootstrapを利用できる

### kaminariでBootstrapのデザイン適用
```bash:
$ rails g kaminari:views bootstrap3
```

### ページネーション用のボタンの表示文字を変える
- 特に設定をしなければ下記画像の用に First Previous Truncate Next Last という文字が表示される
- これを修正することができる
- 現在の言語は**ja**に設定されているので`config/locales/ja.yml`に追記

# 画像SS4

```yml:config/locales/ja.yml
---
ja:
### ここから追加
  views:
    pagination:
      previous: "«"
      next: "»"
      truncate: "..."
### ここまで追加
  activerecord:
```

## 下記のようになる
# 画像SS5


# Sellerモデルとのアソシ―ション
## 出発点: 物件の管理者情報と関連させる
- それぞれの物件の管理者を定義するモデルを用意する
- それを物件情報と関連付ける

## モデル設計
### Sellerモデル
|カラム名 |データ型 |意味|
|:----:|:----:|:----:|
|name   |string |氏名|
|email  |string |メールアドレス|

## モデル開発
- Sellerモデルをつくる
- Migrationスクリプトを修正

```bash:
$ rails g model Seller name:string email:string
```

```rb:db/migrate/yyyymmddhhss_create_sellers.rb
class CreateSellers < ActiveRecord::Migration
  def change
    create_table :sellers do |t|
      t.string :name,  null: false
      t.string :email, null: false

      t.timestamps null: false
    end
  end
end
```

```bash:
$ rake db:migrate
```

## Houseモデルに外部キーを追加
- モデル間の連携をするときには、連携の証として、**参照されるテーブルに、参照元のテーブル名のカラムが必要**
- 具体的には、下記のようなイメージ

<img width="626" alt="2016-09-10 6.33.04.png" src="https://qiita-image-store.s3.amazonaws.com/0/79919/780e5351-e1b2-202a-650a-d5a52a6cb40f.png">


- なので、方法としては
  1. Migrationスクリプトを発行して必要なカラムを追加
  2. add_referenceを使う(今回はコレ)。といってもMigrationスクリプトを発行するのは同じ。
    - [参考：add_reference - Railsドキュメント](http://railsdoc.com/references/add_reference)

### こんな感じの中身
```rb:db/migrate/20160923090339_add_seller_id_to_houses.rb
class AddSellerIdToHouses < ActiveRecord::Migration
  def change
    add_reference :houses, :seller, index: true, foreign_key: true
  end
end
```

```bash:
$ rake db:migrate
```

## ダミーデータの入れ直し
- 新しいテーブルやカラムを作ったのでダミーデータを入れ直す
- やはりseedsファイルを利用する

```bash:まずは既存のデータを削除
$ rails c
irb> House.destroy_all
irb> quit
```

### seedファイル修正
- 新規の売り主を20名ほど追加
- fakerを使ってそれっぽいデータにするにする

```rb:db/seeds.rb
20.times do
  Seller.create(
    name: ForgeryJa(:name).full_name,
    email: Faker::Internet.free_email
  )
end

100.times do
  House.create(
    name:    'メゾン' + ForgeryJa(:name).last_name,
    price:   ForgeryJa(:monetary).popularity_money,
    address: ForgeryJa(:address).full_address,
    note:    Faker::Lorem.paragraphs,
    seller_id: rand(1..20)
  )
end
```

```bash:
$ rake db:seed
```


## 各モデルでアソシエーションの設定
```rb:app/models/house.rb
class House < ActiveRecord::Base
  belongs_to :seller
  validates :name,
    presence: true, length: { maximum: 100 }
  validates :price,
    presence: true
  validates :address,
    presence: true
end
```

```rb:app/models/seller.rb
class Seller < ActiveRecord::Base
  has_many :houses
end
```


## 一覧画面で売り主の氏名を表示
- アソシエーションの設定をしたので簡単に情報にアクセスできる
- `house.seller.name`や`house.seller.email`という記述でいける

```html+erb:app/views/houses/index.html.erb
<div class="row">
  <div class="houses">
    <% @houses.each do |house| %>
      <div class="col-xs-6 col-md-4">
        <div class="house-box">
          <p class="house-name"><%= house.name %></p>
          <img class="house-image" src="http://www.itamichintai.com/01zoom.jpg" width="200" height="200">
          <p class="house-address">所在地: <%= house.address %></p>
          <p class="house-price"><%= number_to_currency(house.price) %></p>
          <!-- ここから追加 -->
          <p class="house-seller">売り主: <%= house.seller.name %></p>
          <!-- ここまで追加 -->
          <%= link_to 'Read More', house_path(house), class: "btn btn-default" %>
        </div>
      </div>
    <% end %>
  </div>
  <%= paginate @houses %>
</div>


## 詳細画面で売り主の氏名を表示

```html+erb:app/views/houses/show.html.erb
<div class="row">
  <div class="col-md-12">
    <h1><%= @house.name %></h1>
    <img class="house-image" src="http://www.itamichintai.com/01zoom.jpg" width="200" height="200">

    <h3>Address</h3>
    <p><%= @house.address %></p>

    <h3>Note</h3>
    <p><%= @house.note %></p>

    <!-- ここから追加 -->
    <h3>売り主情報</h3>
    <p>氏名: <%= @house.seller.name %></p>
    <p>Email: <%= @house.seller.email %></p>
    <!-- ここまで追加 -->

    <hr>
    <%= link_to 'Edit', edit_house_path(@house), class: "btn btn-default" %>
    <button type="button" class="btn btn-danger" data-toggle="modal" data-target="#delete-house">Delete</button>
  </div>
</div>

<div class="modal fade" id="delete-house">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title">物件情報の削除</h4>
      </div>
      <div class="modal-body">
        <p><%= @house.name %>を削除しますか？</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">キャンセル</button>
        <%= link_to '削除する', @house, method: :delete, class: "btn btn-danger" %>
      </div>
    </div>
  </div>
</div>
```

# 認証/承認機能の追加
## 出発点: 解決すべき問題とは
- 現状では物件情報をだれでも自由に追加/編集/削除ができてしまう
- なので、ログイン機能を設けて権限を設定する

## `devise`というGemを利用
- ログイン管理はdeviseというgemを使う
- 参考: [Devise - Github](https://github.com/plataformatec/devise)" target="_blank">公式ページ Github</a>
- 参考: [Railsのログイン認証gemのDeviseのインストール方法 - Rails Webook](http://ruby-rails.hatenadiary.com/entry/20140801/1406907000)
target="_blank">R</a>

## deviseの導入
- まずはGemfileに記述して`bundle install`

```rb:Gemfile
source 'https://rubygems.org'

gem 'rails', '4.2.6'
gem 'sqlite3'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'

gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'kaminari'
### ここから追加 ###
gem 'devise'
### ここまで追加 ###

group :development, :test do
  gem 'byebug'
  gem 'faker'
  gem 'forgery_ja'
end

group :development do
  gem 'web-console', '~> 2.0'

  gem 'spring'
end
```

```bash:
$ bundle install
```

## devise各種設定
### devise関連ファイルをプロジェクトに追加

```bash:
$ rails g devise:install
```

### ログアウト時のリダイレクト先としてroot_urlを設定
- これは既に設定している
- `root 'houses#index'`

### deviseで管理されるuserモデルの追加
- ログイン時に利用するUserモデルを追加
- `devise_for :users`というルーティングが自動で追加される

```bash:
$ rails g devise User
$ rake db:migrate
```

```bash:現在のルーティング
$ rake routes
                  Prefix Verb   URI Pattern                    Controller#Action
        new_user_session GET    /users/sign_in(.:format)       devise/sessions#new
            user_session POST   /users/sign_in(.:format)       devise/sessions#create
    destroy_user_session DELETE /users/sign_out(.:format)      devise/sessions#destroy
           user_password POST   /users/password(.:format)      devise/passwords#create
       new_user_password GET    /users/password/new(.:format)  devise/passwords#new
      edit_user_password GET    /users/password/edit(.:format) devise/passwords#edit
                         PATCH  /users/password(.:format)      devise/passwords#update
                         PUT    /users/password(.:format)      devise/passwords#update
cancel_user_registration GET    /users/cancel(.:format)        devise/registrations#cancel
       user_registration POST   /users(.:format)               devise/registrations#create
   new_user_registration GET    /users/sign_up(.:format)       devise/registrations#new
  edit_user_registration GET    /users/edit(.:format)          devise/registrations#edit
                         PATCH  /users(.:format)               devise/registrations#update
                         PUT    /users(.:format)               devise/registrations#update
                         DELETE /users(.:format)               devise/registrations#destroy
                  houses GET    /houses(.:format)              houses#index
                         POST   /houses(.:format)              houses#create
               new_house GET    /houses/new(.:format)          houses#new
              edit_house GET    /houses/:id/edit(.:format)     houses#edit
                   house GET    /houses/:id(.:format)          houses#show
                         PATCH  /houses/:id(.:format)          houses#update
                         PUT    /houses/:id(.:format)          houses#update
                         DELETE /houses/:id(.:format)          houses#destroy
                    root GET    /                              houses#index
```

### サーバーを再起動する
- 普通に再起動すればOK


## 共通headerの表示切り替え
- ログインしているかどうかで表示する内容を切り替える
  - ログインしている場合 → 設定変更/ログアウト
  - ログインしていない場合 → 新規登録/ログイン
- `モデル名_signer_in?`でログイン状態を判定してくれる
- パスの指定はPrefixを利用しているが、これは`$ rake routes`で確認すること

```html+erb:app/views/layout/_header.html.erb
<nav class="navbar navbar-default">
  <div class="container">
    <div class="navbar-header">
      <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-collapse-menu">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      <%= link_to "HOME", root_path, class: "navbar-brand" %>
    </div>
    <div class="collapse navbar-collapse" id="navbar-collapse-menu">
      <ul class="nav navbar-nav navbar-right">
        <!-- ここから追加 -->
        <% if user_signed_in? %>
          <li><%= link_to "設定変更", edit_user_registration_path %></li>
          <li><%= link_to "ログアウト", destroy_user_session_path, method: :delete %></li>
        <% else %>
          <li><%= link_to "新規登録", new_user_registration_path %></li>
          <li><%= link_to "ログイン", new_user_session_path %></li>
        <% end %>
        <!-- ここまで追加 -->
      </ul>
    </div><!-- /.navbar-collapse -->
  </div><!-- /.container-fluid -->
</nav>
```

## アクセス制限をかける
- `Houses`コントローラのindex,showアクション**以外**はログインを要求する仕様に変更
- `:authenticate_モデル名!`というdeviseのメソッドを`before_action`で呼び出すことによりフィルタリングする
- `only:`や`except:`を指定することで、ログインが必要なメソッドを絞ることもできる
  - before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]


```rb:app/controllers/houses_controller.rb
class HousesController < ApplicationController
  ### ここから追加 ###
  before_action :authenticate_user!, except: [:index, :show]
  ### ここまで追加 ###
  before_action :set_house, only: [:show, :edit, :update, :destroy]

### 省略 ###
end
```


## 注意書きを表示する
- 許可されていないアクションを実行したときにFlashMessageを表示させる
- [参考: ](http://ruby-rails.hatenadiary.com/entry/20141127/1417086075)


```html+erb:app/views/layout/application.html.erb
<!DOCTYPE html>
<html>
<head>
  <!-- 省略 -->
</head>
<body>

<%= render partial: 'layouts/header' %>

<div class="container">
  <!-- ここから追加  -->
  <% if notice.present? %>
    <div class="alert alert-dismissable alert-success">
      <button type="button" class="close" data-dismiss="alert">&times;</button>
      <p><%= notice %></p>
    </div>
  <% end %>

  <% if alert.present? %>
    <div class="alert alert-dismissable alert-danger">
      <button type="button" class="close" data-dismiss="alert">&times;</button>
      <p><%= alert %></p>
    </div>
  <% end %>
  <!-- ここまで追加  -->

  <%= yield %>
</div>

</body>
</html>
```


## Devieseに関するメッセージを日本語にする
- 公式ページの**[ここ](https://github.com/plataformatec/devise/wiki/I18n#japanese-devisejayml)**に、バージョン毎の日本語化ファイルがある
- 4.2.0以上のリンクから、devise.ja.ymlをダウンロード
- ダウンロードしたdevise.ja.ymlをconfig/locales以下に設置する
- サーバーを再起動すると、日本語化している
- 下記のwgetコマンドを使用すると、GitHub上のdevise.ja.ymlファイルをconfig/locales/にダウンロードすることが可能

```bash:日本語化ファイルをダウンロードするコマンド
$ wget https://gist.githubusercontent.com/kaorumori/7276cec9c2d15940a3d93c6fcfab19f3/raw/a8c4f854988391dd345f04ff100441884c324f2a/devise.ja.yml -P config/locales/
```

## ログイン画面などのカスタマイズ
- 下記コマンドで、各種テンプレートを生成される

```bash:
$ rails g devise:views
```

|対象画面|生成ファイル|
|:-----:|:-----:|
|ログイン画面 |app/views/devise/sessions/new.html.erb|
|新規登録画面 |app/views/devise/registrations/new.html.erb|
|登録情報変更画面 |app/views/devise/registrations/edit.html.erb|
|パスワードを変更するためのメールを送信する画面 |app/views/devise/passwords/new.html.erb|
|パスワード変更画面 |app/views/devise/passwords/edit.html.erb|
|メール認証画面 |app/views/devise/confirmations/new.html.erb|
|アカウントのアンロック画面 |app/views/devise/unlocks/new.html.erb|


## 試しにログイン画面を修正してみる

```html+erb:app/views/devise/sessions/new.html.erb
<div class="row">
  <div class="col-sm-8 col-sm-offset-2">
    <h2>ログイン</h2>

    <%= form_for(resource, as: resource_name, url: session_path(resource_name)) do |f| %>
      <div class="form-group">
        <%= f.label :email, "電子メール" %><br />
        <%= f.email_field :email, autofocus: true, class: "form-control" %>
      </div>

      <div class="form-group">
        <%= f.label :password, "パスワード" %><br />
        <%= f.password_field :password, autocomplete: "off", class: "form-control" %>
      </div>

      <% if devise_mapping.rememberable? -%>
        <div class="checkbox">
          <label>
            <%= f.check_box :remember_me %> ログイン情報を記録する
          </label>
        </div>
      <% end -%>

      <div class="form-group">
        <%= f.submit "ログイン", class: 'btn btn-default' %>
      </div>
    <% end %>

    <%= render "devise/shared/links" %>
  </div>
</div>
```

以上
