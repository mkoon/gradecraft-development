require_relative "submission_presenter"

class NewSubmissionPresenter < SubmissionPresenter
  def submission
    @submission ||= properties[:submission] || assignment.submissions.new
  end

  def student
    properties[:student] || view_context.current_student
  end

  def title
    "Submit #{assignment.name} (#{view_context.points assignment.point_total} #{"point".pluralize(assignment.point_total)})"
  end
end
