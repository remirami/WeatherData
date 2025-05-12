class UserLocation < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :location

  # Validations
  validates :user, presence: true
  validates :location, presence: true
  validates :user_id, uniqueness: { scope: :location_id }
  validates :is_default, uniqueness: { scope: :user_id }, if: :is_default?

  # Scopes
  scope :favorites, -> { where(favorite: true) }
  scope :recently_added, -> { order(created_at: :desc) }
  scope :default, -> { where(is_default: true) }
  scope :with_notifications, -> { where(notification_enabled: true) }

  # Callbacks
  before_save :ensure_single_default

  # Methods
  def toggle_favorite
    update(favorite: !favorite)
  end

  def favorite?
    favorite
  end

  private

  def ensure_single_default
    if is_default? && is_default_changed?
      user.user_locations.where.not(id: id).update_all(is_default: false)
    end
  end
end 