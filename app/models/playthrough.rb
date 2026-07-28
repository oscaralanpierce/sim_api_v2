# frozen_string_literal: true

class Playthrough < ApplicationRecord
  belongs_to :user

  validates :name,
            presence: true,
            uniqueness: {
              scope: :user_id,
              message: 'must be unique',
            }

  before_validation :set_name

  scope :index_order, -> { order(updated_at: :desc) }

  private

  def set_name
    self.name = if name.present?
                  name.strip
                else
                  "My Playthrough #{highest_integer_in_default_name + 1}"
                end
  end

  def highest_integer_in_default_name
    # Value will be at least 0 because the regex doesn't match values containing
    # "-". Value will be an integer because the regex doesn't match values
    # containing ".".
    user
      .playthroughs
      .where("name SIMILAR TO 'My Playthrough [[:digit:]]{1,}'")
      .pluck(:name)
      .map {|n| n.scan(/\d+$/).first.to_i }
      .max || 0
  end
end
