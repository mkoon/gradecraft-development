class Grade < ActiveRecord::Base
  include Canable::Ables

  attr_accessible :assignment, :assignment_id, :assignment_type_id, :assignments_attributes,
                  :attempted, :course_id, :feedback, :final_score, :grade_file, :grade_file_ids,
                  :grade_files_attributes, :graded_by_id, :group, :group_id, :group_type,
                  :instructor_modified, :pass_fail_status, :point_total, :predicted_score,
                  :raw_score, :released, :status, :student, :student_id, :submission, :_destroy,
                  :submission_id, :task, :task_id, :team_id,  :earned_badges, :earned_badges_attributes

  STATUSES= ["In Progress", "Graded", "Released"]

  # Note Pass and Fail use term_for in the views
  PASS_FAIL_STATUS = ["Pass", "Fail"]

  belongs_to :course, touch: true
  belongs_to :assignment, touch: true
  belongs_to :assignment_type, touch: true
  belongs_to :student, :class_name => 'User', touch: true
  belongs_to :team, touch: true
  belongs_to :submission, touch: true # Optional
  belongs_to :task, touch: true # Optional
  belongs_to :group, :polymorphic => true, touch: true # Optional
  belongs_to :graded_by, class_name: 'User', touch: true

  has_many :earned_badges, :dependent => :destroy

  has_many :badges, :through => :earned_badges
  accepts_nested_attributes_for :earned_badges, :reject_if => proc { |a| (a['score'].blank?) }, :allow_destroy => true

  before_validation :cache_associations
  before_save :cache_point_total
  before_save :zero_points_for_pass_fail

  has_many :grade_files, :dependent => :destroy
  accepts_nested_attributes_for :grade_files

  validates_presence_of :assignment, :assignment_type, :course, :student
  validates :assignment_id, :uniqueness => {:scope => :student_id}

  delegate :name, :description, :due_at, :assignment_type, :to => :assignment

  before_save :clean_html
  after_destroy :cache_student_and_team_scores

  scope :completion, -> { where(order: "assignments.due_at ASC", :joins => :assignment) }
  scope :graded, -> { where('status = ?', 'Graded') }
  scope :in_progress, -> { where('status = ?', 'In Progress') }
  scope :released, -> { joins(:assignment).where("status = 'Released' OR (status = 'Graded' AND NOT assignments.release_necessary)") }
  scope :graded_or_released, -> { where("status = 'Graded' OR status = 'Released'")}
  scope :not_released, -> { joins(:assignment).where("status = 'Graded' AND assignments.release_necessary")}
  scope :instructor_modified, -> { where('instructor_modified = ?', true) }
  scope :positive, -> { where('score > 0')}


  #validates_numericality_of :raw_score, integer_only: true

  def self.score
    pluck('COALESCE(SUM(grades.score), 0)').first
  end

  def self.predicted_points
    #Only return back the total predicted points for a user, not including points they have been scored on
    scoped.not_released.pluck('COALESCE(SUM(grades.predicted_score), 0)').first
  end

  def self.assignment_scores
    pluck('grades.assignment_id, grades.score')
  end

  def self.assignment_type_scores
    group('grades.assignment_type_id').pluck('grades.assignment_type_id, COALESCE(SUM(grades.score), 0)')
  end

  def is_graded?
    self.status == 'Graded'
  end

  def in_progress?
    self.status == 'In Progress'
  end

  def score
    if student.weighted_assignments?
      final_score || ((raw_score * assignment_weight).round if raw_score.present?)  || nil
    else
      final_score || raw_score
    end
  end

  def predicted_score
    self[:predicted_score] || 0
  end

  def point_total
    assignment.point_total_for_student(student)
  end

  def assignment_weight
    assignment.weight_for_student(student)
  end

  def has_feedback?
    feedback != "" && feedback != nil
  end

  def is_released?
    status == 'Released' || (status = 'Graded' && ! assignment.release_necessary)
  end

  def is_graded_or_released?
    is_graded? || is_released?
  end

  def status_is_graded_or_released?
    self.status == "Graded" || self.status == "Released"
  end
  alias_method :graded_or_released?, :status_is_graded_or_released?

  #Canable Permissions
  def updatable_by?(user)
    creator == user
  end

  def creatable_by?(user)
    student_id == user.id
  end

  def viewable_by?(user)
    student_id == user.id
  end

  def cache_student_and_team_scores
    self.student.cache_course_score(self.course.id)
    if self.course.has_teams? && self.student.team_for_course(self.course).present?
      self.student.team_for_course(self.course).cache_score
    end
  end

  def altered?
    self.score_changed? == true  || self.feedback_changed? == true
  end

  private

  def clean_html
    self.feedback = Sanitize.clean(feedback, Sanitize::Config::BASIC)
  end

  def save_student
    if self.raw_score_changed? || self.status_changed?
      student.save
    end
  end

  def save_team
    if course.has_teams? && student.team_for_course(course).present?
      student.team_for_course(course).save
    end
  end

  def cache_point_total
    self.score = score
    self.point_total = point_total
  end

  def cache_associations
    self.student_id ||= submission.try(:student_id)
    self.task_id ||= submission.try(:task_id)
    self.assignment_id ||= submission.try(:assignment_id) || task.try(:assignment_id)
    self.assignment_type_id ||= assignment.try(:assignment_type_id)
    self.course_id ||= assignment.try(:course_id)
    #self.team_id ||= student.team_for_course(course).try(:id)
  end

  def zero_points_for_pass_fail
    if self.assignment.pass_fail?
      self.raw_score = 0
      self.final_score = 0
      self.point_total = 0

      # use 1 for pass, 0 for fail
      self.predicted_score = 1 if self.predicted_score > 1
    end
  end

  def duplicate_badge_for_grade
    if self.earned_badges.where(:badge_id => earned_badge.badge_id).persisted?
      errors.add("")
    end
  end
end
