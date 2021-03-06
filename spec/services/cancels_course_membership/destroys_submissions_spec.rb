require "light-service"
require "active_record_spec_helper"
require "./app/services/cancels_course_membership/destroys_submissions"

describe Services::Actions::DestroysSubmissions do
  let(:course) { membership.course }
  let(:membership) { create :student_course_membership }
  let(:student) { membership.user }

  it "expects the membership to find the submissions to destroy" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "destroys the submissions" do
    another_submission = create :submission, student: student
    course_submission = create :submission, student: student, course: course
    described_class.execute membership: membership
    expect(student.reload.submissions).to eq [another_submission]
  end
end
