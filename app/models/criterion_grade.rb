class CriterionGrade < ActiveRecord::Base
  attr_accessible :points, :criterion_id, :level_id,
    :student_id, :assignment_id, :comments, :student, :assignment, :criterion

  belongs_to :criterion
  belongs_to :level
  belongs_to :student, class_name: "User"
  belongs_to :assignment

  scope :for_course, ->(course) do
    joins("LEFT OUTER JOIN assignments ON criterion_grades.assignment_id =\
           assignments.id")
      .where("assignments.course_id = :course_id", course_id: course.id)
  end

  scope :for_student, ->(student) { where(student_id: student.id) }

  validates :assignment_id, presence: true
  validates :criterion_id, presence: true
  validates :student_id, presence: true

  def self.find_or_create(assignment_id, criterion_id, student_id)
    CriterionGrade.where(student_id: student_id, criterion_id: criterion_id).first || \
    CriterionGrade.create(assignment_id: assignment_id, criterion_id: criterion_id, student_id: student_id)
  end
end
