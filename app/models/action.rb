class Action < ApplicationRecord
	belongs_to :post
	has_and_belongs_to_many :users
	has_one :share
end
