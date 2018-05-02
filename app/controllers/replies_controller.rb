class RepliesController < ApplicationController
  before_action :set_reply, only: [:show, :edit, :update, :destroy]

  # GET /replies
  # GET /replies.json
  def index
    @replies = Reply.all
  end

  # GET /replies/1
  # GET /replies/1.json
  def show
  end

  # GET /replies/new
  def new
    @reply = Reply.new
  end

  # GET /replies/1/edit
  def edit
  end

  # POST /replies
  # POST /replies.json
  def create
    if current_user
      @reply = Reply.new(reply_params)
      if !reply_params[:content].blank?
        respond_to do |format|
          if @reply.save
            format.html { redirect_to @reply.comment.submission }
            format.json { render :show, status: :created, location: @reply }
          else
            format.html { redirect_to '/comments/' + (@reply.comment.id).to_s + '/new_reply' }
            format.json { render json: @reply.errors, status: :unprocessable_entity }
          end
        end
      else
         redirect_to "/comments/" + (@reply.comment.id).to_s + "/new_reply", :notice => "Write a reply"
      end
    else
      redirect_to "auth/google_oauth2"
    end
  end

  # PATCH/PUT /replies/1
  # PATCH/PUT /replies/1.json
  def update
    respond_to do |format|
      if @reply.update(reply_params)
        format.html { redirect_to @reply }
        format.json { render :show, status: :ok, location: @reply }
      else
        format.html { render :edit }
        format.json { render json: @reply.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /replies/1
  # DELETE /replies/1.json
  def destroy
    @reply.destroy
    respond_to do |format|
      format.html { redirect_to replies_url }
      format.json { head :no_content }
    end
  end

  private
    def set_reply
      @reply = Reply.find(params[:id])
    end

    def reply_params
      params.require(:reply).permit(:content, :user_id, :comment_id)
    end
end
