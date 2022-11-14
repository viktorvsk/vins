# frozen_string_literal: true

class CreateGovMeta < ActiveRecord::Migration[6.1]
  def change
    create_table :gov_meta do |t|
      t.string :name, null: false
      t.string :value, null: false
    end

    add_index :gov_meta, %i[name value], unique: true
  end
end
