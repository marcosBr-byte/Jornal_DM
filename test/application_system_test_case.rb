require "test_helper"
require "selenium-webdriver"
Selenium::WebDriver.logger.level = :warn

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  setup do
    page.current_window.resize_to(1400, 1000)
  end

  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1000 ] do |options|
    options.binary = ENV["CHROME_BIN"] if ENV["CHROME_BIN"].present?
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--no-sandbox") if Process.uid.zero?
  end
end
