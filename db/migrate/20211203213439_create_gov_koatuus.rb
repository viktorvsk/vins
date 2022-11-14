# frozen_string_literal: true

class CreateGovKoatuus < ActiveRecord::Migration[6.1]
  def change
    create_table :gov_koatuus do |t|
      t.string :name, null: false
    end

    add_index :gov_koatuus, :name, unique: true
  end
end
