require "rails_spec_helper"

feature "editing a course's options" do
  context "as a professor" do
    let(:course) { create :course, name: "Course Name"}
    let!(:course_membership) { create :professor_course_membership, user: professor, course: course }
    let(:professor) { create :user }

    before(:each) do
      login_as professor
      visit dashboard_path
    end

    scenario "successfully" do
      within(".sidebar-container .staff-sidenav") do
        click_link "Options"
      end

      within(".pageContent") do
        fill_in "Course Title", with: "New Course Name"
        click_button "Update Course"
      end

      expect(current_path).to eq course_path(course.id)
      expect(page).to have_notification_message('notice', 'Course New Course Name successfully updated')
    end
  end
end
