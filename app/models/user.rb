# frozen_string_literal: true

class User < ApplicationRecord
  has_many :playthroughs, dependent: :destroy

  validates :uid,
            presence: true,
            uniqueness: {
              message: 'must be unique',
            }

  validates :email,
            presence: true,
            uniqueness: {
              message: 'must be unique',
            }

  def self.create_or_update_from_google!(data)
    where(uid: data['sub']).first_or_initialize.tap do |user|
      user.uid = data['sub']
      user.email = data['email']
      user.display_name = data['name']
      user.photo_url = data['picture']
      user.save!
    end
  end
end
