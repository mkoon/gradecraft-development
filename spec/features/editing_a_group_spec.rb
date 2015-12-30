require "rails_spec_helper"

feature "editing a group" do
  context "as a professor" do
    let(:course) { create :course, min_group_size: 2 }
    let!(:course_membership) { create :professor_course_membership, user: professor, course: course }
    let(:professor) { create :user }
    let!(:assignment) { create :assignment, grade_scope: "Group", course: course }
    let(:student_1) { create :user, first_name: "Hermione", last_name: "Granger"}
    let!(:course_membership_2) { create :student_course_membership, user: student_1, course: course }
    let(:student_2) { create :user, first_name: "Ron", last_name: "Weasley"}
    let(:student_3) { create :user, first_name: "George", last_name: "Weasley"}
    let!(:course_membership_3) { create :student_course_membership, user: student_2, course: course }
    let!(:course_membership_4) { create :student_course_membership, user: student_3, course: course }
    let!(:group) { create :group, course: course, name: "Group!", approved: "Approved" }
    let!(:assignment_group) { create :assignment_group, group: group, assignment: assignment }
    let!(:group_membership) { create :group_membership, student: student_1, group: group }
    let!(:group_membership_2) { create :group_membership, student: student_2, group: group }
    let!(:group_membership_2) { create :group_membership, student: student_3, group: group }

    before(:each) do
      login_as professor
      visit dashboard_path
    end

    scenario "successfully" do
      within(".sidebar-container") do
        click_link "groups"
      end

      expect(current_path).to eq groups_path

      within(".pageContent") do
        click_link "Edit group"
      end

      expect(current_path).to eq edit_group_path(group)

      within(".pageContent") do
        fill_in "Name", with: "Less Excited Group Name"
        click_button "Update group"
      end

      expect(page).to have_notification_message('notice', "Less Excited Group Name group successfully updated")
    end
  end
end
