require "application_system_test_case"
class MotionBrowserTest < ApplicationSystemTestCase
  setup do
    user = User.create!(email: "motion-browser@example.test", password: "MotionBrowserPassword123!", admin: true)
    user.articles.create!(title: "Notícias em movimento", body: "Uma escola conectada", category: "Tecnologia", author: "Equipe", status: :published)
  end
  test "logo and headlines animate on mobile and desktop with device reduced motion and an optional saved pause" do
    page.driver.browser.execute_cdp("Emulation.setEmulatedMedia", features: [ { name: "prefers-reduced-motion", value: "reduce" } ])
    [ [ 390, 844 ], [ 1440, 1000 ] ].each do |width, height|
      page.current_window.resize_to(width, height)
      visit root_path
      assert_selector 'html[data-site-motion="on"]'
      assert_equal "news-ticker", page.evaluate_script("getComputedStyle(document.querySelector('.ticker-track')).animationName")
      initial_y = page.evaluate_script("new DOMMatrix(getComputedStyle(document.querySelector('.floating-logo')).transform).m42")
      Selenium::WebDriver::Wait.new(timeout: 5).until { (page.evaluate_script("new DOMMatrix(getComputedStyle(document.querySelector('.floating-logo')).transform).m42") - initial_y).abs > 1 }
      assert_equal "running", page.evaluate_script("getComputedStyle(document.querySelector('.ticker-track')).animationPlayState")
      assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")
    end
    find('button[aria-label="Pausar animações"]').click
    assert_selector 'html[data-site-motion="paused"]'
    page.refresh
    assert_selector 'html[data-site-motion="paused"]'
    find('button[aria-label="Ativar animações"]').click
    assert_selector 'html[data-site-motion="on"]'
    assert_equal "running", page.evaluate_script("getComputedStyle(document.querySelector('.ticker-track')).animationPlayState")
  ensure
    page.execute_script("localStorage.removeItem('jornaldm_motion'); document.documentElement.dataset.siteMotion = 'on'")
    page.driver.browser.execute_cdp("Emulation.setEmulatedMedia", features: [])
  end
end
