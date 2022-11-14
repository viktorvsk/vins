# frozen_string_literal: true

class CreateOperationCodeNames < ActiveRecord::Migration[6.1]
  def up
    execute(<<~SQL)
      CREATE MATERIALIZED VIEW operation_code_names AS (
        SELECT DISTINCT ON (meta_oper_code, meta_oper_name)
          mcode.value AS code, mname.value AS name
        FROM gov_operations
        JOIN gov_meta AS mcode ON mcode.id = gov_operations.meta_oper_code
        JOIN gov_meta AS mname ON mname.id = gov_operations.meta_oper_name
      )
    SQL
  end

  def down
    execute(<<~SQL)
      DROP MATERIALIZED VIEW operation_code_names
    SQL
  end
end
