class NotePlan < ApplicationRecord
  belongs_to :note
  belongs_to :plan
end
