# bin/rails db:seed で初期データを投入します（冪等にするため一度全削除します）。
Task.destroy_all

Task.create!([
  { title: "牛乳と卵を買う",            notes: "スーパーで。卵はLサイズ。",                   priority: :low,    due_on: Date.current + 1 },
  { title: "請求書を送付する",          notes: "今月分のクライアント向け請求書。",            priority: :high,   due_on: Date.current - 1 },
  { title: "歯医者の予約を取る",                                                              priority: :medium, due_on: Date.current + 5 },
  { title: "プレゼン資料を仕上げる",    notes: "来週の定例向け。スライド10枚程度。",          priority: :high,   due_on: Date.current + 2 },
  { title: "Rails のドキュメントを読む", notes: "Hotwire(Turbo) の章をひと通り。",            priority: :low },
  { title: "ランニング 5km",                                                                  priority: :low,    completed: true },
  { title: "図書館に本を返却する",      notes: "延長は不可。",                                priority: :medium, completed: true }
])

puts "Seeded #{Task.count} tasks."
