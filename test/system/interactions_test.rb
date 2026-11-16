require "application_system_test_case"
require "vips"
class InteractionsTest < ApplicationSystemTestCase
  setup do
    ApplicationController::AUTH_RATE_LIMIT_STORE.clear
    user = User.create!(email: "system-interactive@example.test", password: "BrowserSecure123!", admin: true)
    @article = user.articles.create!(title: "Uma escola interativa", body: "Histórias da comunidade", category: "Educação", author: "Redação", status: :published)
  end
  test "reader likes without navigation comments and uses the mobile menu and theme" do
    page.current_window.resize_to(390, 844)
    visit article_path(@article)
    assert_selector "h1", text: @article.title
    button = find("button[data-action='engagement#like']")
    button.click
    assert_selector "button[aria-pressed=true]", text: /1\s+curtidas/
    assert_text "Você curtiu esta notícia."
    page.refresh
    assert_selector "button[aria-pressed=true]", text: /1\s+curtidas/
    find("button[data-action='engagement#like']").click
    assert_text "Curtida retirada."
    fill_in "Comentário", with: "Muito bom acompanhar a escola."
    click_on "Publicar comentário"
    assert_text "Comentário publicado!", wait: 10
    assert_equal "approved", @article.comments.last.status
    find("#themeToggle").click
    assert_selector "html.dark"
    page.refresh
    assert_selector "html.dark"
    assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")
    find("button[aria-controls=main-navigation]").click
    assert_selector "#main-navigation.is-open"
    within("#main-navigation") { click_on "FECT" }
    visit fect_path
    assert_selector "h1", text: "Ideias que conectam."
    assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")
    save_screenshot Rails.root.join("tmp/screenshots/fect-mobile.png")
    page.current_window.resize_to(1440, 1000)
    save_screenshot Rails.root.join("tmp/screenshots/fect-desktop.png")
  end

  test "photos can be previewed removed submitted and confirmed" do
    Tempfile.create([ "browser-photo", ".png" ]) do |file|
      Vips::Image.black(900, 600).new_from_image([ 120, 60, 90 ]).pngsave(file.path)
      visit "/enviar-fotos"
      find("input[data-photo-upload-target=gallery]", visible: :all).attach_file(file.path, make_visible: true)
      assert_selector ".dm-preview img"
      click_on "Remover"
      assert_no_selector ".dm-preview img"
      find("input[data-photo-upload-target=gallery]", visible: :all).attach_file(file.path, make_visible: true)
      check "consent"
      click_on "Confirmar envio"
      assert_text "fotografia(s) recebida(s)!", wait: 15
      assert_equal "pending", PhotoSubmission.last.status
      assert_no_selector ".dm-preview img"
      PhotoSubmission.last.image.purge
    end
  end
end
