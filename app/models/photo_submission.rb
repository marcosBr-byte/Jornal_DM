class PhotoSubmission < ApplicationRecord
  include EditorialEnvironment
  belongs_to :event, optional: true
  belongs_to :article, optional: true
  has_one_attached :image
  validate :matching_article_environment
  def matching_article_environment
    errors.add(:event, "deve pertencer ao mesmo ambiente") if event && event.environment != environment
    errors.add(:article, "deve pertencer ao mesmo ambiente") if article && article.environment != environment
  end
  enum :status, { pending: "pending", approved: "approved", rejected: "rejected", published: "published" }, validate: true
  validates :contributor, length: { maximum: 80 }
  validates :caption, length: { maximum: 220 }
  validates :album, length: { maximum: 120 }
  validate :acceptable_image
  def display_contributor
    contributor.presence || "Colaborador anônimo"
  end
  private
  def acceptable_image
    errors.add(:image, "é obrigatória") unless image.attached?
    return unless image.attached?
    errors.add(:image, "deve ser JPEG, PNG ou WebP de até 10 MB") unless image.content_type.in?(Article::COVER_CONTENT_TYPES) && image.byte_size <= 10.megabytes
  end
end
