# 目次
- [物件管理アプリ(1)](http://qiita.com/mohira/private/6471442a7585cfb911f0)
  - 基本のCRUD
  - バリデーション
  - パーシャル
  - 日本語化
  - リファクタリング
- [物件管理アプリ(2)](http://qiita.com/mohira/private/00c8046afa69cd3d6d48)
  - ページネーション(kaminari)
  - アソシエーション
  - ログイン機能(devise)
- [物件管理アプリ(3)](http://qiita.com/mohira/private/2ea0420c7108f0f6a78a) ← イマココ
  - コメントの追加と削除


# 目的
- 物件詳細画面でコメントできる機能を追加する


## モデル設計
- **1つのHouse**は**複数のComments**を持つ
- House has many Comments.
- Comment belongs to House.

### Commentモデル
|カラム名|データ型|意味|
|:--------:|:-------:|:----------:|
| house_id | string | 紐づく物件のID |
| body     | text   | コメント本文 |

## コントローラ設計
- Commentsコントローラに必要なアクションは下記の2点。

|アクション名|機能|
|:-------:|:-------:|
| create | コメント保存|
| destroy | コメント削除 |

## ビュー設計
- Commentsコントローラは受け取ったデータの保存や削除だけの機能しかない
- よって、Comments独自のテンプレートは不要であり、
- データを渡すのは**物件詳細画面**で行う

## モデル開発
- 外部キーが必要なので、`references`を利用する

```bash:
$ rails g model Comment body:text house:references
$ rake db:migrate
```

## コントローラ開発
- コントローラ生成と空のアクションを実装

```bash:
$ rails g controller comments
```

```rb:app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  def create

  end

  def destroy

  end
end
```


## ビュー開発
- 物件詳細画面にコメント投稿用のフォームをつくる
- 同時に、コメント用の空のオブジェクトの生成も行う

### 空のオブジェクト生成
- これは基本CRUDと同じ

```rb:app/controllers/houses_controller.rb(showアクション)
class HousesController < ApplicationController
  def show
    @comment = Comment.new # これをform_forで利用する
  end
end
```

### 物件詳細画面にコメント用のフォームを用意
- `form_for`を利用する
- 各Commentは`house_id`を持っているが、それをいちいち入力するようにするのは面倒な上にミスも発生しやすいので、**隠しフォーム(f.hidden_field)**を使う
- しかし、**このままではエラーになる！**

```html+erb:app/views/houses/show.html.erb
<div class="row">
  <div class="col-md-12">
    <h1><%= @house.name %></h1>
    <img class="house-image" src="http://www.itamichintai.com/01zoom.jpg" width="200" height="200">

    <h3>Address</h3>
    <p><%= @house.address %></p>

    <h3>Note</h3>
    <p><%= @house.note %></p>

    <h3>売り主情報</h3>
    <p>氏名: <%= @house.seller.name %></p>
    <p>Email: <%= @house.seller.email %></p>

    <hr>
    <%= link_to 'Edit', edit_house_path(@house), class: "btn btn-default" %>
    <button type="button" class="btn btn-danger" data-toggle="modal" data-target="#delete-house">Delete</button>

    <!-- ここから追加 -->
    <hr>
    <%= form_for @comment, url: {controller: :comments, action: :create} do |f| %>
      <div class="form-group">
        <%= f.label :body, 'コメント' %><br>
        <%= f.text_area :body %>
      </div>
      <%= f.hidden_field :house_id, value: @house.id %>
      <%= f.submit '投稿する', class: "btn btn-default"  %>
    <% end %>
    <!-- ここまで追加 -->
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

## このままではエラーになる
#SS7

### エラー文(抜粋)
- エラー文は下記の通り
- どうやら`comments_path`というメソッドを実行しているらしいが、それが未定義(undefined)となっているのが原因らしい

```
undefined method `comments_path' for #<#<Class:0x007fc06d1f5308>:0x007fc06cc3cb78>
```

### 原因: ルーティング
- `<%= form_for @comment do |f| %>`とすることにより、Railsが`@comment`に対応したパスを生成しようとする
- 今回は`@comment`なので、`comments_path`と勝手に判断している
- しかし、ルーティングが特に設定されていないのでエラーになった

## 解決策: ルーティングを追加すればいい
- 書き方は2通り
- `resources`を使った方がいろいろ便利

```rb:config/routes.rb
Rails.application.routes.draw do
  devise_for :users
  resources :houses

  ### ここから追加
  # post 'comments' => 'comments#create' でもOK
  resources :comments, only: [:create]
  ### ここまで追加

  root 'houses#index'
end
```

## createアクション実装
- 保存処理の記述/StrongParameter/リダイレクト先の指定
- redirect_toの指定をしない場合、`comments/create.html.erb`に行ってしまう
- 今回は物件詳細にリダイレクトさせるほうがユーザーにとって嬉しい
- **物件詳細(houses#show)**の中の**コメントが投稿されたID**に飛ばしたい
- Viewの中で使うのはxxx_path、コントローラーで使うのはxxx_url

```rb:app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      redirect_to house_url(@comment.house.id)
    else
      redirect_to house_url(@comment.house.id)
    end
  end

  def destroy

  end

  private
  def comment_params
    params.require(:comment).permit(:body, :house_id)
  end
end
```

## Commentのバリデーションとアソシエーション
```rb:app/models/house.rb
class House < ActiveRecord::Base
  belongs_to :seller
  has_many :comments # 追加
  validates :name,
    presence: true, length: { maximum: 100 }
  validates :price,
    presence: true
  validates :address,
    presence: true
end
```

```rb:app/models/comment.rb
class Comment < ActiveRecord::Base
  belongs_to :house

  validates :body,     presence: true
  validates :house_id, presence: true
end
```

## 物件詳細画面でコメントを表示する
- 例えば下記のようなテンプレートが考えられる
- 求められるのはhouses#showの中で、表示されているhouseの全コメントが@commentsに格納されていること
- しかし、@commentsはまだ存在しない。どこに、どのように記述するか？

```html+erb:app/views/houses/show.html.erbのイメージ
<h2>コメント</h2>
<% @comments.each do |comment| %>
  <p>
    <%= comment.body %>
  </p>
<% end %>
```

## Housesコントローラの修正(1)
- @commentsを記述する
- `where`を利用する

```rb:app/controllers/houses_controller.rb(showアクションのみ)
class HousesController < ApplicationController
  def show
    @comment = Comment.new
    @comments = Comment.where(house_id: params[:id])
  end
end
```

## Housesコントローラの修正(1)
- `@comments = Comment.where(house_id: params[:id])`で問題なく動く
- しかし記述が長い。
- アソシエーションを設定しているので簡潔に記述することができる
- `@house`は`before_action`で定義していることを忘れないように

```rb:app/controllers/houses_controller.rb(showアクションのみ)
class HousesController < ApplicationController
  def show
    @comment = Comment.new
    # @comments = Comment.where(house_id: params[:id])
    @comments = @house.comments
  end
end
```

## ビューの修正
- ちょっと装飾もしてみる

```html+erb:app/views/houses/show.html.erb
<div class="row">
  <div class="col-md-12">
    <h1><%= @house.name %></h1>
    <img class="house-image" src="http://www.itamichintai.com/01zoom.jpg" width="200" height="200">

    <h3>Address</h3>
    <p><%= @house.address %></p>

    <h3>Note</h3>
    <p><%= @house.note %></p>

    <h3>売り主情報</h3>
    <p>氏名: <%= @house.seller.name %></p>
    <p>Email: <%= @house.seller.email %></p>

    <hr>
    <%= link_to 'Edit', edit_house_path(@house), class: "btn btn-default" %>
    <button type="button" class="btn btn-danger" data-toggle="modal" data-target="#delete-house">Delete</button>

    <!-- ここから追加 -->
    <h2>コメント</h2>
    <% @comments.each do |comment| %>
      <div class="media">
        <div class="media-body">
          <%= simple_format(comment.body) %>
          <p class="text-muted">
            投稿記事:<%= comment.created_at.strftime('%Y%m%d %H:%M') %>
          </p>
        </div>
      </div>
    <% end %>
    <!-- ここまで追加 -->

    <hr>
    <%= form_for @comment do |f| %>
      <div class="form-group">
        <%= f.label :body, 'コメント' %><br>
        <%= f.text_area :body %>
      </div>
      <%= f.hidden_field :house_id, value: @house.id %>
      <%= f.submit '投稿する', class: "btn btn-default"  %>
    <% end %>

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


# コメント削除機能
## ルーティングカイアhつ
- comments#destroy用のルーティングを記述

```rb:config/routes.rb
Rails.application.routes.draw do
  devise_for :users
  resources :houses
  # :destroy追加するだけ
  resources :comments, only: [:create, :destroy]
  root 'houses#index'
end
```

## コントローラ開発
- 削除は基本どおり
- しかし、リダイレクト先が問題

```rb:app/controllers/comments_controller.rb(destroyアクションのみ)
class CommentsController < ApplicationController
  def destroy
    @comment = Comment.find(params[:id])

    # @commentがdestroyされる前に、commentが誰のものかを変数に保存する
    house_id = @comment.house.id
    @comment.destroy

    # さっき保存したcustomer_idをここで使う
    redirect_to house_url(house_id)
  end
end
```

## ビュー開発
- 削除用のリンクを作成




```html+erb:app/views/houses/show.html.erb
<div class="row">
  <div class="col-md-12">
    <h1><%= @house.name %></h1>
    <img class="house-image" src="http://www.itamichintai.com/01zoom.jpg" width="200" height="200">

    <h3>Address</h3>
    <p><%= @house.address %></p>

    <h3>Note</h3>
    <p><%= @house.note %></p>

    <h3>売り主情報</h3>
    <p>氏名: <%= @house.seller.name %></p>
    <p>Email: <%= @house.seller.email %></p>

    <hr>
    <%= link_to 'Edit', edit_house_path(@house), class: "btn btn-default" %>
    <button type="button" class="btn btn-danger" data-toggle="modal" data-target="#delete-house">Delete</button>

    <h2>コメント</h2>
    <% @comments.each do |comment| %>
      <div class="media">
        <div class="media-body">
          <%= simple_format(comment.body) %>
          <p class="text-muted">
            投稿記事:<%= comment.created_at.strftime('%Y%m%d %H:%M') %>
          </p>
          <!-- ここから追加 -->
          <%= link_to '削除', comment_path(comment.id) ,method: :delete %>
          <!-- ここまで追加 -->
        </div>
      </div>
    <% end %>

    <hr>
    <%= form_for @comment do |f| %>
      <div class="form-group">
        <%= f.label :body, 'コメント' %><br>
        <%= f.text_area :body %>
      </div>
      <%= f.hidden_field :house_id, value: @house.id %>
      <%= f.submit '投稿する', class: "btn btn-default"  %>
    <% end %>

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



以上






