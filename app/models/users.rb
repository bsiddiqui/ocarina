class Users < ActiveRecord::Base
  validates :name, :email, presence: true
end
