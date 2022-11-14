# frozen_string_literal: true

class CreateGovDatasetUploads < ActiveRecord::Migration[6.1]
  def change
    create_table :gov_dataset_uploads do |t|
      t.string :filename, null: false
      t.string :status, null: false
      t.json :extra
      t.timestamps
    end

    add_index :gov_dataset_uploads, :filename
  end
end
