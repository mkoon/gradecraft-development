require "rails_spec_helper"

feature "editing submissions" do
  context "as a student" do
    let!(:submission) do
      create :submission, course: membership.course, assignment: assignment, student: student
    end

    let(:assignment) { create :assignment, accepts_submissions: true, course: membership.course }
    let(:membership) { create :student_course_membership, user: student }
    let(:student) { create :user }

    before { login_as student }

    scenario "notification of a resubmission" do
      create :grade, status: "Released", student: student, submission: submission,
        assignment: assignment
      visit edit_assignment_submission_path assignment, submission

      within ".pageContent" do
        expect(page).to have_content "Resubmission!"
      end
    end
  end
end
