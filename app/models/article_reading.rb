class ArticleReading < ApplicationRecord
  belongs_to :article
  def self.record(article, visitor_digest)
    transaction do
      inserted = insert_all([ { article_id: article.id, visitor_digest: visitor_digest, read_on: Date.current } ], unique_by: :index_unique_daily_article_reading, returning: [ :id ])
      if inserted.rows.any?
        Article.where(id: article.id).update_all("reads_count = reads_count + 1")
        article.reads_count += 1
      end
    end
  end
end
