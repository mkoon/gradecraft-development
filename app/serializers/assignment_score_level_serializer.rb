class AssignmentScoreLevelSerializer < ActiveModel::Serializer
  attributes :id, :name, :value, :assignment_id
end
