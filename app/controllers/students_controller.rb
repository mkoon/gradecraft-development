class StudentsController < ApplicationController
  respond_to :html, :json

  def index
    @title = "#{current_course.user_term} Roster"
    @users = current_course.users
    @students = current_course.students.includes(:earned_badges)
    @teams = current_course.teams
    user_search_options = {}
    user_search_options['team_memberships.team_id'] = params[:team_id] if params[:team_id].present?
    @sorted_students = @students.includes(:teams).where(user_search_options).order_by_high_score
    respond_to do |format|
      format.html
      format.json { render json: @users }
      format.csv { send_data User.csv_for_course(current_course) }
      format.xls { send_data @users.csv_for_course(current_course, col_sep: "\t") }
    end
  end

  def show
    @students = current_course.students.includes(:earned_badges)
    self.current_student = @students.find(params[:id])

    @assignment_types = current_course.assignment_types.includes(:assignments)
    @assignment_weights = current_student.assignment_weights
    @assignment_weight = current_student.assignment_weights.new
    @assignments = current_course.assignments.includes(:submissions, :assignment_type).chronological
    @assignments_with_due_dates = @assignments.select { |assignment| assignment.due_at.present? }
    @grades = current_student.grades
    @badges = current_course.badges.includes(:earned_badges, :tasks)
    @earned_badges = current_student.earned_badges
    @teams = current_course.teams
    @sorted_teams = @teams.order_by_high_score

    @form = AssignmentTypeWeightForm.new(current_student, current_course)

    scores = []
    current_course.assignment_types.each do |assignment_type|
      scores << { data: [current_student.grades.released.where(assignment_type: assignment_type).score], name: assignment_type.name }
    end

    earned_badge_score = current_student.earned_badges.where(course: current_course).score
    scores << { :data => [earned_badge_score], :name => 'Badges' }

    assignments = current_student.assignments.where(course: current_course)
    assignments = assignments.graded_for_student(current_student) if params[:in_progress]

    respond_to do |format|
      format.html
      format.json { render json: { :student_name => current_student.name, :scores => scores, :course_total => assignments.point_total + earned_badge_score } }
    end
  end
end