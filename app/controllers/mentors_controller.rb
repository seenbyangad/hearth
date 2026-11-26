class MentorsController < ApplicationController
  # GET /mentors
  def index
    @mentors = Mentor.all
  end

  # GET /mentors/:id
  def show
    @mentor = Mentor.find(params[:id])

    # My past chats with this mentor, newest first
    @chats = current_user.chats.where(mentor: @mentor).order(created_at: :desc)
  end
end
