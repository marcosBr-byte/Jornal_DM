class Category < ApplicationRecord
  include EditorialEnvironment
  validates :name, presence: true, length: { maximum: 80 }, uniqueness: { scope: :environment }
end
