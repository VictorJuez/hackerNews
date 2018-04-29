class CommentsController < ApplicationController
    before_action :set_comment, only: [:show, :edit, :update, :destroy]
    
    def vote
      @comment = Comment.find(params[:id])
      auth_user = current_user
      begin
        tmp = User.where("oauth_token=?", request.headers["HTTP_API_KEY"])[0]
        if (tmp)
          auth_user = tmp
        end
      rescue
        # intentionally left out
      end
      begin
        auth_user.vote_for(@comment)
      rescue
        # ok
      end
      respond_to do |format|
        format.html {redirect_to request.referer}
        format.json { render :json => @comment }
      end
    end
    
    def votes
      thing = Comment.find(params[:id])
      auth_user = current_user
      begin
        tmp = User.where("oauth_token=?", request.headers["HTTP_API_KEY"])[0]
        if (tmp)
          auth_user = tmp
        end
      rescue
        # intentionally left out
      end
      if (auth_user)
        render :json => { "votes" => thing.votes.size, "voted" => auth_user.voted_for?(thing)}
        return;
      else
        render :json => { "votes" => thing.votes.size, "voted" => false}
        return;
      end
    end
    
    def new_reply
      @comment = Comment.find(params[:id])
      @replies = Reply.where("comment_id=?",@comment.id).order("created_at DESC")
    end
    
    def threads
      @pre = Comment.all.order("created_at DESC") | Reply.all.order("created_at DESC");
      @commentsandreplies = @pre.sort_by { |t| t.created_at }.reverse!;
    end
    
    def user_comments
      begin
        @user = User.find(params[:user])
        @comments = Comment.where("user_id=?", params[:user]).order("created_at DESC")
      rescue ActiveRecord::RecordNotFound
        render :json => { "code" => "404", "message" => "User not found."}, status: :not_found
      end
    end
    
    def submission_comments
      begin
        @comments = Comment.where("submission_id=?", params[:id]).order("created_at DESC")
      rescue ActiveRecord::RecordNotFound
        render :json => { "code" => "404", "message" => "Submission not found."}, status: :not_found
      end
    end
  
    # GET /comments
    # GET /comments.json
    def index
      @comments = Comment.all
    end
  
    # GET /comments/1
    # GET /comments/1.json
    def show
    end
  
    # GET /comments/new
    def new
      @comment = Comment.new
    end
  
    # GET /comments/1/edit
    def edit
    end
  
    # POST /comments
    # POST /comments.json
    def create
      
      auth_user = current_user
      begin
        tmp = User.where("oauth_token=?", request.headers["HTTP_API_KEY"])[0]
        if (tmp)
          puts tmp.name
          auth_user = tmp
        end
      rescue
        # intentionally left out
      end
      
      if auth_user
        @comment = Comment.new(comment_params)
        @comment.user = auth_user
        
        respond_to do |format|
          if @comment.save
            #auth_user&.vote_for(@comment)
            format.html { redirect_to @comment.submission, notice: 'Comment was successfully created.' }
            format.json { render :show, status: :created, location: @comment }
          else
            format.html { redirect_to @comment.submission, notice: 'Comment not created, you have to fill de field content' }
            format.json { render json: @comment.errors, status: :unprocessable_entity }
          end
        end
      else
        redirect_to "/auth/google_oauth2"
      end
    end
  
    # PATCH/PUT /comments/1
    # PATCH/PUT /comments/1.json
    def update
      respond_to do |format|
        if @comment.update(comment_params)
          format.html { redirect_to @comment.submission, notice: 'Comment was successfully updated.' }
          format.json { render :show, status: :ok, location: @comment }
        else
          format.html { render :edit }
          format.json { render json: @comment.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /comments/1
    # DELETE /comments/1.json
    def destroy
      @comment.destroy
      respond_to do |format|
        format.html { redirect_to comments_url, notice: 'Comment was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_comment
        @comment = Comment.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def comment_params
        params.require(:comment).permit(:content, :user_id, :submission_id)
      end
  end
  