# frozen_string_literal: true

class CreateBrandModels < ActiveRecord::Migration[6.1]
  def up
    execute(<<~SQL)
      CREATE MATERIALIZED VIEW brand_models AS (
        SELECT DISTINCT ON (gov_brand_id, gov_model_id)
          gov_brands.name AS brand, gov_models.name AS model
        FROM gov_operations
        JOIN gov_brands ON gov_brands.id = gov_operations.gov_brand_id
        JOIN gov_models ON gov_models.id = gov_operations.gov_model_id
      )
    SQL
  end

  def down
    execute(<<~SQL)
      DROP MATERIALIZED VIEW brand_models
    SQL
  end
end
