module Services
  module Actions
    class DestroysEarnedChallenges
      extend LightService::Action

      expects :membership

      executed do |context|
        membership = context[:membership]

        PredictedEarnedChallenge.for_course(membership.course)
          .for_student(membership.user)
          .destroy_all
      end
    end
  end
end
