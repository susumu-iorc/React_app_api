class Memo < ApplicationRecord
  belongs_to :users, optional: true
end
  