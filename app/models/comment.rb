class Comment < ApplicationRecord
  before_validation :filter_language
  belongs_to :article
  enum :status, { pending: "pending", approved: "approved", rejected: "rejected" }, validate: true
  validates :body, presence: true, length: { maximum: 3000 }
  validates :name, length: { maximum: 80 }
  def filter_language
    self.name = CommentLanguageFilter.call(name)
    self.body = CommentLanguageFilter.call(body)
  end
  def display_name
    CommentLanguageFilter.call(name).presence || "Leitor anônimo"
  end
  def display_body
    CommentLanguageFilter.call(body)
  end
end
