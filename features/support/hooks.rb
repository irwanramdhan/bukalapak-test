Before do |_scenario|
  Capybara.app_host = ENV['BASE_URL']
  Capybara.default_max_wait_time = DEFAULT_TIMEOUT
  Capybara.javascript_driver = :chrome
  @driver = page.driver
  @pages = Pages.new
  Selenium::WebDriver.logger.level = :debug
  Selenium::WebDriver.logger.output = 'selenium.log'
  page.driver.browser.manage.window.resize_to(1440, 877)
end

After do |scenario|
  if ENV['TESTRAIL_RUN_UPDATE'].eql? 'true'
    statuses = {
      passed: 1,
      failed: 5,
      pending: 6
    }

    results = []
    case_ids = case_ids(scenario)
    case_ids.delete(0)

    if case_ids.count > 0
      case_ids.each { |case_id| results << set_result(case_id, statuses[scenario.status]) }
      add_results_for_cases({ results: results })
    end
  end

  if scenario.failed?
    Capybara.using_session_with_screenshot(Capybara.session_name.to_s) do
      # screenshots will work and use the correct session
    end
  end
end

def case_ids(scenario)
  case_ids = scenario.outline? ? scenario.scenario_outline.cell_values : scenario.name.split('-')
  case_ids.first.split(',').map(&:to_i)
end

def set_result(case_id, status_id)
  {
    case_id: case_id,
    comment: 'from automation',
    status_id: status_id
  }
end

def add_results_for_cases(params)
  client = TestRail::APIClient.new(ENV['TESTRAIL_API_CLIENT'])
  client.user = ENV['TESTRAIL_USER']
  client.password = ENV['TESTRAIL_PASSWORD']
  client.send_post("add_results_for_cases/#{ENV['TESTRAIL_RUN']}", params)
end
