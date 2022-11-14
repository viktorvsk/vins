# frozen_string_literal: true

class CreateGovNos < ActiveRecord::Migration[6.1]
  def change
    create_table :gov_nos do |t|
      t.string :name, null: false
    end

    add_index :gov_nos, :name, unique: true
  end
end
