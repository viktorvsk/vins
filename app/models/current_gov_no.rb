# frozen_string_literal: true

class CurrentGovNo < ApplicationRecord
  belongs_to :gov_operation
  belongs_to :gov_no
end
