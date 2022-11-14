# frozen_string_literal: true

class ProcessGovDataset < ApplicationJob
  COLUMNS = %w[person reg_addr_koatuu oper_code oper_name d_reg dep_code dep brand model vin make_year color kind body
               purpose fuel capacity own_weight total_weight n_reg_new].freeze
  SMALL_COLUMNS = %w[person color kind body purpose fuel oper_code oper_name dep_code dep].freeze
  TABLE_COLUMNS = {
    vins: :vin,
    gov_nos: :n_reg_new,
    gov_brands: :brand,
    gov_models: :model,
    gov_koatuus: :reg_addr_koatuu,
  }.freeze

  CASE_REGISTERED_AT_DATE_OR_NULL = <<~SQL.chomp
    CASE
      WHEN t.d_reg ~ '^\\d{4}-\\d{2}-\\d{2}$' THEN TO_DATE(t.d_reg, 'YYYY-MM-DD')
      WHEN t.d_reg ~ '^\\d{2}\\.\\d{2}\\.\\d{4}$' THEN TO_DATE(t.d_reg, 'DD-MM-YYYY')
      ELSE NULL
    END
  SQL

  def perform(file)
    headers = CSV.foreach(file.path, 'r', col_sep: ';').detect(&:any?).map(&:downcase)

    filename = File.basename(file.path)

    raise 'Unexpected Headers' if headers - COLUMNS != ['vin'] && headers - COLUMNS != []
    return 'File Was Already Uploaded' if GovDatasetUpload.where(filename: filename).exists?

    gov_dataset_upload = GovDatasetUpload.create(filename: filename, status: 'in_progress')

    sql = [
      create_temp_table,
      copy_from_csv_to_temp_table(file.path, headers),
      clean_temp_table,
      insert_gov_meta,
      insert_table_meta(headers),
      insert_gov_operations(headers, gov_dataset_upload.id),
      drop_temp_table
    ].flatten.join(";\n\n")

    gov_dataset_upload.update(status: 'completed')

    # byebug

    ActiveRecord::Base.connection.execute(sql)
  end

  private

  def create_temp_table
    <<~SQL
      CREATE TABLE raw_data (
        person character varying,
        reg_addr_koatuu character varying,
        oper_code character varying,
        oper_name character varying,
        d_reg character varying,
        dep_code character varying,
        dep character varying,
        brand character varying,
        model character varying,
        make_year character varying,
        color character varying,
        kind character varying,
        body character varying,
        purpose character varying,
        fuel character varying,
        capacity character varying,
        own_weight character varying,
        total_weight character varying,
        n_reg_new character varying,
        vin character varying
      )
    SQL
  end

  def copy_from_csv_to_temp_table(file_path, headers)
    <<~SQL
      COPY raw_data(#{headers.join(', ')})
      FROM '#{file_path}'
      DELIMITER ';'
      CSV HEADER
    SQL
  end

  def clean_temp_table
    <<~SQL
      DELETE
      FROM raw_data AS t
      WHERE (#{CASE_REGISTERED_AT_DATE_OR_NULL}) <= (SELECT MAX(registered_at) FROM gov_operations)
    SQL
  end

  def insert_gov_meta
    <<~SQL
      INSERT INTO gov_meta(name, value)
        SELECT 'person' AS option, person AS value FROM raw_data GROUP BY person
        UNION
        SELECT 'color' AS option, color AS value FROM raw_data GROUP BY color
        UNION
        SELECT 'kind' AS option, kind AS value FROM raw_data GROUP BY kind
        UNION
        SELECT 'body' AS option, body AS value FROM raw_data GROUP BY body
        UNION
        SELECT 'purpose' AS option, purpose AS value FROM raw_data GROUP BY purpose
        UNION
        SELECT 'fuel' AS option, fuel AS value FROM raw_data GROUP BY fuel
        UNION
        SELECT 'oper_code' AS option, oper_code AS value FROM raw_data GROUP BY oper_code
        UNION
        SELECT 'oper_name' AS option, oper_name AS value FROM raw_data GROUP BY oper_name
        UNION
        SELECT 'dep_code' AS option, dep_code AS value FROM raw_data GROUP BY dep_code
        UNION
        SELECT 'dep' AS option, dep AS value FROM raw_data GROUP BY dep
      ON CONFLICT DO NOTHING
    SQL
  end

  def insert_in_meta_table(table, column)
    <<~SQL
      INSERT INTO #{table}(name)
        SELECT #{column} FROM raw_data GROUP BY #{column}
      ON CONFLICT DO NOTHING
    SQL
  end

  def insert_table_meta(headers)
    TABLE_COLUMNS.select do |_table, column|
      headers.include?(column.to_s)
    end.map { |table, column| insert_in_meta_table(table, column) }
  end

  def insert_gov_operations(headers, gov_dataset_upload_id)
    with_vin = headers.include?('vin')
    columns_to_insert = %w[gov_dataset_upload_id gov_no_id gov_brand_id gov_model_id gov_koatuu_id meta_person
                           meta_oper_code meta_oper_name meta_dep_code meta_dep meta_color meta_kind meta_body meta_purpose meta_fuel capacity own_weight total_weight make_year registered_at]
    columns_to_insert << 'vin_id' if with_vin

    <<~SQL
      INSERT INTO gov_operations(#{columns_to_insert.join(', ')})
        SELECT
          #{gov_dataset_upload_id} AS gov_dataset_upload_id,
          gov_nos.id AS gov_no_id,
          gov_brands.id AS gov_brand_id,
          gov_models.id AS gov_model_id,
          gov_koatuus.id AS gov_koatuu_id,
          meta_person.id AS meta_person,
          meta_oper_code.id AS meta_oper_code,
          meta_oper_name.id AS meta_oper_name,
          meta_dep_code.id AS meta_dep_code,
          meta_dep.id AS meta_dep,
          meta_color.id AS meta_color,
          meta_kind.id AS meta_kind,
          meta_body.id AS meta_body,
          meta_purpose.id AS meta_purpose,
          meta_fuel.id AS meta_fuel,
          (#{case_int_or_null('capacity')}) AS capacity,
          (#{case_int_or_null('own_weight')}) AS own_weight,
          (#{case_int_or_null('total_weight')}) AS total_weight,
          (#{case_int_or_null('make_year')}) AS make_year,
          (#{CASE_REGISTERED_AT_DATE_OR_NULL}) AS registered_at#{with_vin ? ",\n    vins.id AS vin_id\n" : ''}
        FROM raw_data AS t
        JOIN gov_models ON gov_models.name = t.model#{with_vin ? "\n  JOIN vins ON vins.name = t.vin\n" : ''}
        JOIN gov_brands ON gov_brands.name = t.brand
        JOIN gov_nos ON gov_nos.name = t.n_reg_new
        JOIN gov_koatuus ON gov_koatuus.name = t.reg_addr_koatuu
        JOIN gov_meta AS meta_person ON meta_person.name = 'person' AND meta_person.value = t.person
        JOIN gov_meta AS meta_oper_code ON meta_oper_code.name = 'oper_code' AND meta_oper_code.value = t.oper_code
        JOIN gov_meta AS meta_oper_name ON meta_oper_name.name = 'oper_name' AND meta_oper_name.value = t.oper_name
        JOIN gov_meta AS meta_dep_code ON meta_dep_code.name = 'dep_code' AND meta_dep_code.value = t.dep_code
        JOIN gov_meta AS meta_dep ON meta_dep.name = 'dep' AND meta_dep.value = t.dep
        JOIN gov_meta AS meta_color ON meta_color.name = 'color' AND meta_color.value = t.color
        JOIN gov_meta AS meta_kind ON meta_kind.name = 'kind' AND meta_kind.value = t.kind
        JOIN gov_meta AS meta_body ON meta_body.name = 'body' AND meta_body.value = t.body
        JOIN gov_meta AS meta_purpose ON meta_purpose.name = 'purpose' AND meta_purpose.value = t.purpose
        JOIN gov_meta AS meta_fuel ON meta_fuel.name = 'fuel' AND meta_fuel.value = t.fuel
      ON CONFLICT DO NOTHING
    SQL
  end

  def drop_temp_table
    # return []

    <<~SQL
      DROP TABLE raw_data
    SQL
  end

  def case_int_or_null(column)
    <<~SQL.chomp
      CASE WHEN t.#{column} ~ '^\\d+$' THEN t.#{column}::int ELSE NULL END
    SQL
  end
end
