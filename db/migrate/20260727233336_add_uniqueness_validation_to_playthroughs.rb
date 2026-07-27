# frozen_string_literal: true

class AddUniquenessValidationToPlaythroughs < ActiveRecord::Migration[8.1]
  def change
    add_index :playthroughs, %i[name user_id], unique: true
  end
end
