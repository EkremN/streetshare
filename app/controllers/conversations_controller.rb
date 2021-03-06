class ConversationsController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  def index
    @users = User.all
    @conversations = Conversation.where(sender: current_user).or(Conversation.where(recipient: current_user))
  end

  def create
    if Conversation.between(params[:sender_id], params[:recipient_id]).present?
      @conversation = Conversation.between(params[:sender_id], params[:recipient_id]).first
    else
      @conversation = Conversation.create!(conversation_params)
    end
    redirect_to conversations_path(conversation_id: @conversation.id)
  end

  def toggle
    @conversation = Conversation.find(params[:conversation].to_i)
  end

  private

  def conversation_params
    params.permit(:sender_id, :recipient_id)
  end
end
