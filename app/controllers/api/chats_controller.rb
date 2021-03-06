class Api::ChatsController < ApplicationController
  def index
    if current_user
      if params[:query].length > 0
        @chats = current_user.chats.where("LOWER(name) ILIKE ?", "%#{params[:query]}%")
      else 
        @chats = current_user.chats
      end
    else
      render json: {}
    end
  end

  def create
    @names = []
    @ids = []

    params[:members].each do |_, member|
       @names.push(member[:username])
       @ids.push(member[:id].to_i)
    end

    @chat = Chat.new(name: @names.join(", "))

    @errors = []

    @user_chats = current_user.chats.includes(:members)
    @user_chats.find_each do |chat|
      @member_ids = chat.members.pluck(:id)

      if (@member_ids.size == @ids.size) && ((@member_ids & @ids) == @member_ids)
        @exists = true
        @chat = chat
        break
      end
    end

    if @exists 
      render :show
    elsif @chat.save
      params[:members].each do |_, member|
        @membership = ChatMembership.new(
          member_id: member[:id], 
          chat_id: @chat[:id]
        )

        unless @membership.save
          @errors = errors.concat(@membership.errors.full_messages)
        end
      end

      if @errors.empty?
        render :show # just merge the new one
      else
        render json: errors, status: 422        
      end
    else
      render json: @chat.errors.full_messages, status: 422
    end
  end

  def show
    @chats = current_user.chats.where("chats.id = ?", params[:id])
    @limit = params[:limit]
    @chat = @chats[0]
    
    if @chat
      render :show
    else
      render json: ["Chat does not exist for this user!"], status: 404
    end
  end

  def update
    @chat = Chat.find_by(id: params[:id])
    @limit = params[:limit]
    @errors = []

    # Add new members
    unless params[:members].nil?
      params[:members].each do |_, member|
        @membership = ChatMembership.new(
          member_id: member[:id], 
          chat_id: @chat[:id]
        )

        unless @membership.save
          @errors = @errors.concat(@membership.errors.full_messages)
        end
      end

      @names = []

      params[:members].each do |_, member|
        @names.push(member[:username])
      end


      if @errors.empty?

        if @chat.update(name: "#{@chat[:name]}, #{@names.join(', ')}")

          @message = Message.new(
            body: "#{current_user[:username]} added #{@names.join(', ')} to the group",
            author_id: current_user[:id],
            chat_id: @chat[:id]
          )

          if @message.save
            render :show # just merge edited one
          else
            render json: @message.errors.full_messages, status: 422
          end
        else
          render json: @chat.errors.full_messages, status: 422 
        end
      else
        render json: @membership.errors.full_messages, status: 422
      end

    # Change name/pic instead

    else 
      if params[:name] != "" && params[:name] != nil
        @body = "#{current_user[:username]} changed the chat name to #{params[:name]}" 
        @chat.assign_attributes(name: params[:name])
      else
        @body = "#{current_user[:username]} updated the chat picture"
        @chat.assign_attributes(chat_image: params[:chat_image])
      end

      if @chat.save

        @message = Message.new(
          body: @body,
          author_id: current_user[:id],
          chat_id: @chat[:id]
        )

        if @message.save
          render :show
        else
          render json: @membership.errors.full_messages, status: 422
        end
      else
        render json: @chat.errors.full_messages, status: 422
      end
    end
  end

  private

  def chat_params
    params.require(:chat).permit(:name, :chat_pic_url)
  end
end