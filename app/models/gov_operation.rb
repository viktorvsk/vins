# frozen_string_literal: true

class GovOperation < ApplicationRecord
  MAPPING = {
    'raw_person' => 'person',
    'raw_oper_code' => 'operation_code',
    'raw_oper_name' => 'operation_name',
    'raw_dep_code' => 'department_code',
    'raw_dep' => 'department_name',
    'raw_color' => 'color',
    'raw_kind' => 'kind',
    'raw_body' => 'body',
    'raw_purpose' => 'purpose',
    'raw_fuel' => 'fuel',
    'raw_vin' => 'vin',
    'raw_gov_no' => 'gov_no',
    'raw_gov_brand' => 'brand',
    'raw_gov_model' => 'model',
    'raw_gov_koatuu' => 'koatuu',
  }.freeze

  belongs_to :gov_dataset_upload

  belongs_to :vin, optional: true
  belongs_to :gov_no, optional: true
  belongs_to :gov_brand, optional: true
  belongs_to :gov_model, optional: true
  belongs_to :gov_koatuu, optional: true

  belongs_to :person, -> { where(name: 'person') }, class_name: GovMetum.name, foreign_key: :meta_person, optional: true
  belongs_to :oper_code, lambda {
                           where(name: 'oper_code')
                         }, class_name: GovMetum.name, foreign_key: :meta_oper_code, optional: true
  belongs_to :oper_name, lambda {
                           where(name: 'oper_name')
                         }, class_name: GovMetum.name, foreign_key: :meta_oper_name, optional: true
  belongs_to :dep_code, lambda {
                          where(name: 'dep_code')
                        }, class_name: GovMetum.name, foreign_key: :meta_dep_code, optional: true
  belongs_to :dep, -> { where(name: 'dep') }, class_name: GovMetum.name, foreign_key: :meta_dep, optional: true
  belongs_to :color, -> { where(name: 'color') }, class_name: GovMetum.name, foreign_key: :meta_color, optional: true
  belongs_to :kind, -> { where(name: 'kind') }, class_name: GovMetum.name, foreign_key: :meta_kind, optional: true
  belongs_to :body, -> { where(name: 'body') }, class_name: GovMetum.name, foreign_key: :meta_body, optional: true
  belongs_to :purpose, lambda {
                         where(name: 'purpose')
                       }, class_name: GovMetum.name, foreign_key: :meta_purpose, optional: true
  belongs_to :fuel, -> { where(name: 'fuel') }, class_name: GovMetum.name, foreign_key: :meta_fuel, optional: true

  scope :with_values_preloaded, lambda {
    associations = %i[vin gov_no gov_brand gov_model gov_koatuu person oper_code oper_name dep_code dep color kind body purpose fuel]
    to_select = [
      'gov_meta.value AS raw_person',
      'oper_codes_gov_operations.value AS raw_oper_code',
      'oper_names_gov_operations.value AS raw_oper_name',
      'dep_codes_gov_operations.value AS raw_dep_code',
      'deps_gov_operations.value AS raw_dep',
      'colors_gov_operations.value AS raw_color',
      'kinds_gov_operations.value AS raw_kind',
      'bodies_gov_operations.value AS raw_body',
      'purposes_gov_operations.value AS raw_purpose',
      'fuels_gov_operations.value AS raw_fuel',
      'vins.name AS raw_vin',
      'gov_nos.name AS raw_gov_no',
      'gov_brands.name AS raw_gov_brand',
      'gov_models.name AS raw_gov_model',
      'gov_koatuus.name AS raw_gov_koatuu'
    ]
    left_joins(associations).select(to_select.join(', '))
  }

  def as_json
    super.except(:id).deep_transform_keys { |k, _v| MAPPING[k] }.compact
  end
end
