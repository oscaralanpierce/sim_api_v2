# frozen_string_literal: true

class CreatePlaythroughs < ActiveRecord::Migration[8.1]
  def change
    create_table :playthroughs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :description

      t.timestamps
    end
  end
end
