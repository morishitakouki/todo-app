require "rails_helper"

RSpec.describe "Tasks", type: :request do
  describe "GET /tasks (index)" do
    before { create_list(:task, 3) }

    it "200 を返す" do
      get tasks_path
      expect(response).to have_http_status(:ok)
    end

    it "filter=active でも 200 を返す" do
      get tasks_path(filter: "active")
      expect(response).to have_http_status(:ok)
    end

    it "filter=completed でも 200 を返す" do
      get tasks_path(filter: "completed")
      expect(response).to have_http_status(:ok)
    end

    it "不正な filter は all 扱いで 200 を返す" do
      get tasks_path(filter: "bogus")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /tasks/:id/edit (edit)" do
    it "200 を返す" do
      task = create(:task)
      get edit_task_path(task)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /tasks (create)" do
    context "有効なパラメータ" do
      let(:valid_params) { { task: { title: "牛乳を買う", priority: "high" } } }

      it "タスクを 1 件作成する" do
        expect { post tasks_path, params: valid_params }.to change(Task, :count).by(1)
      end

      it "一覧へリダイレクトする" do
        post tasks_path, params: valid_params
        expect(response).to redirect_to(tasks_path(filter: "all"))
      end
    end

    context "無効なパラメータ" do
      let(:invalid_params) { { task: { title: "" } } }

      it "タスクを作成しない" do
        expect { post tasks_path, params: invalid_params }.not_to change(Task, :count)
      end

      it "422 を返す" do
        post tasks_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "Turbo Stream リクエスト" do
      it "turbo_stream で応答する" do
        post tasks_path, params: { task: { title: "資料作成" } },
                         headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end
  end

  describe "PATCH /tasks/:id (update)" do
    let(:task) { create(:task, title: "旧タイトル") }

    it "タスクを更新して一覧へリダイレクトする" do
      patch task_path(task), params: { task: { title: "新タイトル" } }
      expect(response).to redirect_to(tasks_path(filter: "all"))
      expect(task.reload.title).to eq("新タイトル")
    end

    it "無効なパラメータでは 422 を返し更新しない" do
      patch task_path(task), params: { task: { title: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(task.reload.title).to eq("旧タイトル")
    end
  end

  describe "PATCH /tasks/:id/toggle (toggle)" do
    it "完了状態を反転する" do
      task = create(:task, completed: false)
      patch toggle_task_path(task)
      expect(task.reload.completed).to be(true)

      patch toggle_task_path(task)
      expect(task.reload.completed).to be(false)
    end
  end

  describe "DELETE /tasks/:id (destroy)" do
    it "タスクを削除して一覧へリダイレクトする" do
      task = create(:task)
      expect { delete task_path(task) }.to change(Task, :count).by(-1)
      expect(response).to redirect_to(tasks_path(filter: "all"))
    end
  end
end
