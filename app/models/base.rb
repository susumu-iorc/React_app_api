class Base < ApplicationRecord
  belongs_to :users, optional: true
end
