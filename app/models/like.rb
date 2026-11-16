class Like < ApplicationRecord
  belongs_to :article
  validates :visitor_digest, presence: true, uniqueness: { scope: :article_id }
end
