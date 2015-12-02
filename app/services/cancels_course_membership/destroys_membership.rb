module Services
  module Actions
    class DestroysMembership
      extend LightService::Action

      expects :membership

      executed do |context|
        membership = context[:membership]
        membership.destroy
      end
    end

    class DestroysFlaggedUsers
      extend LightService::Action

      executed do |context|
      end
    end
  end
end
