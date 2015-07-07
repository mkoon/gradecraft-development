class RubricsController < ApplicationController
  before_action :find_rubric, except: [:design, :create, :existing_metrics, :course_badges]

  respond_to :html, :json

  def design
    @assignment = current_course.assignments.find params[:assignment_id]
    @rubric = @assignment.rubric
    @course_badge_count = @assignment.course.badges.visible.count
    @title = "Design Rubric for #{@assignment.name}"
    respond_with @rubric
  end

  def create
    @rubric = Rubric.create params[:rubric]
    respond_with @rubric
  end

  def destroy
    @rubric.destroy
    respond_with @rubric
  end

  def show
    respond_with @rubric
  end

  def update
    @rubric.update_attributes params[:rubric]
    respond_with @rubric, status: :not_found
  end

  def existing_metrics
    @assignment = current_course.assignments.find params[:assignment_id]
    @rubric = @assignment.rubric
    metrics = ActiveModel::ArraySerializer.new(
                @rubric.metrics.order(:order).includes(:tiers),
                  each_serializer: ExistingMetricSerializer
              )
    json = cache ['v1', metrics] do
            MultiJson.dump(metrics)
          end
    render json: json
  end

  def course_badges
    @assignment = current_course.assignments.find params[:assignment_id]
    render json:  MultiJson.dump(
                    ActiveModel::ArraySerializer.new(
                      find_course_badges, each_serializer: CourseBadgeSerializer
                    )
                  )
  end

  private

  def find_course_badges
     @course_badges ||= @assignment.course.badges.visible
  end

  def find_rubric
    @rubric = @assignment.rubric
  end
end
