class MessagesController < ApplicationController
  # POST /chats/:chat_id/messages
  def create
    @chat = current_user.chats.find(params[:chat_id])

    # 1. Save what the user wrote
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      # 2. Use the first message as the chat's title, so it's easy to find in "My chats"
      if @chat.messages.count == 1
        @chat.update(title: @message.content.truncate(50))
      end

      # 3. Ask the mentor (the AI) for an answer, and save it as a message too
      answer = ask_mentor

      if answer.present?
        Message.create(role: "assistant", content: answer, chat: @chat)
        redirect_to chat_path(@chat)
      else
        redirect_to chat_path(@chat), alert: "#{@chat.mentor.name} couldn't answer right now. Please try again."
      end
    else
      # The message was empty: show the chat page again with the error
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end

  # Sends the whole conversation to the AI and returns the mentor's answer as text.
  # Sending ALL the messages every time is how the mentor "remembers" the conversation.
  def ask_mentor
    llm_chat = RubyLLM.chat(model: "gpt-4.1-mini")

    # The system prompt is the mentor's personality (saved in the seeds).
    # We also tell the mentor the user's first name, so it feels personal.
    llm_chat.with_instructions(
      "#{@chat.mentor.system_prompt} " \
      "The person you are talking to is called #{current_user.first_name}."
    )

    # Give the AI every message of this chat, oldest first
    @chat.messages.order(:created_at).each do |message|
      llm_chat.add_message(role: message.role.to_sym, content: message.content)
    end

    # Ask the AI to write the next message (the mentor's answer)
    response = llm_chat.complete
    response.content
  rescue RubyLLM::Error, RubyLLM::ConfigurationError => e
    # Something went wrong (no API key, no internet, the AI is busy...).
    # Write it in the server logs so we can see what happened, and return nothing.
    Rails.logger.error("AI error: #{e.class} - #{e.message}")
    nil
  end
end
