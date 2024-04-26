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
* SQLite3 1.4
* Puma 5.0
* Webpacker 5.0
* Turbolinks 5
* Bootsnap 1.4.4

## テスト
Circle CIを使用して、以下のテストが自動化されています。

* RSpec
* RuboCop
* Build

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

## ライセンス

このプロジェクトは MIT ライセンスのもとで公開されています。
