# frozen_string_literal: true

class User < ApplicationRecord
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
end
