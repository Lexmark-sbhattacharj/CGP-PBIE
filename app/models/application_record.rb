# frozen_string_literal: true

# application top level model
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
