require 'capybara/cucumber'
require 'capybara-screenshot/cucumber'
require 'capybara/rspec'
require 'selenium-webdriver'
require 'site_prism'
require 'dotenv'
require 'rspec/expectations'
require 'data_magic'
require 'pry'
require 'faker'
require 'active_support/all'
require 'date'
require 'byebug'
require 'data_magic'
require 'yaml'
require 'simple_xlsx_reader'
require 'roo'
require 'roo-xls'
require_relative '../lib/base_helper'

include RSpec::Matchers
include BaseHelper

Dotenv.load
browser = 'chrome'.to_sym
base_url = ENV['BASE_URL'] || 'http://klikpajak-staging.cd.jurnal.id'
wait_time = 60
SHORT_TIMEOUT = 60
DEFAULT_TIMEOUT = 30
DataMagic.yml_directory = base_url.include?('staging') ? './features/config/data/uat' : './features/config/data/dev'

browser_options = Selenium::WebDriver::Chrome::Options.new
browser_profile = Selenium::WebDriver::Chrome::Profile.new

if ENV['BROWSER'].eql? 'chrome_headless'
  browser_options.headless!
  browser_options.add_argument('--no-sandbox')
  browser_options.add_argument('--disable-gpu')
  browser_options.add_argument('--disable-dev-shm-usage')
  browser_options.add_argument('--enable-features=NetworkService,NetworkServiceInProcess')
end

browser_options.add_preference('download.default_directory', File.absolute_path('./features/data/downloaded'))
browser_options.add_preference(:download, default_directory: File.absolute_path('./features/data/downloaded'))
browser_options.add_preference('plugins.always_open_pdf_externally', true)
browser_options.add_preference(:plugins, always_open_pdf_externally: true)
# browser_options.add_preference('profile.geolocation.default_content_setting', 1)

# "profile.default_content_settings.geolocation", 2
# browser_profile['geolocation.default_content_setting'] = 2

Capybara.register_driver :chrome do |app|
  browser_options.add_argument('--user-agent=selenium')
  browser_options.add_argument('--start-maximized')

  client = Selenium::WebDriver::Remote::Http::Default.new
  client.open_timeout = wait_time
  client.read_timeout = wait_time

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: browser_options,
    http_client: client,
    profile: browser_profile
  )
end

# clear report files
report_root = File.absolute_path('./report')
if ENV['REPORT_PATH'].nil?
  # remove report directory when run localy,
  # ENV report will initiate from rakefile, or below this
  puts ' ========Deleting old reports ang logs========='
  FileUtils.rm_rf(report_root, secure: true)
end
ENV['REPORT_PATH'] ||= Time.now.strftime('%F_%H-%M-%S')
path = "#{report_root}/#{ENV['REPORT_PATH']}"
FileUtils.mkdir_p path

Capybara::Screenshot.register_driver(browser) do |driver, path|
  driver.browser.save_screenshot path
end

if ENV['CI'] == 'true'
  p "about to run on #{browser} remotes #{base_url}"
  Capybara.default_driver = :selenium
else
  p "about to run on #{browser} to #{base_url}"
  Capybara.default_driver = browser
end

Capybara::Screenshot.autosave_on_failure = true
Capybara::Screenshot.prune_strategy = { keep: 50 }
Capybara::Screenshot.append_timestamp = true
Capybara::Screenshot.webkit_options = {
  width: 1366,
  height: 768
}

Capybara.save_path = "#{path}/screenshots"
