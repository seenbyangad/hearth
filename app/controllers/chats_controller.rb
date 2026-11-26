class ChatsController < ApplicationController
  # GET /chats
  # A list of all my past chats, newest first
  def index
    @chats = current_user.chats.order(created_at: :desc)
  end

  # GET /chats/:id
  def show
    # Only look inside the logged-in user's own chats,
    # so nobody can read someone else's chat by changing the number in the URL.
    @chat = current_user.chats.find(params[:id])

    # An empty message for the "send a message" form at the bottom of the page
    @message = Message.new
  end

  # POST /mentors/:mentor_id/chats
  def create
    @mentor = Mentor.find(params[:mentor_id])

    @chat = Chat.new(title: "Chat with #{@mentor.name}")
    @chat.mentor = @mentor
    @chat.user = current_user

    if @chat.save
      redirect_to chat_path(@chat)
    else
      redirect_to mentor_path(@mentor), alert: "Sorry, we couldn't start the chat. Please try again."
    end
  end
end
