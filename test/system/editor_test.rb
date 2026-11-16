require "application_system_test_case"

class EditorTest < ApplicationSystemTestCase
  setup do
    @admin = User.create!(email: "browser-admin@example.test", password: "BrowserPassword123!", admin: true)
  end

  test "administrator can format and publish an article with the security policy enabled" do
    visit new_user_session_path
    fill_in "E-MAIL", with: @admin.email
    fill_in "SENHA", with: "BrowserPassword123!"
    click_on "Entrar no painel →"
    assert_selector "aside", text: "MENU PRINCIPAL", wait: 10
    assert_no_selector ".verification-overlay", wait: 5
    page.execute_script("localStorage.setItem('jornaldm_theme', 'light')")
    page.refresh
    assert_selector "#themeToggle.icon-button.theme-button", count: 1
    assert_no_selector "[data-theme-target=label]"
    find("#themeToggle").click
    assert_selector "html.dark"
    find("#themeToggle").click
    assert_no_selector "html.dark"
    begin
      assert_selector "trix-editor[contenteditable]:not([contenteditable=false])", wait: 10
    rescue Minitest::Assertion
      warn page.driver.browser.logs.get(:browser).map(&:message).join("\n")
      raise
    end
    fill_in "TÍTULO DA NOTÍCIA *", with: "Reportagem pelo editor"
    select "Cultura", from: "CATEGORIA"
    editor = find("trix-editor")
    editor.click
    editor.send_keys("Conteúdo do jornal")
    assert_text "3 palavras"
    page.execute_script("document.querySelector('trix-editor').editor.setSelectedRange([0, 8])")
    find("button[data-trix-attribute=bold]").click
    click_on "Publicar notícia →"
    assert_text "Publicação salva.", wait: 10
    article = Article.find_by!(title: "Reportagem pelo editor")
    assert_includes article.body, "<strong>Conteúdo</strong>"
    visit article_path(article)
    assert_selector "strong", text: "Conteúdo"
    assert_selector "h1", text: "Reportagem pelo editor"
  end
end
