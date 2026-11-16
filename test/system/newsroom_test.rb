require "application_system_test_case"
class NewsroomBrowserTest < ApplicationSystemTestCase
  setup do
    user = User.create!(email: "carousel-browser@example.test", password: "CarouselPassword123!", admin: true)
    @first = user.articles.create!(title: "Primeiro destaque de tecnologia", body: "Conhecimento da comunidade", category: "Tecnologia", author: "Equipe", status: :published, featured: true, published_at: 1.hour.ago)
    @second = user.articles.create!(title: "Segundo destaque de esportes", body: "Conquistas da comunidade", category: "Esportes", author: "Equipe", status: :published, featured: true, published_at: 2.hours.ago)
  end
  test "highlights rotate after five seconds and have manual accessible controls" do
    page.current_window.resize_to(1440, 1000)
    visit root_path
    assert_selector ".featured-slide:not([hidden])", text: @first.title
    assert_selector ".featured-slide:not([hidden])", text: @second.title, wait: 7
    find("button[aria-label='Pausar carrossel']").click
    assert_selector "button[aria-label='Retomar carrossel'][aria-pressed=true]"
    find("button[aria-label='Destaque anterior']").click
    assert_selector ".featured-slide:not([hidden])", text: @first.title
    find("button[aria-label='Próximo destaque']").click
    assert_selector ".featured-slide:not([hidden])", text: @second.title
    find("button[aria-label='Pausar manchetes']").click
    assert_selector ".ticker-track.is-paused"
    find("button[aria-label='Retomar manchetes']").click
    find(".news-ticker").hover
    assert_equal "running", page.evaluate_script("getComputedStyle(document.querySelector('.ticker-track')).animationPlayState")
    assert page.evaluate_script("document.querySelector('.ticker-group').getBoundingClientRect().width >= document.querySelector('.ticker-window').clientWidth")
    assert page.evaluate_script("Math.abs(document.querySelectorAll('.ticker-group')[0].getBoundingClientRect().width - document.querySelectorAll('.ticker-group')[1].getBoundingClientRect().width) < 1")
    assert page.evaluate_script("(() => {const track = document.querySelector('.ticker-track'); const animation = track.getAnimations()[0]; const saved = animation.currentTime; animation.pause(); animation.currentTime = 1000; const x1 = new DOMMatrix(getComputedStyle(track).transform).m41; animation.currentTime = 2000; const x2 = new DOMMatrix(getComputedStyle(track).transform).m41; animation.currentTime = saved; animation.play(); return x2 < x1})()")
    initial_y = page.evaluate_script("new DOMMatrix(getComputedStyle(document.querySelector('.floating-logo')).transform).m42")
    Selenium::WebDriver::Wait.new(timeout: 5).until { (page.evaluate_script("new DOMMatrix(getComputedStyle(document.querySelector('.floating-logo')).transform).m42") - initial_y).abs > 1 }
    assert_equal "journal-logo-float", page.evaluate_script("getComputedStyle(document.querySelector('.floating-logo')).animationName")
    assert_selector ".brand-hero img", count: 1
    assert_no_selector ".floating-card"
    assert_equal "center", page.evaluate_script("getComputedStyle(document.querySelector('.category-tabs')).justifyContent")
    assert page.evaluate_script("document.querySelector('.brand-logo').getBoundingClientRect().left < document.querySelector('.brand-copy').getBoundingClientRect().left")
    assert page.evaluate_script("Array.from(document.querySelectorAll('.brand-hero img')).every(image => image.complete && image.naturalWidth > 0)")
    page.execute_script("window.scrollTo(0, 0)")
    save_screenshot Rails.root.join("tmp/screenshots/jornal-desktop-light.png")
    find("#themeToggle").click
    assert_selector "html.dark"
    Selenium::WebDriver::Wait.new(timeout: 3).until { page.evaluate_script("getComputedStyle(document.body).backgroundColor") == "rgb(12, 23, 32)" }
    save_screenshot Rails.root.join("tmp/screenshots/jornal-desktop-dark.png")
    page.current_window.resize_to(390, 844)
    page.refresh
    assert_selector "html.dark"
    assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")
    save_screenshot Rails.root.join("tmp/screenshots/jornal-mobile-dark.png")
    visit articles_path(category: "Tecnologia")
    assert_selector ".news-card h3", text: @first.title
    assert_no_selector ".news-card h3", text: @second.title
  end
end
