class Event < ApplicationRecord
  include EditorialEnvironment
  has_one_attached :image
  has_many :photo_submissions, dependent: :nullify
  validates :title, :starts_at, :location, presence: true
  validates :title, :location, :category, length: { maximum: 160 }
  validates :description, length: { maximum: 5000 }
end
