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

  # Sends the whole conversation to Claude and returns the mentor's answer as text.
  # Sending ALL the messages every time is how the mentor "remembers" the conversation.
  def ask_mentor
    # Claude wants the conversation as a list like:
    #   [{ role: "user", content: "Hi" }, { role: "assistant", content: "Hello!" }, ...]
    # Our messages table has exactly these two columns, so we just copy them over.
    conversation = []
    @chat.messages.order(:created_at).each do |message|
      conversation << { role: message.role, content: message.content }
    end

    # The system prompt is the mentor's personality (saved in the seeds).
    # We also tell the mentor the user's first name, so it feels personal.
    instructions = "#{@chat.mentor.system_prompt} " \
                   "The person you are talking to is called #{current_user.first_name}."

    # The client reads the ANTHROPIC_API_KEY from the .env file
    client = Anthropic::Client.new

    response = client.beta.messages.create(
      model: "claude-opus-5-5",
      max_tokens: 1000,
      system_: instructions,
      messages: conversation,
      # Short chat answers don't need deep thinking, and "low" answers faster
      output_config: { effort: "low" },
      # If Claude says no to a message for safety reasons, Anthropic automatically tries another model
      fallbacks: "default",
      betas: ["server-side-fallback-2026-07-01"]
    )

    # The answer comes back in "blocks". We only keep the text blocks.
    answer = ""
    response.content.each do |block|
      answer += block.text if block.type == :text
    end
    answer
  rescue Anthropic::Errors::Error => e
    # Something went wrong (no API key, no internet, Claude is busy...).
    # Write it in the server logs so we can see what happened, and return nothing.
    Rails.logger.error("Claude error: #{e.class} - #{e.message}")
    nil
  end
end
