# ToDo App (Rails + Docker)

Rails 7.1 / PostgreSQL / Hotwire(Turbo) / Tailwind CSS で作った ToDo アプリです。
画面リロードなしでタスクの追加・完了・編集・削除ができます。

## 機能

- タスクの追加 / 編集 / 削除（Turbo Stream で部分更新）
- ワンクリックで完了 / 未完了の切り替え
- 「すべて / 未完了 / 完了」のフィルタ（件数バッジ付き）
- 優先度（低 / 中 / 高）と期限の設定。期限切れ・期限間近をバッジで表示
- 期限・優先度を考慮した自動並び替え

## 必要なもの

- Docker / Docker Compose

## 起動方法

```bash
docker compose up --build
```

初回は gem のインストールと DB 作成のため少し時間がかかります。
起動したらブラウザで以下を開いてください。

http://localhost:3100

> ※ ホスト側ポートは、よくある 3000 番（他の Rails アプリ等）との衝突を避けて **3100** にしています。
> 変更したい場合は `docker-compose.yml` の `ports` を編集してください（例: `"3000:3000"`）。

サンプルデータは初回起動時に自動で投入されます。後から入れ直したい場合は別ターミナルで:

```bash
docker compose exec web bin/rails db:seed
```

## よく使うコマンド

```bash
# 起動 / 停止
docker compose up
docker compose down

# DB ごと作り直す
docker compose down -v && docker compose up --build

# Rails コンソール
docker compose exec web bin/rails console

# ログを見る
docker compose logs -f web
```

## 構成メモ

| 項目        | 内容                                             |
| ----------- | ------------------------------------------------ |
| Ruby        | 3.3                                              |
| Rails       | 7.1                                              |
| DB          | PostgreSQL 16                                    |
| フロント    | Hotwire (Turbo) + Tailwind CSS（Node 不要）      |
| コンテナ内  | アプリは `/workspace/todo-app` に配置             |

主なコード:

- モデル: `app/models/task.rb`
- コントローラ: `app/controllers/tasks_controller.rb`
- ビュー: `app/views/tasks/`
- ルーティング: `config/routes.rb`
