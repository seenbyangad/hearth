class CreateMentors < ActiveRecord::Migration[8.1]
  def change
    create_table :mentors do |t|
      t.string :name
      t.string :specialty
      t.string :tagline
      t.text :system_prompt
      t.string :avatar

      t.timestamps
    end
  end
end
