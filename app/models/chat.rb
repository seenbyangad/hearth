class Chat < ApplicationRecord
  belongs_to :user
  belongs_to :mentor

  validates :title, presence: true
end
