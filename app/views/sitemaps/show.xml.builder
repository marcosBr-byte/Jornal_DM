xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  [ root_url, articles_url, escola_url, agenda_url, fect_url, fect_articles_url, fect_agenda_url ].each do |url|
    xml.url { xml.loc url }
  end
  @articles.each do |article|
    xml.url do
      xml.loc article.environment == "fect" ? fect_article_url(article) : article_url(article)
      xml.lastmod article.updated_at.iso8601
    end
  end
end
