module UniMock
  module StubRails
    # include RSpec::Mocks::Syntax

    def stub_env(env_name)
      allow(Rails).to receive(:env) { ActiveSupport::StringInquirer.new(env_name) }
    end
  end
end
