class SiteSetting < ApplicationRecord
  include EditorialEnvironment
  has_one_attached :logo
  validates :environment, uniqueness: true
end
