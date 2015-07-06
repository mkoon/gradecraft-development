class ExistingMetricSerializer < ActiveModel::Serializer
  cached
  delegate :cache_key, to: :object

  attributes :id, :name, :description, :max_points, :rubric_id, :order
  has_many :tiers, serializer: ExistingTierSerializer
  has_many :metric_badges, serializer: ExistingMetricBadgeSerializer

  def tiers
    object.tiers.order("points ASC")
  end

  def metric_badges
    object.metric_badges.order("created_at ASC")
  end
end
