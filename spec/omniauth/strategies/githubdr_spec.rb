require "omniauth/strategies/githubdr"

RSpec.describe OmniAuth::Strategies::Githubdr do
  let(:access_token) { instance_double("AccessToken", :options => {}, :[] => "user") }
  let(:app) { lambda { |_env| [200, {}, ["Hello."]] } }
  let(:enterprise_subdomain) { "example-corp" }

  subject do
    described_class.new(app, "client_id", "client_secret")
  end

  before do
    allow(subject).to receive(:access_token).and_return(access_token)
  end

  describe "client_options" do
    it "has default values" do
      expect(subject.options.client_options.site).to eq("https://api.github.com")
      expect(subject.options.client_options.authorize_url).to eq("https://github.com/login/oauth/authorize")
      expect(subject.options.client_options.token_url).to eq("https://github.com/login/oauth/access_token")
    end
  end

  describe "#build_client_options" do
    before do
      subject.options.enterprise_options[:enterprise_subdomain] = enterprise_subdomain
    end

    it "sets the client_options URLs based on the enterprise_subdomain" do
      subject.send(:build_client_options)

      expect(subject.options.client_options.site).to eq("https://api.#{enterprise_subdomain}.ghe.com")
      expect(subject.options.client_options.authorize_url).to eq("https://#{enterprise_subdomain}.ghe.com/login/oauth/authorize")
      expect(subject.options.client_options.token_url).to eq("https://#{enterprise_subdomain}.ghe.com/login/oauth/access_token")
    end

    context "with missing enterprise_subdomain" do
      let(:enterprise_subdomain) { nil }

      it "raises an error" do
        expect { subject.send(:build_client_options) }.to raise_error(OmniAuth::Strategies::OAuth2::CallbackError, "An Enterprise subdomain is required.")
      end
    end

    context "with empty enterprise_subdomain" do
      let(:enterprise_subdomain) { "" }

      it "raises an error" do
        expect { subject.send(:build_client_options) }.to raise_error(OmniAuth::Strategies::OAuth2::CallbackError, "An Enterprise subdomain is required.")
      end
    end
  end

  describe "#request_phase" do
    before do
      subject.options.enterprise_options[:enterprise_subdomain] = enterprise_subdomain
      # Stop the parent request_phase from being called and returning errors
      allow_any_instance_of(OmniAuth::Strategies::GitHub).to receive(:request_phase).and_return(true)
    end

    it "ensures client options are updated before proceeding" do
      # Create a custom test implementation of request_phase that simply returns an observable result
      test_implementation = Class.new(OmniAuth::Strategies::Githubdr) do
        def custom_request_phase_test
          # Call the original request_phase
          request_phase

          # Return the client options for observation in the test
          options.client_options
        end
      end

      # Create a test instance and set the options
      test_instance = test_implementation.new(app, "client_id", "client_secret")
      test_instance.options.enterprise_options[:enterprise_subdomain] = enterprise_subdomain

      # Call the test method and verify the options afterward
      result = test_instance.custom_request_phase_test

      # Verify the client options were properly updated
      expect(result.site).to eq("https://api.#{enterprise_subdomain}.ghe.com")
      expect(result.authorize_url).to eq("https://#{enterprise_subdomain}.ghe.com/login/oauth/authorize")
      expect(result.token_url).to eq("https://#{enterprise_subdomain}.ghe.com/login/oauth/access_token")
    end
  end

  describe "#callback_phase" do
    before do
      subject.options.enterprise_options[:enterprise_subdomain] = enterprise_subdomain
      # Stop the parent callback_phase from being called and returning errors
      allow_any_instance_of(OmniAuth::Strategies::GitHub).to receive(:callback_phase).and_return(true)
    end

    it "ensures client options are updated before proceeding" do
      # Create a custom test implementation of callback_phase that simply returns an observable result
      test_implementation = Class.new(OmniAuth::Strategies::Githubdr) do
        def custom_callback_phase_test
          # Call the original callback_phase
          callback_phase

          # Return the client options for observation in the test
          options.client_options
        end
      end

      # Create a test instance and set the options
      test_instance = test_implementation.new(app, "client_id", "client_secret")
      test_instance.options.enterprise_options[:enterprise_subdomain] = enterprise_subdomain

      # Call the test method and verify the options afterward
      result = test_instance.custom_callback_phase_test

      # Verify the client options were properly updated
      expect(result.site).to eq("https://api.#{enterprise_subdomain}.ghe.com")
      expect(result.authorize_url).to eq("https://#{enterprise_subdomain}.ghe.com/login/oauth/authorize")
      expect(result.token_url).to eq("https://#{enterprise_subdomain}.ghe.com/login/oauth/access_token")
    end
  end

  describe "#invalid_enterprise_subdomain?" do
    context "when enterprise_subdomain is nil" do
      it "returns true" do
        subject.options.enterprise_options[:enterprise_subdomain] = nil
        expect(subject.send(:invalid_enterprise_subdomain?)).to be true
      end
    end

    context "when enterprise_subdomain is empty" do
      it "returns true" do
        subject.options.enterprise_options[:enterprise_subdomain] = ""
        expect(subject.send(:invalid_enterprise_subdomain?)).to be true
      end
    end

    context "when enterprise_subdomain is present" do
      it "returns false" do
        subject.options.enterprise_options[:enterprise_subdomain] = "example-corp"
        expect(subject.send(:invalid_enterprise_subdomain?)).to be false
      end
    end
  end
end
