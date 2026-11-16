require "application_system_test_case"
class LiveUpdatesBrowserTest < ApplicationSystemTestCase
  setup do
    @user = User.create!(email: "live-browser@example.test", password: "LiveBrowserPassword123!", admin: true)
    @article = @user.articles.create!(title: "Manchete inicial", body: "Texto da escola", category: "Educação", author: "Equipe", status: :published)
  end
  def faster_updates
    page.execute_script("document.body.setAttribute('data-live-updates-interval-value', '700')")
  end
  test "new headlines appear automatically while the logo and ticker keep running" do
    visit root_path
    faster_updates
    page.execute_script("window.liveLogo = document.querySelector('.floating-logo'); window.liveTicker = document.querySelector('#news-ticker');")
    @user.articles.create!(title: "Novidade publicada agora", body: "Uma nova história", category: "Tecnologia", author: "Equipe", status: :published)
    assert_selector ".news-card h3", text: "Novidade publicada agora", wait: 15
    assert_selector ".ticker-group a", text: /Novidade publicada agora/, wait: 15
    assert page.evaluate_script("window.liveLogo === document.querySelector('.floating-logo')")
    assert page.evaluate_script("window.liveTicker === document.querySelector('#news-ticker')")
    assert_equal "running", page.evaluate_script("getComputedStyle(document.querySelector('.ticker-track')).animationPlayState")
    assert_equal root_path, page.current_path
  end
  test "new comments and likes refresh without erasing a reader comment" do
    visit article_path(@article)
    fill_in "Comentário", with: "Estou escrevendo minha mensagem."
    faster_updates
    @article.comments.create!(body: "Comentário recebido de outro leitor", status: :approved)
    @article.likes.create!(visitor_digest: "another-signed-reader")
    assert_selector "#article-comments", text: "Comentário recebido de outro leitor", wait: 15
    assert_selector "[data-engagement-target=count]", text: "1", wait: 15
    assert_field "Comentário", with: "Estou escrevendo minha mensagem."
    assert_equal 1, @article.reload.reads_count
  end
  test "dashboard refreshes publications without replacing unsaved editor text" do
    visit new_user_session_path
    fill_in "E-MAIL", with: @user.email
    fill_in "SENHA", with: "LiveBrowserPassword123!"
    click_on "Entrar no painel →"
    assert_selector "#editorPanel", wait: 15
    fill_in "TÍTULO DA NOTÍCIA *", with: "Rascunho que ainda estou escrevendo"
    faster_updates
    @user.articles.create!(title: "Publicação recebida de outra aba", body: "Texto novo", category: "Cultura", author: "Equipe", status: :published)
    assert_selector "#managePanel", text: "Publicação recebida de outra aba", wait: 15
    assert_field "TÍTULO DA NOTÍCIA *", with: "Rascunho que ainda estou escrevendo"
  end
end
