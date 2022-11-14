# frozen_string_literal: true

class CreateGovBrands < ActiveRecord::Migration[6.1]
  def change
    create_table :gov_brands do |t|
      t.string :name, null: false
    end

    add_index :gov_brands, :name, unique: true
  end
end
