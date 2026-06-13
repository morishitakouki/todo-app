FactoryBot.define do
  factory :task do
    sequence(:title) { |n| "タスク#{n}" }
    notes { nil }
    completed { false }
    priority { :medium }
    due_on { nil }

    trait :completed do
      completed { true }
    end

    trait :overdue do
      completed { false }
      due_on { Date.current - 1 }
    end

    trait :due_soon do
      completed { false }
      due_on { Date.current + 1 }
    end
  end
end
