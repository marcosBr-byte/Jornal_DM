require "test_helper"
class LiveUpdatesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @user = User.create!(email: "live-updates@example.test", password: "LiveUpdatesPassword123!", admin: true)
    @article = @user.articles.create!(title: "Notícia ao vivo", body: "Conteúdo", category: "Tecnologia", author: "Equipe", status: :published)
  end
  test "background article refreshes return current comments without creating readings" do
    @article.comments.create!(body: "Uma boa descoberta", status: :approved)
    assert_no_difference "ArticleReading.count" do
      get article_path(@article), headers: { "X-Live-Update" => "true" }
    end
    assert_response :success
    assert_includes response.headers["Cache-Control"], "no-store"
    assert_select "#article-comments[data-live-region]", text: /Uma boa descoberta/
    assert_select "#article-content[data-live-region]"
    assert_equal 0, @article.reload.reads_count
  end
  test "newsroom and panel expose refresh regions without replacing the editor" do
    get root_path
    assert_select "#news-ticker[data-live-ticker][data-live-region]"
    assert_select "#ultimas-noticias[data-live-region]"
    sign_in @user
    get admin_root_path
    assert_select "#admin-metrics[data-live-region]"
    assert_select "#managePanel[data-live-region]"
    assert_select "#editorPanel[data-live-region]", count: 0
  end
end
