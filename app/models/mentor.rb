class Mentor < ApplicationRecord
  has_many :chats, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :specialty, presence: true
  validates :system_prompt, presence: true
end
