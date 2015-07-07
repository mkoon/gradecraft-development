class ExistingTierSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :points, :full_credit, :no_credit, :durable
  has_many :tier_badges, serializer: ExistingTierBadgeSerializer

  def tier_badges
    object.tier_badges.order("created_at ASC")
  end
end
