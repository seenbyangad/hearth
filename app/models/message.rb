class Message < ApplicationRecord
  belongs_to :chat

  # "user" = written by the person, "assistant" = written by the mentor (the AI)
  validates :role, inclusion: { in: ["user", "assistant"] }
  validates :content, presence: true
end
