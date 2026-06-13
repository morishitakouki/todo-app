class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string  :title,     null: false
      t.text    :notes
      t.boolean :completed, null: false, default: false
      t.integer :priority,  null: false, default: 1
      t.date    :due_on

      t.timestamps
    end

    add_index :tasks, :completed
    add_index :tasks, :priority
    add_index :tasks, :due_on
  end
end
