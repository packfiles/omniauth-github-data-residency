# OmniAuth GitHub Enterprise Cloud with Data Residency

This is an OmniAuth strategy for authenticating with a [GitHub Enterprise Cloud with Data Residency](https://docs.github.com/en/enterprise-cloud@latest/admin/data-residency/about-github-enterprise-cloud-with-data-residency) host. 

It extends the Official OmniAuth strategy in the following ways: 
- Since this version of GitHub has strict tenant boundaries, an enterprise_subdomain configuration option is rquired
- While the official strategy can be configured for either github.com or an [enterprise version](https://github.com/omniauth/omniauth-github/blob/master/README.md#github-enterprise-usage) (including a Data Residency version), this strategy allows for using the two strategies side by side 

To use it, you'll need to sign up for an OAuth2 Application ID and Secret
on the [GitHub OAuth Apps Page](https://github.com/settings/developers).

## Installation

```ruby
gem 'omniauth-github-with-data-residency', '~> 0.0.1'
```

## Usage

### Basic Rails Usage with Devise

```ruby
config.omniauth :githubdr, client_id, client_secret, scope: "user:email,read:user", enterprise_options: {enterprise_subdomain: "my-domain"}
```

### Side-by-side Usage in Rails with Devise

```ruby
SETUP_PROC = lambda do |env|
  req = Rack::Request.new(env)
  query_params = Rack::Utils.parse_nested_query(req.query_string).deep_symbolize_keys

  env["omniauth.strategy"].options[:enterprise_options][:enterprise_subdomain] = query_params[:enterprise_subdomain] if query_params[:enterprise_subdomain]
  env["omniauth.strategy"].options[:enterprise_options][:enterprise_subdomain] = query_params[:github_host].split(".").first if query_params[:github_host]
end


config.omniauth :github, client_id, client_secret, scope: "user:email,read:user"
config.omniauth :githubdr, client_id, client_secret, scope: "user:email,read:user", setup: SETUP_PROC
```

You can make use of the [setup phase](https://github.com/omniauth/omniauth/wiki/Setup-Phase) to dynamically configure the `enterprise_subdomain` option for the request and callback phases.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/packfiles/omniauth-github-data-residency.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
