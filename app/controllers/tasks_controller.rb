class TasksController < ApplicationController
  before_action :set_filter
  before_action :set_task, only: %i[show edit update destroy toggle]

  def index
    load_collection
    @task = Task.new
  end

  # 編集をキャンセルしたときに表示行へ戻すために使う（Turbo Frame の差し戻し先）。
  def show
  end

  def create
    @task = Task.new(task_params)

    if @task.save
      load_collection
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tasks_path(filter: @filter), notice: "タスクを追加しました。" }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "new_task_form",
            partial: "tasks/form",
            locals: { task: @task, filter: @filter }
          ), status: :unprocessable_entity
        end
        format.html { load_collection; render :index, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    if @task.update(task_params)
      load_collection
      respond_to do |format|
        format.turbo_stream # update.turbo_stream.erb
        format.html { redirect_to tasks_path(filter: @filter), notice: "タスクを更新しました。" }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            helpers.dom_id(@task),
            partial: "tasks/edit_form",
            locals: { task: @task, filter: @filter }
          ), status: :unprocessable_entity
        end
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def toggle
    @task.update(completed: !@task.completed)
    load_collection
    respond_to do |format|
      format.turbo_stream # toggle.turbo_stream.erb
      format.html { redirect_to tasks_path(filter: @filter) }
    end
  end

  def destroy
    @task.destroy
    load_collection
    respond_to do |format|
      format.turbo_stream # destroy.turbo_stream.erb
      format.html { redirect_to tasks_path(filter: @filter), notice: "タスクを削除しました。" }
    end
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def set_filter
    @filter = params[:filter].presence_in(%w[all active completed]) || "all"
  end

  def load_collection
    @tasks =
      case @filter
      when "active"    then Task.active.ordered
      when "completed" then Task.completed.ordered
      else                  Task.ordered
      end

    @counts = {
      all:       Task.count,
      active:    Task.active.count,
      completed: Task.completed.count
    }
  end

  def task_params
    params.require(:task).permit(:title, :notes, :priority, :due_on, :completed)
  end
end
