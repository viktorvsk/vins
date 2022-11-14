# frozen_string_literal: true

class CreateGovOperations < ActiveRecord::Migration[6.1]
  def change
    create_table :gov_operations do |t|
      t.belongs_to :gov_dataset_upload

      t.integer :vin_id, limit: 4 # vin
      t.integer :gov_no_id, limit: 4 # n_reg_new
      t.integer :gov_brand_id, limit: 4 # brand
      t.integer :gov_model_id, limit: 4 # model
      t.integer :gov_koatuu_id, limit: 4 # reg_addr_koatuu

      t.integer :meta_person, limit: 2
      t.integer :meta_oper_code, limit: 2
      t.integer :meta_oper_name, limit: 2
      t.integer :meta_dep_code, limit: 2
      t.integer :meta_dep, limit: 2
      t.integer :meta_color, limit: 2
      t.integer :meta_kind, limit: 2
      t.integer :meta_body, limit: 2
      t.integer :meta_purpose, limit: 2
      t.integer :meta_fuel, limit: 2

      t.integer :make_year, limit: 4
      t.integer :capacity, limit: 4
      t.integer :own_weight, limit: 4
      t.integer :total_weight, limit: 4

      t.date :registered_at # d_reg
    end
  end
end
