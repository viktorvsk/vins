# frozen_string_literal: true

class CreateVins < ActiveRecord::Migration[6.1]
  def change
    create_table :vins do |t|
      t.string :name, null: false
    end

    add_index :vins, :name, unique: true
  end
end
