# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :uid, null: false
      t.string :display_name
      t.string :email, null: false
      t.string :photo_url

      t.timestamps
    end

    add_index :users, :uid, unique: true
    add_index :users, :email, unique: true
  end
end
