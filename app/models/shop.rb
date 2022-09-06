class Shop < ApplicationRecord
    has_many :memos
    has_many :distance
end
