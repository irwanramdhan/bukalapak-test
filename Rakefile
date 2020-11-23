require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'
require 'report_builder'
require 'parallel_tests'

namespace :klikpajak do
  @status = true
  Cucumber::Rake::Task.new do |t|
    t.cucumber_opts = %w[--format progress]
  end

  Cucumber::Rake::Task.new(:test, 'Run Klikpajak Automation Test') do |t|
    # sample use: rake klikpajak:test t=@login REPORT_NAME=2
    t.cucumber_opts = ["-t #{ENV['t']}"] unless ENV['t'].nil?
    t.cucumber_opts = ["features/#{ENV['f']}"] unless ENV['f'].nil?
    t.profile = 'rake_run'
  end

  desc 'Parallel run'
  task :parallel do
    abort '=====:: Failed to proceed, tags needed for parallel (t=@sometag)' if ENV['t'].nil?
    puts "=====:: Parallel execution tag: #{ENV['t']} about to start "
    # these exec no needed, already covered in "klikpajak:parallel_run"
    # Rake::Task['klikpajak:clear_report'].execute
    # Rake::Task['klikpajak:init_report'].execute

    begin
      @status = system "bundle exec parallel_cucumber features/ -o '-t #{ENV['t']}'"
      puts "Testing @status after parallel #{@status}"
    rescue StandardError => exception
      p 'Found error!'
      pp exception
    ensure
      puts '=====::  ::====='
      # p "merging report:"
      # Rake::Task["klikpajak:merge_report"].execute
    end
  end

  task :clear_report do
    puts '=====:: Delete report directory '
    report_root = File.absolute_path('./report')
    FileUtils.rm_rf(report_root, secure: true)
    FileUtils.mkdir_p report_root
  end

  task :init_report do
    puts '=====:: Preparing KlikPajak ::====='
    report_root = File.absolute_path('./report')
    ENV['REPORT_PATH'] = Time.now.strftime('%F_%H-%M-%S.%L')
    puts "=====:: about to create report #{ENV['REPORT_PATH']} "
    FileUtils.mkdir_p "#{report_root}/#{ENV['REPORT_PATH']}"
  end

  task :setup do
    # exec 'bundle install'
    ENV['TZ'] = 'Asia/Jakarta'
    ENV['RUBYOPT'] = '-W0'
    ENV['BROWSER'] = 'chrome_headless'
  end

  task :merge_report do
    output_report = "report/output/test_report_#{ENV['REPORT_PATH']}"
    puts "=====:: Merging report #{output_report}"
    FileUtils.mkdir_p 'report/output'
    options = {
      input_path: "report/#{ENV['REPORT_PATH']}",
      report_path: output_report,
      report_types: %w[retry html json],
      report_title: 'Teletubbies Report',
      color: 'blue',
      additional_info: { 'Browser' => 'Chrome', 'Environment' => ENV['BASE_URL'].to_s, 'Generated report' => Time.now, 'Tags' => ENV['t'] }
    }
    ReportBuilder.build_report options
    puts "After rerun @status in merging report is #{@status}"
    exit(1) unless @status
  end

  task :run do
    # Before all
    Rake::Task['klikpajak:clear_report'].execute

    # Test 1
    Rake::Task['klikpajak:init_report'].execute
    system 'rake klikpajak:test t=@login'

    # Test 2
    # Rake::Task['icebox:init_report'].execute
    # system 'rake icebox:test t=@signup'

    # # After all
    # Rake::Task['icebox:merge_report'].execute
  end

  task :rerun do
    @temp_status = 1
    puts Dir["."]
    Dir["report/#{ENV['REPORT_PATH']}/*.txt"].each do |f|
      unless File.size(f).zero?
        puts "=====:: will rerun file #{f}"
        FileUtils.cp_r f, "./rerun.txt"
        opening_file = open "./rerun.txt"
        content_rerun = opening_file.read
        puts "=====:: failed scenarios #{content_rerun}"
        opening_file.close
        file_rerun = f.split('/').last.tr('.txt', '')
        status_rerun = system "bundle exec cucumber @rerun.txt --format pretty --format html --out report/#{ENV['REPORT_PATH']}/features_report_rerun#{file_rerun}.html --format json --out=report/#{ENV['REPORT_PATH']}/cucumber_rerun#{file_rerun}.json"
        @temp_status -= 1 unless status_rerun
      end
    end
    # see :merge_report for exit @status
    puts "Final status #{@temp_status} : #{@temp_status.positive?}"
    @status = true if @temp_status.positive?
  end

  task :police do
    sh 'bundle exec cuke_sniffer --out html report/cuke_sniffer.html'
  end

  task :install do
    # this task needed in docker to update gems file
    # Gemfile located outside directory of Rakefile, so we add relative path
    puts '=====:: Installing Gems '
    system 'pwd && bundle install --path ../Gemfile'
  end
  task parallel_run: %i[clear_report init_report parallel rerun merge_report]
end
