class GradeSerializer < ActiveModel::Serializer
  attributes :id, :status, :raw_score, :feedback, :is_custom_value
end
