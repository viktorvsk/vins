# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20_211_207_215_207) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'gov_brands', force: :cascade do |t|
    t.string('name', null: false)
    t.index(['name'], name: 'index_gov_brands_on_name', unique: true)
  end

  create_table 'gov_dataset_uploads', force: :cascade do |t|
    t.string('filename', null: false)
    t.string('status', null: false)
    t.json('extra')
    t.datetime('created_at', precision: 6, null: false)
    t.datetime('updated_at', precision: 6, null: false)
    t.index(['filename'], name: 'index_gov_dataset_uploads_on_filename')
  end

  create_table 'gov_koatuus', force: :cascade do |t|
    t.string('name', null: false)
    t.index(['name'], name: 'index_gov_koatuus_on_name', unique: true)
  end

  create_table 'gov_meta', force: :cascade do |t|
    t.string('name', null: false)
    t.string('value', null: false)
    t.index(%w[name value], name: 'index_gov_meta_on_name_and_value', unique: true)
  end

  create_table 'gov_models', force: :cascade do |t|
    t.string('name', null: false)
    t.index(['name'], name: 'index_gov_models_on_name', unique: true)
  end

  create_table 'gov_nos', force: :cascade do |t|
    t.string('name', null: false)
    t.index(['name'], name: 'index_gov_nos_on_name', unique: true)
  end

  create_table 'gov_operations', force: :cascade do |t|
    t.bigint('gov_dataset_upload_id')
    t.integer('vin_id')
    t.integer('gov_no_id')
    t.integer('gov_brand_id')
    t.integer('gov_model_id')
    t.integer('gov_koatuu_id')
    t.integer('meta_person', limit: 2)
    t.integer('meta_oper_code', limit: 2)
    t.integer('meta_oper_name', limit: 2)
    t.integer('meta_dep_code', limit: 2)
    t.integer('meta_dep', limit: 2)
    t.integer('meta_color', limit: 2)
    t.integer('meta_kind', limit: 2)
    t.integer('meta_body', limit: 2)
    t.integer('meta_purpose', limit: 2)
    t.integer('meta_fuel', limit: 2)
    t.integer('make_year')
    t.integer('capacity')
    t.integer('own_weight')
    t.integer('total_weight')
    t.date('registered_at')
    t.index(['gov_dataset_upload_id'], name: 'index_gov_operations_on_gov_dataset_upload_id')
  end

  create_table 'vins', force: :cascade do |t|
    t.string('name', null: false)
    t.index(['name'], name: 'index_vins_on_name', unique: true)
  end
end
