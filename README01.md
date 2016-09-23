# 目次
- [物件管理アプリ(1)](http://qiita.com/mohira/private/6471442a7585cfb911f0) ← イマココ
  - 基本のCRUD
  - バリデーション
  - パーシャル
  - 日本語化
  - リファクタリング
- [物件管理アプリ(2)](http://qiita.com/mohira/private/00c8046afa69cd3d6d48)
  - ページネーション(kaminari)
  - アソシエーション
  - ログイン機能(devise)
- [物件管理アプリ(3)](http://qiita.com/mohira/private/2ea0420c7108f0f6a78a)
  - コメントの追加と削除

## 要件定義
- 物件を管理できる(基本CRUD)
- ログイン機能がある
- ページネーションがなされている
- 物件に対してコメントができる

## モデル設計
### Houseモデル
|カラム名|データ型|意味|備考|
|:--------:|:-------:|:----------:|:------:|
| name     | string  | 物件名     |
| price    | integer | 価格       |
| address  | string  | 住所       |
| note     | text    | 備考       |


## プロジェクト作成
```bash:プロジェクト作成
$ rails new real_estate_app
$ cd real_estate_app
```

# 基本CRUD
## ルーティング設計
- 基本のCRUDのルーティング

|HTTP|URIパターン|呼び出し|機能|
|:----:|:-------------:|:------------:|:--------------------:|
|GET   |houses         |houses#index  |物件の一覧表示        |
|GET   |houses/new     |houses#new    |物件の投稿フォーム表示|
|POST  |houses         |houses#create |物件の投稿データ保存  |
|GET   |houses/:id     |houses#show   |各物件の詳細表示      |
|GET   |houses/:id/edit|houses#edit   |物件の編集フォーム表示|
|PATCH |houses/:id     |houses#update |物件の編集データの更新|
|DELETE|houses/:id     |houses#destroy|物件データの削除      |

## Houseモデル作成
### Houseモデル設計(再掲)
|カラム名|データ型|意味|備考|
|:--------:|:-------:|:----------:|:------:|
| name     | string  | 物件名     |
| price    | integer | 価格       |
| address  | string  | 住所       |
| note     | text    | 備考       |

```bash:
$ rails g model House name:string price:integer address:string note:text
```

### Migrationスクリプトの編集: カラムのオプション設定
- `null: false`
  - NULL(Nプログラミング言語やデータベースのデータ表現の一種で、何のデータも含まれない状態、あるいは長さ0の空文字列のこと。)を許可しない
- `length: { maximum: 100 }`
  - 100文字までの設定
- 参考: [create_table - Railsドキュメント](http://ur0.pw/yyyQ)

```rb:db/migrate/yyyymmddhhss_create_houses.rb
class CreateHouses < ActiveRecord::Migration
  def change
    create_table :houses do |t|
      t.string :name,    null: false, length: { maximum: 100 }
      t.integer :price,  null: false
      t.string :address, null: false
      t.text :note

      t.timestamps null: false
    end
  end
end
```

### Migrationスクリプト反映
```bash:
$ rake db:migrate
```

## Housesコントローラ作成
- コントローラを作成する際、CRUDに必要なアクション(7種類)を指定する。
- コントローラー名の後にメソッドをつけると、コントローラーで空のメソッド定義、ビューのテンプレまで作ってくれるので利用する

```bash:
$ rails g controller Houses index show new create edit update destroy
```

### 余計なViewファイル削除
- コントローラ生成時のオプションで生まれた余計なViewファイルを削除する
  - create.html.erb
  - update.html.erb
  - destroy.html.erb

## ルーティング開発
- Housesに関する基本のCRUDのルーティングを**resources**を利用して修正
- 同時に、rootのルーティングも設定

```rb:config/routes.rb
Rails.application.routes.draw do
  resources :houses
  root 'houses#index'
end
```

### `rake routes`でルーティングを確認
```bash:ルーティングの確認
$ rake routes
    Prefix Verb   URI Pattern                Controller#Action
    houses GET    /houses(.:format)          houses#index
           POST   /houses(.:format)          houses#create
 new_house GET    /houses/new(.:format)      houses#new
edit_house GET    /houses/:id/edit(.:format) houses#edit
     house GET    /houses/:id(.:format)      houses#show
           PATCH  /houses/:id(.:format)      houses#update
           PUT    /houses/:id(.:format)      houses#update
           DELETE /houses/:id(.:format)      houses#destroy
      root GET    /                          houses#index
```

# 初期設定
## 基本設定ファイルを修正
### メッセージの日本語化
- Railsの国際化機能を使うと、日本語や英語などさまざまな言語のテキストをブラウザ上に表示することができる
- [Railsの多言語化対応 I18nのやり方を整理してみた！【国際化/英語化](http://morizyun.github.io/blog/i18n-english-rails-ruby-many-languages/)
- `config/application.rb`はすべての環境で共通の設定ファイル
- `config.パラメータ名 = 値`の形式
- 設定系ファイルはすべて、サーバを再起動しないと反映されない
- 参考: [設定ファイル(config) - Railsドキュメント](http://railsdoc.com/config)


```ruby:config/application.rb

### 省略 ###

module RealEstateApp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.

    ### ここから修正 ###
    config.time_zone = 'Tokyo'
    ### ここまで修正 ###

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]

    ### ここから修正 ###
    config.i18n.default_locale = :ja
    ### ここからまで ###

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end
end
```

### 日本語化ファイルをいれる
- [Github](https://github.com/svenfuchs/rails-i18n/blob/master/rails/locale/ja.yml)から`ja.yml`をダウンロードする
- ダウンロードした`ja.yml`を`config/locale/`の以下に入れる。
- 下記のwgetコマンドを使用すると、GitHub上の`ja.yml`ファイルを`config/locale/`にダウンロードすることが可能

```bash:日本語のテンプレートをダウンロードするコマンド
$ wget https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml -P config/locales/
```

## Bootstrapの適用
- [Bootstrapの公式ページ](http://getbootstrap.com/)
- Getting startedにアクセス

<img width="852" alt="Bootstrap_·_The_world_s_most_popular_mobile-first_and_responsive_front-end_framework_.png" src="https://qiita-image-store.s3.amazonaws.com/0/79919/b01468b0-5c85-6aa7-0177-b6a4f1197cb0.png">


- Bootstrap CDNをコピー

<img width="804" alt="Getting_started_·_Bootstrap.png" src="https://qiita-image-store.s3.amazonaws.com/0/79919/6fb6cf62-5c66-7b88-00a7-dbf88c2af25b.png">


- app/views/layouts/application.html.erbのheadタグ内にペースト

```html+erb:app/views/layouts/application.html.erb
<!DOCTYPE html>
<html>
<head>
  <title>SpartaCrm</title>
  <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>
  <%= javascript_include_tag 'application', 'data-turbolinks-track' => true %>
  <%= csrf_meta_tags %>
<!-- ここから追加 -->
  <!-- Latest compiled and minified CSS -->
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">

  <!-- Optional theme -->
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous">

  <!-- Latest compiled and minified JavaScript -->
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
<!-- ここまで追加 -->
</head>
<body>

<%= yield %>

</body>
</html>
```

## 共通headerの作成
- 全ページ共通のheaderを作成
- 全てのページで利用するので、Partialを作り、共通レイアウト(`application.html.erb`)で読み込む
- 同時に`<%= yield %>`を`.container`で囲っておく

```html+erb:app/views/layouts/_header.html.erb
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

    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="collapse navbar-collapse" id="navbar-collapse-menu">
      <ul class="nav navbar-nav navbar-right">
        <li><a href="#">ダミー</a></li>
      </ul>
    </div><!-- /.navbar-collapse -->
  </div><!-- /.container-fluid -->
</nav>
```

```html+erb:app/views/layouts/application.html.erb
<!DOCTYPE html>
<html>
<head>
  <title>RealEstateApp</title>
  <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>
  <%= javascript_include_tag 'application', 'data-turbolinks-track' => true %>
  <%= csrf_meta_tags %>
  <!-- Latest compiled and minified CSS -->
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">

  <!-- Optional theme -->
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous">

  <!-- Latest compiled and minified JavaScript -->
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
</head>
<body>
<!-- ここから追加 -->
<%= render partial: 'layouts/header' %>

<div class="container">
  <%= yield %>
</div>
<!-- ここまで追加 -->
</body>
</html>
```

### 動作確認
![SS.png](https://qiita-image-store.s3.amazonaws.com/0/79919/fe5ad09e-f3d2-eef2-43d3-e1957ddc8e1e.png)

## ダミーデータの用意
- FakerとForgeryJaというGemを利用してダミーデータをつくる
- [Faker](https://github.com/stympy/faker)
  - おそらく一番人気のダミーデータ作成Gem
- [ForgeryJa](https://github.com/namakesugi/forgery_ja)
  - 英語のみ対応のダミーデータ作成GemであるForgeryを日本語化したもの
  - フリガナや住所などに対応している

```rb:Gemfile
### 省略 ###

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  ### ここから追加 ###
  gem 'faker'
  gem 'forgery_ja'
  ### ここまで追加 ###
end

### 省略 ###
```

```bash:
$ bundle install
```

## seedsファイルの作成
- FakerとForgeryJaを利用して100件ほどのダミーデータを作成

```rb:db/seeds.rb
100.times do
  House.create(
    name:    'メゾン' + ForgeryJa(:name).last_name,
    price:   ForgeryJa(:monetary).popularity_money,
    address: ForgeryJa(:address).full_address,
    note:    Faker::Lorem.paragraphs
  )
end
```

```bash:
$ rake db:seed
```

### コンソールで確認
```bash:
$ rails c
irb(main):001:0> House.all
```

# 一覧機能
## コントローラ開発: indexアクション

```rb:app/controllers/houses_controller.rb
class HousesController < ApplicationController
  def index
    @houses = House.all
  end
end
```

## ビュー開発
- ひとまず表示させてみる
- 画像はダミー画像(1種類)を表示している
- 価格については`number_to_currency`メソッドを使って成形
  - 参考: [数値を通貨のフォーマットに変換(number_to_currency) - Railsドキュメント](http://railsdoc.com/references/number_to_currency)
- `link_to`の引数の`house_path(house)`は実際に生成されるURLを確認してほしい

```html+erb:app/views/houses/index.html.erb
<% @houses.each do |house| %>
  <p><%= house.name %></p>
  <%= image_tag "http://www.itamichintai.com/01zoom.jpg", width: 200 , height: 200 %>
  <p>所在地: <%= house.address %></p>
  <p><%= number_to_currency(house.price) %></p>
  <%= link_to 'Read More', house_path(house) %>
<% end %>
```

## CSSで装飾
- 少しだけ見栄えを調整
- housesに関するViewのCSSは`app/assets/stylesheets/houses.scss`に記述すればOK
- 細かいCSSは各自で確認してください(今回はコピペします)

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
          <%= link_to 'Read More', house_path(house), class: "btn btn-default" %>
        </div>
      </div>
    <% end %>
  </div>
</div>
```

```scss:app/assets/stylesheets/houses.scss
.houses {
  .house-box {
    border: solid 5px;
    padding: 20px;
    margin-bottom: 20px;
    text-align: center;

    .house-name {font-size: 24px;}

    .house-image {margin: 10px;}

    .house-address {}
  }
}
```

# 詳細機能

## コントローラ開発: showアクション
```rb:app/controllers/houses_controller.rb
class HousesController < ApplicationController
  def show
    @house = House.find(params[:id])
  end
end
```

## ビュー開発
- 編集のリンク指定にはPrefixを利用している
- 他は基本通り

```html+erb:app/views/houses/show.html.erb
<div class="row">
  <div class="col-md-12">
    <h1><%= @house.name %></h1>
    <img class="house-image" src="http://www.itamichintai.com/01zoom.jpg" width="200" height="200">

    <h3>Address</h3>
    <p><%= @house.address %></p>

    <h3>Note</h3>
    <p><%= @house.note %></p>

    <hr>
    <%= link_to 'Edit', edit_house_path(@house), class: "btn btn-default" %>
  </div>
</div>
```


# 新規登録機能
- バリデーションも実装する

## コントローラ開発: newアクション
```rb:app/controllers/houses_controller.rb
class HousesController < ApplicationController
  def new
    @house = House.new
  end
end
```

## ビュー開発
- フォームは新規登録と編集フォームの内容が同一になるのでパーシャルを利用する
- パーシャルの読み込みは`<%= render partial: 'form' %>`が基本だが、localsを利用して変数を渡さない場合は**partialを省略できる**

```html+erb:app/views/layouts/_form.html.erb
<%= form_for(@house) do |f| %>
  <div class="form-group">
    <%= f.label :name %><br>
    <%= f.text_field :name, class: "form-control" %>
  </div>
  <div class="form-group">
    <%= f.label :price %><br>
    <%= f.number_field :price, class: "form-control" %>
  </div>
  <div class="form-group">
    <%= f.label :address %><br>
    <%= f.text_field :address, class: "form-control" %>
  </div>
  <div class="form-group">
    <%= f.label :note %><br>
    <%= f.text_area :note, class: "form-control" %>
  </div>
  <%= f.submit class: "btn btn-default" %>
<% end %>
```


```html+erb:app/views/houses/new.html.erb
<div class="row">
  <div class="col-md-12">
    <%= render 'form' %>
  </div>
</div>
```

## 共通headerからnewアクションを呼べるようにする

```diff:app/views/layouts/_header.html.erb
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

    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="collapse navbar-collapse" id="navbar-collapse-menu">
      <ul class="nav navbar-nav navbar-right">
-        <li><a href="#">ダミー</a></li>
+        <li><%= link_to '物件登録', new_house_path %></li>
      </ul>
    </div><!-- /.navbar-collapse -->
  </div><!-- /.container-fluid -->
</nav>
```

## コントローラ開発: createアクション
- 現時点ではデータを投げているが、そのデータを保存するアクションがないのでcreateアクションを実装
- 当然StrongParameterをプライベートメソッドとして設定する
- データ保存が完了したら詳細画面にリダイレクトさせる
  - `redirect_to`のURL指定は色々あるが今回は`@house`でOK

```rb:app/controllers/houses_controller.rb
class HousesController < ApplicationController
  def create
    @house = House.new(house_params)
    @house.save
    redirect_to @house
  end

  private
  def house_params
    params.require(:house).permit(:name, :price, :address, :note)
  end
end
```

## バリデーション
- Migrationスクリプトで、null禁止指定をした
- バリデーション無しで投げたらどうなるかチェックしてみる

![SS 1.png](https://qiita-image-store.s3.amazonaws.com/0/79919/8a21f4c7-62e7-4a81-c5c6-e556a9bb6173.png)



## チェックする項目と動き
- データが入力されているかどうか
- データが規定の長さ以下か

```rb:app/models/house.rb
class House < ActiveRecord::Base
  validates :name,
    presence: true, length: { maximum: 100 }
  validates :price,
    presence: true
  validates :address,
    presence: true
end
```

## 再度空欄で登録してみる
- 今度はエラーはでない
- しかし、保存もされていない

## バリデーションが行われるタイミング
- saveメソッドが呼ばれたタイミングで、モデルのバリデーションが実行される
  - バリデーションが通って保存されたらtrue
  - 通らなかったら保存しないでfalse
- よって、if文を利用して
  - 保存される → 詳細画面にリダイレクト
  - 保存されない → 再度登録フォームを表示させる

```rb:app/controllers/houses_controller.rb
class HousesController < ApplicationController
  def create
    @house = House.new(house_params)
    if @house.save
      redirect_to @house
    else
      render :new
    end
  end
end
```

## バリデーションを突破しない場合にエラー内容を表示する
- バリデーションが通らずnewにredirect_toされた際、エラー内容が表示されるようにする
- フォームに関する内容なのでパーシャルに記述
- `@house.errors`でエラー情報にアクセスできる
- エラーメッセージが日本語なのは日本語化したため

```html+erb:app/views/layouts/_form.html.erb
<%= form_for(@house) do |f| %>

  <!-- ここから追加 -->
  <% if @house.errors.any? %>
    <div class="alert alert-danger">
      <p><b><%= @house.errors.count %>件のエラーがあります</b></p>

      <ul>
        <% @house.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>
  <!-- ここまで追加 -->

  <div class="form-group">
    <%= f.label :name %><br>
    <%= f.text_field :name, class: "form-control" %>
  </div>
  <div class="form-group">
    <%= f.label :price %><br>
    <%= f.number_field :price, class: "form-control" %>
  </div>
  <div class="form-group">
    <%= f.label :address %><br>
    <%= f.text_field :address, class: "form-control" %>
  </div>
  <div class="form-group">
    <%= f.label :note %><br>
    <%= f.text_area :note, class: "form-control" %>
  </div>
  <%= f.submit class: "btn btn-default" %>
<% end %>
```

# 編集機能
## コントローラ開発: editアクション
```rb:app/controllers/houses_controller.rb
class HousesController < ApplicationController
  def edit
    @house = House.find(params[:id])
  end
end
```

## ビュー開発
- フォームはPartialを読み込めばOK
  - 細かい点ではあるが、送信ボタンが「Update House」となっている

```html+erb:app/views/houses/edit.html.erb
<div class="row">
  <div class="col-md-12">
    <%= render 'form' %>
  </div>
</div>
```

## コントローラ開発: updateアクション
- データ更新が完了したら詳細画面にリダイレクトさせる
  - `redirect_to`のURL指定は色々あるが今回は`@house`でOK
  - `redirect_to @customer` は `redirect_to customer_path(@customer)`と同じ動きになる。
  - 参考：[redirect_to の引数とかのメモ]

```rb:app/controllers/houses_controller.rb
class HousesController < ApplicationController
  def update
    @house = House.find(params[:id])
    @house.update(house_params)
    redirect_to @house
  end
end
```

## バリデーション対応
- updateアクションもバリデーションの確認をする

```rb:app/controllers/houses_controller.rb
class HousesController < ApplicationController
  def update
    @house = House.find(params[:id])
    @house.update(house_params)
    redirect_to @house
  end
end
```

# 削除機能
- データを削除したら一覧にリダイレクトさせる
  - `root_path`でOK

## コントローラ開発:
```rb:app/controllers/houses_controller.rb
class HousesController < ApplicationController
  def destroy
    @house = House.find(params[:id])
    @house.destroy
    redirect_to root_path
  end
end
```

## 削除用のモーダルを表示する
- 削除用のリンクを生成するがモーダルを利用してみる
- [Bootstrapの公式ページ - Modal](http://v4-alpha.getbootstrap.com/components/modal/)

```html+erb:app/views/houses/show.html.erb
<div class="row">
  <div class="col-md-12">
    <h1><%= @house.name %></h1>
    <img class="house-image" src="http://www.itamichintai.com/01zoom.jpg" width="200" height="200">

    <h3>Address</h3>
    <p><%= @house.address %></p>

    <h3>Note</h3>
    <p><%= @house.note %></p>

    <hr>
    <%= link_to 'Edit', edit_house_path(@house), class: "btn btn-default" %>

    <!-- ここから追加 -->
    <button type="button" class="btn btn-danger" data-toggle="modal" data-target="#delete-house">Delete</button>
    <!-- ここまで追加 -->
  </div>
</div>

<!-- ここから追加 -->
<!-- 下記のモーダルは通常は隠れているので、どこに書いてもＯＫ -->
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
<!-- ここまで追加 -->
```

# リファクタリング
## before_actionでコントローラをスッキリさせる
- 例によって`@house = House.find(params[:id])`が重複しているのでリファクタリング
- `set_house`というプライベートメソッドを用意する
- `show`, `edit`, `update`, `destroy`における`@house = House.find(params[:id])`を削除
- 記述した後はきちんと動作確認をすること

```rb:app/controllers/houses_controller.rb
class HousesController < ApplicationController
  before_action :set_house, only: [:show, :edit, :update, :destroy]

  def index
    @houses = House.all
  end

  def show
  end

  def new
    @house = House.new
  end

  def create
    @house = House.new(house_params)
    if @house.save
      redirect_to @house
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @house.update(house_params)
      redirect_to @house
    else
      render :edit
    end
  end

  def destroy
    @house.destroy
    redirect_to root_path
  end

  private
  def house_params
    params.require(:house).permit(:name, :price, :address, :note)
  end

  def set_house
    @house = House.find(params[:id])
  end
end
```

以上