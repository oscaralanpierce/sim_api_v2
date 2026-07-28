# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def errors_array
    errors.map {|error| "#{error.attribute.capitalize} #{error.message}" }
  end
end
