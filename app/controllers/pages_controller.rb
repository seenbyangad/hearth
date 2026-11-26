class PagesController < ApplicationController
  # The home page is public, so people can see it without logging in
  skip_before_action :authenticate_user!, only: :home

  def home
    @mentors = Mentor.all
  end
end
