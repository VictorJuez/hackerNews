class CreateSubmissions < ActiveRecord::Migration[5.1]
  def change
    create_table :submissions do |t|
      t.string :title
      t.string :url
      t.string :text
      t.references :user, index: true, foreign_key: true
      t.timestamps
    end
  end
end
