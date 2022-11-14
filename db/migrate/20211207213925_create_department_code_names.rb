# frozen_string_literal: true

class CreateDepartmentCodeNames < ActiveRecord::Migration[6.1]
  def up
    execute(<<~SQL)
      CREATE MATERIALIZED VIEW department_code_names AS (
        SELECT DISTINCT ON (meta_dep_code, meta_dep)
          mcode.value AS code, mname.value AS name
        FROM gov_operations
        JOIN gov_meta AS mcode ON mcode.id = gov_operations.meta_dep_code
        JOIN gov_meta AS mname ON mname.id = gov_operations.meta_dep
      )
    SQL
  end

  def down
    execute(<<~SQL)
      DROP MATERIALIZED VIEW department_code_names
    SQL
  end
end
