require "test_helper"
class NewsroomTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @admin = User.create!(email: "newsroom-admin@example.test", password: "NewsroomPassword123!", admin: true)
    @article = @admin.articles.create!(title: "Tecnologia na nossa escola", body: "Uma descoberta", author: "Equipe", category: "Tecnologia", featured: true, status: :published)
    @fect = @admin.articles.create!(title: "Projeto FECT", body: "Conhecimento", author: "Equipe", category: "Ciência", featured: true, environment: "fect", status: :published)
  end
  test "new navigation featured headlines categories and rankings stay scoped" do
    get root_path
    assert_response :success
    assert_select "header nav a", count: 4
    assert_select "header nav a", text: "Início"
    assert_select "header nav a", text: "Últimas notícias"
    assert_select "header nav a", text: "Agenda"
    assert_select "[data-carousel-interval-value='5000']"
    assert_select ".ticker-group a", text: /Tecnologia na nossa escola/, count: 2
    assert_select ".category-tab", text: "Tecnologia"
    assert_select ".brand-hero img[src$='.png']", count: 1
    assert_select ".featured-slide h3", text: @fect.title, count: 0
    get fect_path
    assert_response :success
    assert_select "header nav a", count: 3
    assert_select ".featured-slide h3", text: @fect.title
    assert_select ".featured-slide h3", text: @article.title, count: 0
  end
  test "reading increments once per visitor and day without locking editorial changes" do
    original_lock = @article.lock_version
    assert_difference "ArticleReading.count", 1 do
      get article_path(@article)
      assert_response :success
    end
    assert_equal 1, @article.reload.reads_count
    assert_equal original_lock, @article.lock_version
    assert_no_difference "ArticleReading.count" do
      get article_path(@article)
    end
    assert_equal 1, @article.reload.reads_count
    travel 1.day do
      get article_path(@article)
      assert_equal 2, @article.reload.reads_count
    end
  end
  test "session does not expire after inactivity while the browser session remains" do
    post user_session_path, params: { user: { email: @admin.email, password: "NewsroomPassword123!" } }
    get admin_root_path
    assert_response :success
    assert_select ".verification-overlay", count: 1
    travel 3.hours do
      get admin_articles_path
      assert_response :success
      assert_select ".verification-overlay", count: 0
    end
    delete destroy_user_session_path
    get admin_articles_path
    assert_redirected_to new_user_session_path
  end
  test "most commented ranking counts approved comments only and separates portals" do
    2.times { @article.comments.create!(body: "Uma ótima iniciativa", status: :approved) }
    @article.comments.create!(body: "Oculto", status: :rejected)
    @fect.comments.create!(body: "Projeto interessante", status: :approved)
    draft = @admin.articles.create!(title: "Rascunho com comentários", body: "Privado", category: "Educação", author: "Equipe")
    4.times { draft.comments.create!(body: "Registro anterior", status: :approved) }
    get root_path
    assert_select ".most-commented h2", text: /Mais comentadas/
    assert_select ".most-commented h3", text: @article.title
    assert_select ".most-commented small", text: "2 comentários"
    assert_select ".most-commented h3", text: @fect.title, count: 0
    assert_select ".most-commented h3", text: draft.title, count: 0
    @article.comments.approved.first.update!(status: :rejected)
    get articles_path
    assert_select ".most-commented small", text: "1 comentário"
    get fect_path
    assert_select ".most-commented h3", text: @fect.title
    assert_select ".most-commented h3", text: @article.title, count: 0
  end
end
