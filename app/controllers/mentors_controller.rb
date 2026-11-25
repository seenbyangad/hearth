class MentorsController < ApplicationController
  # GET /mentors
  def index
    @mentors = Mentor.all
  end

  # GET /mentors/:id
  def show
    @mentor = Mentor.find(params[:id])
  end
end
