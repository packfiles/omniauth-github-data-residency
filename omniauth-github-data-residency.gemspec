# frozen_string_literal: true

require_relative "lib/omniauth-github-data-residency/version"

Gem::Specification.new do |spec|
  spec.name = "omniauth-github-data-residency"
  spec.version = OmniAuth::Githubdr::VERSION
  spec.authors = ["Packfiles"]
  spec.email = ["hello@packfiles.io"]

  spec.summary = "OmniAuth strategy for GitHub Enterprise Cloud with Data Residency"
  spec.description = "OmniAuth strategy for GitHub Enterprise Cloud with Data Residency"
  spec.homepage = "https://github.com/packfiles/omniauth-github-data-residency"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com/packfiles"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/packfiles/omniauth-github-data-residency"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "omniauth-github", "~> 2.0", ">= 2.0.1"
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "ruby-lsp"
  spec.add_development_dependency "standard"
  spec.add_development_dependency "irb"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "lefthook"
  spec.add_development_dependency "mdl"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
