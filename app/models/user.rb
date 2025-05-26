class User < ApplicationRecord
  # Include default devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :user_locations, dependent: :destroy
  has_many :locations, through: :user_locations
  has_many :weather_alerts, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :timezone, presence: true

  # Scopes
  scope :with_alerts, -> { joins(:weather_alerts).distinct }
  scope :active, -> { where(active: true) }

  # Methods
  def favorite_locations
    locations.order("user_locations.created_at DESC")
  end

  def add_location(location)
    locations << location unless locations.include?(location)
  end

  def remove_location(location)
    locations.delete(location)
  end

  def has_weather_alerts?
    weather_alerts.any?
  end

  def active_alerts
    weather_alerts.where(active: true)
  end

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def default_location
    user_locations.find_by(is_default: true)&.location
  end

  def set_default_location(location)
    user_locations.update_all(is_default: false)
    user_locations.find_or_create_by(location: location).update(is_default: true)
  end
end
