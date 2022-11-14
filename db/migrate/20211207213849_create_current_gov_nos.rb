# frozen_string_literal: true

class CreateCurrentGovNos < ActiveRecord::Migration[6.1]
  def up
    execute(<<~SQL)
      CREATE MATERIALIZED VIEW current_gov_nos AS (
        SELECT gov_no_id, id AS gov_operation_id FROM
        (
          SELECT gov_no_id,
            id,
            (ROW_NUMBER() OVER(PARTITION BY gov_no_id ORDER BY registered_at ASC )) AS rank
          FROM gov_operations
        ) AS t
        WHERE rank = 1
      )
    SQL
  end

  def down
    execute(<<~SQL)
      DROP MATERIALIZED VIEW current_gov_nos
    SQL
  end
end
