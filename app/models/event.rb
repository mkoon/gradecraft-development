class Event < ActiveRecord::Base

  attr_accessible :course_id, :name, :description, :media, :media_credit, :thumbnail, :media_caption, :open_at,
  :due_at, :remove_media, :remove_thumbnail

  mount_uploader :media, ImageUploader
  mount_uploader :thumbnail, ThumbnailUploader

  validates :media, file_size: { maximum: 2.megabytes.to_i }
  validates :thumbnail, file_size: { maximum: 2.megabytes.to_i }

  belongs_to :course, touch: true

  scope :with_dates, -> { where('events.due_at IS NOT NULL OR events.open_at IS NOT NULL') }

  # Check to make sure the event has a name before saving
  validates_presence_of :name

  def content
    content = ""
    if description.present?
      content << description
    end
  end
end
