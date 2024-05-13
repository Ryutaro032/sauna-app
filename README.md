# サウナ施設検索アプリ

このアプリはGoogle APIを利用してサウナ施設を検索することができるウェブアプリケーションです。ユーザーはログイン後、施設をお気に入りとして保存することができます。

## 目次
- [概要](#概要)
- [機能](#機能)
- [使用技術](#使用技術)
- [環境](#環境)
- [テスト](#テスト)
- [インストール](#インストール)
- [ER図](#er図)
- [デプロイ](#デプロイ)
- [ライセンス](#ライセンス)

## 概要
このアプリケーションは、Railsを使用して開発されたサウナ施設検索アプリです。Google APIを利用してサウナ施設の情報を検索し、ユーザーはお気に入りの施設を保存することができます。

## 機能
* Google APIを利用したサウナ施設の検索
* ユーザー認証機能（ログイン・ログアウト）
* 施設のお気に入り追加・削除

## 使用技術
* Ruby on Rails
* Google API
* CircleCI

## 環境
* Ruby 3.0.6
* Rails 6.1.7
* MySQL 8.3.0
* Puma 5.0
* Webpacker 5.4.4
* Turbolinks 5
* Bootsnap 1.4.4

## テスト
Circle CIを使用して、以下のテストが自動化されています。

* RuboCop
* Build

このアプリケーションはRSpecを使用してテストされています。また、VCRとWebMockを組み合わせて外部APIへのリクエストをモックしています。
テストの実行方法は以下の通りです。

    ```
     $ bundle exec rspec
    ```

このコマンドにより、RSpecによるテストが実行され、VCRとWebMockによって外部APIへのリクエストがモックされます。

## インストール
1. リポジトリをクローンします。

    ```
    $ git clone https://github.com/Ryutaro032/sauna-app.git
    ```

2. ディレクトリに移動します。

    ```
    $ cd repository
    ```

3. 必要なGemをインストールします。

    ```
    $ bundle install
    ```

4. データベースを作成します。

    ```
    $ rails db:create
    $ rails db:migrate
    ```

5. アプリケーションを起動します。

    ```
    $ rails server


## ER図

  ![](./sauna-app.drawio.svg)

## デプロイ

このアプリケーションは、Herokuを使用して簡単にデプロイできます。

1. Herokuにログインします。

2. 新しいアプリケーションを作成します。

    ```
    $ heroku create <アプリケーション名>
    ```

3. Herokuにデプロイします。

    ```
    $ git push heroku main
    ```

4. データベースをセットアップします。

    ```
    $ heroku run rails db:migrate
    $ heroku run rails db:seed:production_seed1
    $ heroku run rails db:seed:production_seed2
    $ heroku run rails db:seed:production_seed3
    
    ```

5. アプリケーションを開きます。

    ```
    $ heroku open
    ```

これで、アプリケーションがHerokuにデプロイされ、利用できるようになります。

## ライセンス

このプロジェクトは MIT ライセンスのもとで公開されています。
