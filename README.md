# OmniAuth GitHub Enterprise Cloud with Data Residency

This is an OmniAuth strategy for authenticating with a [GitHub Enterprise Cloud with Data Residency][1] host.

It extends the [Official OmniAuth GitHub strategy][2] in the following ways:

- Since this version of GitHub has strict tenant boundaries,
therefore the configuration options require a `enterprise_subdomain` option
- While the official strategy has configuration options for either github.com or an
[enterprise version][3] (including a Data Residency version),
this strategy allows for using the two strategies side by side

To use it, you'll need to sign up for an OAuth2 Application ID and Secret
on the [developer settings view][4] in GitHub.

## Installation

```ruby
gem 'omniauth-github-with-data-residency', '~> 0.0.1'
```

## Usage

### Options

You are required to pass an `enterprise_subdomain` inside an `enterprise_options` options hash to build the correct client URLs.

For example, `enterprise_options: {enterprise_subdomain: "my-domain"}` will then expand to:

```ruby

"https://api.mydomain.ghe.com"
"https://mydomain.ghe.com/login/oauth/authorize"
"https://mydomain.ghe.com/login/oauth/access_token"

```

The `enterprise_options` are initially set in the setup phase,
and you can use hooks to update strategy options before the request and callback phases.

Static: you can set `enterprise_options` statically by adding to the options hash.

Dynamic: you can pass a proc (or another callable object) or a rack endpoint into the `setup` option.
This is useful if you need to pull the subdomain from a request.

### Basic Rails Usage with Devise

```ruby
config.omniauth :githubdr, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET'], scope: "user:email,read:user", enterprise_options: {enterprise_subdomain: "my-domain"}
```

### Side-by-side Usage in Rails with Devise

```ruby
SETUP_PROC = lambda do |env|
  req = Rack::Request.new(env)
  query_params = Rack::Utils.parse_nested_query(req.query_string).deep_symbolize_keys

  env["omniauth.strategy"].options[:enterprise_options][:enterprise_subdomain] = query_params[:enterprise_subdomain] if query_params[:enterprise_subdomain]
  env["omniauth.strategy"].options[:enterprise_options][:enterprise_subdomain] = query_params[:github_host].split(".").first if query_params[:github_host]
end

config.omniauth :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET'], scope: "user:email,read:user"
config.omniauth :github_data_residency, ENV['GITHUB_ENTERPRISE_CLIENT_ID'], ENV['GITHUB_ENTERPRISE_CLIENT_SECRET'], scope: "user:email,read:user", setup: SETUP_PROC
```

You can use the [setup phase][5] to dynamically configure the `enterprise_subdomain` option for the request and callback phases.

## Development

### Setup

This project uses [mise][6] to manage dependencies like the required Ruby version.
The provided setup script uses mise by default to install Ruby before installing gems and other dependencies.

After checking out the repository, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

### Local installation

To install this gem onto your local machine, run `bundle exec rake install`.

### Release

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`.
This command will create a git tag for the version, push git commits and the newly created tag, and push the `.gem` file to [rubygems.org][7].

### Documentation

You can lint markdown with the following command: `bundle exec mdl *.md`. You can override styles in `md_styles.rb`. See [mdl_configuration][11] for more.

You can check the documentation content with [Vale][8]. For example, run `vale sync && vale --config=./.vale.ini README.md` to install styles and check the README file.

You can validate include links with this command: `lychee --no-progress --include-fragments --verbose *.md`

[Vale][9] and [Lychee][10] are optional and not included in the [mise.toml](./mise.toml) configuration file.

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/packfiles/omniauth-github-data-residency>.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/license/MIT).

---

Made with :heart: by [Packfiles :package:](https://packfiles.io)

[1]: https://docs.github.com/en/enterprise-cloud@latest/admin/data-residency/about-github-enterprise-cloud-with-data-residency
[2]: https://github.com/omniauth/omniauth-github/
[3]: https://github.com/omniauth/omniauth-github/blob/master/README.md#github-enterprise-usage
[4]: https://github.com/settings/developers
[5]: https://github.com/omniauth/omniauth/wiki/Setup-Phase
[6]: http://mise.jdx.dev/
[7]: https://rubygems.org
[8]: https://vale.sh/docs
[9]: https://vale.sh/
[10]: https://lychee.cli.rs/
[11]: https://github.com/markdownlint/markdownlint/blob/main/docs/configuration.md
