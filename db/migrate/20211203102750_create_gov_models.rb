# frozen_string_literal: true

class CreateGovModels < ActiveRecord::Migration[6.1]
  def change
    create_table :gov_models do |t|
      t.string :name, null: false
    end

    add_index :gov_models, :name, unique: true
  end
end
