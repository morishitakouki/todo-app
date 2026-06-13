class Task < ApplicationRecord
  # priority: low(0) / medium(1) / high(2)。DB のデフォルトは medium。
  enum :priority, { low: 0, medium: 1, high: 2 }

  validates :title, presence: true, length: { maximum: 200 }
  validates :notes, length: { maximum: 2_000 }

  scope :active,    -> { where(completed: false) }
  scope :completed, -> { where(completed: true) }

  # 未完了 → 完了 の順。未完了内では「期限が近い → 優先度が高い → 新しい」順に並べる。
  scope :ordered, -> {
    order(
      Arel.sql(<<~SQL.squish)
        completed ASC,
        CASE WHEN due_on IS NULL THEN 1 ELSE 0 END ASC,
        due_on ASC,
        priority DESC,
        created_at DESC
      SQL
    )
  }

  def overdue?
    due_on.present? && !completed? && due_on < Date.current
  end

  def due_soon?
    due_on.present? && !completed? && due_on >= Date.current && due_on <= Date.current + 2
  end
end
