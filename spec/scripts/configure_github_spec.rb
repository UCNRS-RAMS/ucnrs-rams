require "base64"
require "fileutils"
require "json"
require "open3"
require "rbconfig"
require "tmpdir"

RSpec.describe "bin/configure-github" do
  let(:script) { File.expand_path("../../bin/configure-github", __dir__) }
  let(:api) { "repos/UCNRS-RAMS/ucnrs-rams" }
  let(:configuration) do
    {
      repository: { permissions: { admin: true }, default_branch: "main" },
      workflow: { content: Base64.strict_encode64("jobs:\n  policy: {}\n") },
      rulesets: []
    }
  end

  around do |example|
    Dir.mktmpdir("rams-github-spec") do |directory|
      @directory = directory
      example.run
    end
  end

  before do
    File.write(File.join(@directory, "gh"), <<~RUBY)
      #!#{RbConfig.ruby}
      require "json"
      configuration = JSON.parse(File.read(ENV.fetch("GITHUB_SPEC_CONFIGURATION")))
      method = ARGV.fetch(2)
      path = ARGV.fetch(3)
      body = ARGV.include?("--input") ? JSON.parse($stdin.read) : nil
      File.open(ENV.fetch("GITHUB_SPEC_REQUESTS"), "a") do |file|
        file.puts(JSON.generate({ method: method, path: path, body: body }))
      end
      if configuration["fail_path"] == path
        warn "simulated GitHub failure"
        exit 1
      end
      response = if method != "GET"
        {}
      elsif path.include?("/contents/")
        configuration.fetch("workflow")
      elsif path.include?("/rulesets?")
        configuration.fetch("rulesets")
      else
        configuration.fetch("repository")
      end
      puts JSON.generate(response)
    RUBY
    FileUtils.chmod(0o755, File.join(@directory, "gh"))
  end

  def run_configuration(*arguments)
    configuration_file = File.join(@directory, "configuration.json")
    File.write(configuration_file, JSON.generate(configuration))
    Open3.capture3(
      {
        "PATH" => "#{@directory}:#{ENV.fetch('PATH')}",
        "GITHUB_SPEC_CONFIGURATION" => configuration_file,
        "GITHUB_SPEC_REQUESTS" => File.join(@directory, "requests.jsonl")
      },
      RbConfig.ruby, script, *arguments
    )
  end

  def requests
    path = File.join(@directory, "requests.jsonl")
    File.exist?(path) ? File.readlines(path).map { |line| JSON.parse(line) } : []
  end

  it "previews squash-only merges and required checks without contacting GitHub" do
    output, error, status = run_configuration
    expect(status.success?).to be(true), error
    preview = JSON.parse(output)
    expect(preview.fetch("settings")).to include(
      "allow_squash_merge" => true, "allow_rebase_merge" => false,
      "allow_merge_commit" => false, "squash_merge_commit_title" => "PR_TITLE"
    )
    rules = preview.fetch("rulesets").first.fetch("rules")
    check_rule = rules.find { |rule| rule.fetch("type") == "required_status_checks" }
    expect(check_rule.dig("parameters", "required_status_checks").map { |check| check.fetch("context") })
      .to eq([ "policy", "ci/circleci: build" ])
    expect(requests).to be_empty
  end

  it "refuses non-administrators before making any changes" do
    configuration[:repository][:permissions][:admin] = false
    _, error, status = run_configuration("--apply")
    expect(status.success?).to be(false)
    expect(error).to include("admin permission is required")
    expect(requests.map { |request| request.fetch("method") }).to eq([ "GET" ])
  end

  it "requires main to be the default branch before making any changes" do
    configuration[:repository][:default_branch] = "development"
    _, error, status = run_configuration("--apply")
    expect(status.success?).to be(false)
    expect(error).to include("default branch must be main")
    expect(requests.map { |request| request.fetch("method") }).to eq([ "GET" ])
  end

  it "refuses to require the policy check before it has landed on main" do
    configuration[:workflow][:content] = Base64.strict_encode64("jobs:\n  unrelated: {}\n")
    _, error, status = run_configuration("--apply")
    expect(status.success?).to be(false)
    expect(error).to include("main must contain the policy job")
    expect(requests.map { |request| request.fetch("method") }).to eq([ "GET", "GET" ])
  end

  it "creates the RAMS rulesets while preserving unrelated rulesets" do
    configuration[:rulesets] = [ { id: 99, name: "An existing rule" } ]
    _, error, status = run_configuration("--apply")
    expect(status.success?).to be(true), error
    writes = requests.reject { |request| request.fetch("method") == "GET" }
    expect(writes.map { |request| request.fetch("method") }).to eq([ "PATCH", "POST", "POST" ])
    expect(writes.first.fetch("path")).to eq(api)
    expect(writes.drop(1).map { |request| request.dig("body", "name") })
      .to eq([ "RAMS main", "RAMS release tags" ])
    expect(writes.none? { |request| request.fetch("path").end_with?("/99") }).to be(true)
  end

  it "updates existing named rulesets rather than creating duplicates" do
    configuration[:rulesets] = [ { id: 1, name: "RAMS main" }, { id: 2, name: "RAMS release tags" } ]
    _, error, status = run_configuration("--apply")
    expect(status.success?).to be(true), error
    writes = requests.select { |request| request.fetch("method") == "PUT" }
    expect(writes.map { |request| request.fetch("path") }).to eq([ "#{api}/rulesets/1", "#{api}/rulesets/2" ])
    expect(requests.none? { |request| request.fetch("method") == "POST" }).to be(true)
  end

  it "stops before mutation if a GitHub preflight request fails" do
    configuration[:fail_path] = "#{api}/contents/.github/workflows/pr-policy.yml?ref=main"
    _, error, status = run_configuration("--apply")
    expect(status.success?).to be(false)
    expect(error).to include("simulated GitHub failure")
    expect(requests.all? { |request| request.fetch("method") == "GET" }).to be(true)
  end
end
