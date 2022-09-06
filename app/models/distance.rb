class Distance < ApplicationRecord
  belongs_to :users, optional: true
end
