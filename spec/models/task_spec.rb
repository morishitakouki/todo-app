require "rails_helper"

RSpec.describe Task, type: :model do
  describe "ファクトリ" do
    it "デフォルトのファクトリが有効である" do
      expect(build(:task)).to be_valid
    end
  end

  describe "バリデーション" do
    it "title が無いと無効" do
      task = build(:task, title: nil)
      expect(task).to be_invalid
      expect(task.errors[:title]).to be_present
    end

    it "title が空文字だと無効" do
      expect(build(:task, title: "")).to be_invalid
    end

    it "title が 200 文字までは有効" do
      expect(build(:task, title: "a" * 200)).to be_valid
    end

    it "title が 201 文字だと無効" do
      expect(build(:task, title: "a" * 201)).to be_invalid
    end

    it "notes が 2000 文字までは有効" do
      expect(build(:task, notes: "a" * 2_000)).to be_valid
    end

    it "notes が 2001 文字だと無効" do
      expect(build(:task, notes: "a" * 2_001)).to be_invalid
    end
  end

  describe "priority enum" do
    it "low / medium / high を持つ" do
      expect(described_class.priorities.keys).to contain_exactly("low", "medium", "high")
    end

    it "デフォルトは medium" do
      expect(described_class.new.priority).to eq("medium")
    end

    it "シンボルで優先度を設定できる" do
      task = build(:task, priority: :high)
      expect(task).to be_high
    end
  end

  describe "スコープ" do
    let!(:active_task)    { create(:task, completed: false) }
    let!(:completed_task) { create(:task, :completed) }

    describe ".active" do
      it "未完了のタスクだけを返す" do
        expect(described_class.active).to contain_exactly(active_task)
      end
    end

    describe ".completed" do
      it "完了済みのタスクだけを返す" do
        expect(described_class.completed).to contain_exactly(completed_task)
      end
    end

    describe ".ordered" do
      it "未完了タスクを完了タスクより前に並べる" do
        expect(described_class.ordered.to_a).to eq([ active_task, completed_task ])
      end

      it "未完了のうち期限が近いものを先に並べる" do
        soon = create(:task, completed: false, due_on: Date.current + 1)
        later = create(:task, completed: false, due_on: Date.current + 10)
        ordered = described_class.active.ordered.to_a
        expect(ordered.index(soon)).to be < ordered.index(later)
      end

      it "期限ありを期限なしより前に並べる" do
        with_due = create(:task, completed: false, due_on: Date.current + 3)
        without_due = create(:task, completed: false, due_on: nil)
        ordered = described_class.active.ordered.to_a
        expect(ordered.index(with_due)).to be < ordered.index(without_due)
      end
    end
  end

  describe "#overdue?" do
    it "期限が過去で未完了なら true" do
      expect(build(:task, :overdue)).to be_overdue
    end

    it "期限が今日なら false" do
      expect(build(:task, completed: false, due_on: Date.current)).not_to be_overdue
    end

    it "期限が過去でも完了済みなら false" do
      expect(build(:task, completed: true, due_on: Date.current - 1)).not_to be_overdue
    end

    it "期限が無ければ false" do
      expect(build(:task, due_on: nil)).not_to be_overdue
    end
  end

  describe "#due_soon?" do
    it "期限が今日から 2 日以内で未完了なら true" do
      expect(build(:task, completed: false, due_on: Date.current + 2)).to be_due_soon
    end

    it "期限が今日なら true" do
      expect(build(:task, completed: false, due_on: Date.current)).to be_due_soon
    end

    it "期限が 3 日後なら false" do
      expect(build(:task, completed: false, due_on: Date.current + 3)).not_to be_due_soon
    end

    it "期限が過去（期限切れ）なら false" do
      expect(build(:task, completed: false, due_on: Date.current - 1)).not_to be_due_soon
    end

    it "完了済みなら false" do
      expect(build(:task, completed: true, due_on: Date.current + 1)).not_to be_due_soon
    end
  end
end
