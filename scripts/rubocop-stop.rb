#!/usr/bin/env ruby
require "json"
require "open3"

def finish(message = nil)
  puts JSON.generate(message ? { systemMessage: message } : {})
  exit 0
end

def git_files(*args)
  output, error, status = Open3.capture3("git", *args)
  raise "Git file selection failed: #{error}" unless status.success?

  output.split("\0")
end

begin
  input = JSON.parse($stdin.read)
  Dir.chdir(File.expand_path("..", __dir__))
  files = (git_files("diff", "--name-only", "-z", "--diff-filter=ACMR", "HEAD", "--") +
    git_files("ls-files", "--others", "--exclude-standard", "-z")).uniq.select do |path|
    File.file?(path) && (path.end_with?(".rb", ".rake") || %w[Gemfile Rakefile].include?(File.basename(path)))
  end
  finish if files.empty?

  output, status = Open3.capture2e("bundle", "exec", "rubocop", "--force-exclusion", "--format", "simple", "--", *files)
  finish if status.success?

  if status.exitstatus != 1
    finish("RuboCop hook could not complete (exit #{status.exitstatus.inspect}). Check the local Ruby/Bundler setup.\n#{output}")
  end

  if input["stop_hook_active"] == true
    finish("RuboCop still reports failures after one correction attempt; review is needed.\n#{output}")
  end

  warn <<~MESSAGE
    RuboCop reported failures. Fix violations introduced by this task, then report any remaining issues.
    This check includes all working-tree changes; do not rewrite unrelated pre-existing work.
    See docs/agent_hooks.md for guidance. Do not change behavior or suppress cops merely to pass lint.
    #{output}
  MESSAGE
  exit 2
rescue JSON::ParserError, SystemCallError, RuntimeError => error
  finish("RuboCop hook could not run: #{error.message}")
end
