class World
  def self.create
    Instance.new
  end

  class Instance
    attr_reader :assignments, :badges, :courses, :course_memberships, :criteria,
                :criterion_grades, :grades, :rubrics, :students, :teams, :users

    def assignment
      assignments.first
    end

    def badge
      badges.first
    end

    def course
      courses.first
    end

    def criterion
      criteria.first
    end

    def criterion_grade
      criterion_grades.first
    end

    def grade
      grades.first
    end

    def rubric
      rubrics.first
    end

    def students
      course_memberships.select{ |cm| cm.role == "student" }.map(&:user)
    end

    def student
      students.first
    end

    def team
      teams.first
    end

    def user
      users.first
    end

    def with(*items)
      items.each do |item|
        self.send("create_#{item}")
      end
      self
    end

    def create_assignment(attributes={})
      course = attributes.delete(:course) || self.course || FactoryGirl.build(:course)
      assignments << FactoryGirl.create(:assignment, attributes.merge(course: course))
      self
    end

    def create_badge(attributes={})
      course = attributes.delete(:course) || self.course || FactoryGirl.build(:course)
      badges << FactoryGirl.create(:badge, attributes.merge(course: course))
      self
    end

    def create_course(attributes={})
      courses << FactoryGirl.create(:course, attributes)
      self
    end

    def create_criterion(attributes={})
      assignment = attributes.delete(:assignment) || self.assignment || FactoryGirl.build(:assignment)
      rubric = attributes.delete(:rubric) || self.rubric || FactoryGirl.build(:rubric, assignment: assignment)
      criteria << FactoryGirl.create(:criterion, attributes.merge(rubric: rubric))
    end

    def create_criterion_grade(attributes={})
      assignment = attributes.delete(:assignment) || self.assignment || FactoryGirl.build(:assignment)
      student = attributes.delete(:student) || self.student || FactoryGirl.build(:user)
      rubric = attributes.delete(:rubric) || self.rubric || FactoryGirl.build(:rubric, assignment: assignment)
      criterion = attributes.delete(:criterion) || self.criterion || FactoryGirl.build(:criterion, assignment: assignment)
      criterion_grades << FactoryGirl.create(:criterion_grade, \
        attributes.merge(assignment: assignment, student: student, criterion: criterion))
      self
    end

    def create_grade(attributes={})
      assignment = attributes.delete(:assignment) || self.assignment || FactoryGirl.build(:assignment)
      assignment_type = attributes.delete(:assignment_type) || assignment.assignment_type
      course = attributes.delete(:course) || self.course || FactoryGirl.build(:course)
      student = attributes.delete(:student) || self.student || FactoryGirl.build(:user)
      grades << FactoryGirl.create(:grade, attributes.merge(assignment: assignment, assignment_type: assignment_type,
                                                            course: course, student: student))
      self
    end

    def create_rubric(attributes={})
      assignment = attributes.delete(:assignment) || self.assignment || FactoryGirl.build(:assignment)
      rubrics << FactoryGirl.create(:rubric, attributes.merge(assignment: assignment))
      self
    end

    def create_student(attributes={})
      course = attributes.delete(:course) || self.course
      user = FactoryGirl.create(:user, attributes)
      course_memberships << FactoryGirl.create(:course_membership, course: course, user: user, role: "student") if course
      users << user
      self
    end

    def create_team(attributes={})
      course = attributes.delete(:course) || self.course
      teams << FactoryGirl.create(:team, attributes.merge(course: course))
      self
    end

    private

    def initialize
      @assignments = []
      @badges = []
      @courses = []
      @criteria = []
      @criterion_grades = []
      @course_memberships = []
      @grades = []
      @rubrics = []
      @teams = []
      @users = []
    end
  end
end
