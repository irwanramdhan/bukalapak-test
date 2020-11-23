module BaseHelper
  def waiting_for_page_ready
    sleep 2
    wait_for_ajax
  end

  def wait_for_ajax
    max_time = Capybara::Helpers.monotonic_time + Capybara.default_max_wait_time

    while Capybara::Helpers.monotonic_time < max_time
      finished = finished_all_ajax_requests?
      finished ? break : sleep(0.1)
    end
    raise 'wait_for_ajax timeout' unless finished
  end

  def finished_all_ajax_requests?
    page.evaluate_script(<<~EOS
      ((typeof window.jQuery === 'undefined')
       || (typeof window.jQuery.active === 'undefined')
       || (window.jQuery.active === 0))
      && ((typeof window.injectedJQueryFromNode === 'undefined')
       || (typeof window.injectedJQueryFromNode.active === 'undefined')
       || (window.injectedJQueryFromNode.active === 0))
      && ((typeof window.httpClients === 'undefined')
       || (window.httpClients.every(function (client) { return (client.activeRequestCount === 0); })))
    EOS
                        )
  end

  def short_wait(time_out = SHORT_TIMEOUT)
    Selenium::WebDriver::Wait.new(timeout: time_out, interval: 0.2, ignore: Selenium::WebDriver::Error::NoSuchElementError)
  end

  def generate_code(number)
    charset = Array('A'..'Z') + Array('a'..'z')
    Array.new(number) { charset.sample }.join
  end

  def get_shadow_dom(host, element)
    root = page.driver.browser.find_element(:css, host)
    shadow_root = page.execute_script('return arguments[0].shadowRoot', root)
    shadow_root.find_element(:css,element)
  end

  def is_shadow_dom_exist?(host, element)
    begin
      root = page.driver.browser.find_element(:css, host)
      shadow_root = page.execute_script('return arguments[0].shadowRoot', root)
      shadow_root.find_element(:css,element)
      return true
    rescue
      puts 'element not found'
      return false
    end
  end

end
