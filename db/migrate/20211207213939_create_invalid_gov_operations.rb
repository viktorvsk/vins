# frozen_string_literal: true

class CreateInvalidGovOperations < ActiveRecord::Migration[6.1]
  def up
    execute(<<~SQL)
      CREATE MATERIALIZED VIEW invalid_gov_operations AS (
        SELECT id AS gov_operation_id
        FROM gov_operations
        WHERE gov_no_id IS NULL OR
              gov_brand_id IS NULL OR
              gov_model_id IS NULL OR
              gov_koatuu_id IS NULL OR
              meta_person IS NULL OR
              meta_oper_code IS NULL OR
              meta_oper_name IS NULL OR
              meta_dep_code IS NULL OR
              meta_dep IS NULL OR
              meta_color IS NULL OR
              meta_kind IS NULL OR
              meta_body IS NULL OR
              meta_purpose IS NULL OR
              meta_fuel IS NULL OR
              make_year IS NULL OR
              capacity IS NULL OR
              own_weight IS NULL OR
              total_weight IS NULL OR
              registered_at IS NULL
        UNION
        SELECT id AS gov_operation_id FROM gov_operations WHERE make_year < 1900 OR make_year > 2021
        UNION
        SELECT id AS gov_operation_id FROM gov_operations WHERE capacity < 100 OR capacity > 20000
        UNION
        SELECT id AS gov_operation_id FROM gov_operations WHERE own_weight < 50 OR own_weight > 10000
        UNION
        SELECT id AS gov_operation_id FROM gov_operations WHERE total_weight < 50 OR total_weight > 10000
      )
    SQL
  end

  def down
    execute(<<~SQL)
      DROP MATERIALIZED VIEW invalid_gov_operations
    SQL
  end
end
