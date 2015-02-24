class CreateCustomThemes < ActiveRecord::Migration
  def change
    create_table :custom_themes do |t|
      t.string :color
      t.string :digest

      t.timestamps null: false
    end
  end
end
