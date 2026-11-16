class Article < ApplicationRecord
  include EditorialEnvironment
  has_many :photo_submissions, dependent: :nullify
  has_many :article_readings, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  CATEGORIES = [ "Educação", "Tecnologia", "Ciência", "Eventos", "Esportes", "Cultura", "Projetos", "Entrevistas", "Comunidade", "Avisos" ].freeze
  COVER_CONTENT_TYPES = %w[image/jpeg image/png image/webp].freeze
  BODY_TAGS = %w[div p br h2 h3 h4 strong b em i s del u ul ol li blockquote pre code a].freeze
  BODY_ATTRIBUTES = %w[href].freeze
  belongs_to :user
  has_one_attached :cover
  enum :status, { draft: 0, published: 1 }, default: :draft
  enum :body_format, { plain: 0, html: 1 }, default: :plain, prefix: true, validate: true
  before_validation :sanitize_rich_body
  validates :title, :body, :author, presence: true
  validate :visible_body
  validates :title, length: { maximum: 120 }
  validates :summary, length: { maximum: 220 }
  validate :valid_editorial_category
  validate :acceptable_cover
  before_save :stamp_publication
  scope :publicly_visible, -> { published.where(published_at: ..Time.current) }
  scope :editorial_order, -> { order(featured: :desc, published_at: :desc, id: :desc) }
  def to_param
    persisted? ? "#{id}-#{title.to_s.parameterize}" : nil
  end

  def body_text
    return body.to_s unless body_format_html?
    CGI.unescapeHTML(Loofah.fragment(body.to_s).to_text).strip
  end

  def sanitized_body
    ActionController::Base.helpers.sanitize(body.to_s, tags: BODY_TAGS, attributes: BODY_ATTRIBUTES)
  end

  def self.most_commented(environment)
    in_environment(environment).publicly_visible.joins(:comments).merge(Comment.approved)
      .select("articles.*, COUNT(comments.id) AS approved_comments_count")
      .group("articles.id").order(Arel.sql("COUNT(comments.id) DESC"), published_at: :desc, id: :desc).limit(5)
  end

  def self.category_names(environment)
    (CATEGORIES + Category.in_environment(environment).order(:name).pluck(:name)).uniq
  end

  private

  def valid_editorial_category
    names = self.class.category_names(environment)
    errors.add(:category, "não pertence ao ambiente selecionado") unless names.include?(category)
  end

  def sanitize_rich_body
    self.body = sanitized_body if body_format_html? && (body_changed? || body_format_changed?)
  end

  def visible_body
    errors.add(:body, "deve conter texto") if body_format_html? && body_text.gsub(/[[:space:]\u00a0\u200b]/, "").empty?
  end

  def stamp_publication
    self.published_at ||= Time.current if published?
  end
  def acceptable_cover
    return unless cover.attached?
    errors.add(:cover, "deve ser JPEG, PNG ou WebP") unless cover.content_type.in?(COVER_CONTENT_TYPES)
    errors.add(:cover, "deve ter até 1,5 MB") if cover.byte_size > 1.5.megabytes
  end
end
