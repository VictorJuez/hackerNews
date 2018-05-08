module Api
	module V1
		class CommentsController < ApplicationController
			skip_before_action :verify_authenticity_token

			def create
				begin
					user = User.where(:uid => request.headers['Authorization']).first
					if user
						current_user = user
					end
				rescue Exception => e
					#empty
				end	
				comment = Comment.new(comment_params)
				if current_user
					if !comment_params[:content].blank?
						comment.user = current_user
						comment.vote_by :voter => current_user
						submission = Submission.find(params[:id])
						comment.submission = submission
						if comment.save
							render json: {status: 'SUCCESS', message: 'Comment created correctly', data: comment.errors}, status: :unprocessable_entity
						else
							render json: {status: 'ERROR', message: 'Error in data base', data: comment.errors}, status: :unprocessable_entity
						end
					else
						render json: {status: 'ERROR', message: 'Comment can not be blank', data: comment.errors}, status: :unprocessable_entity
					end
				else
					render json: {status: 'ERROR', message: 'Error in authenticity', data: comment.errors}, status: :unprocessable_entity
				end
			end

			def vote
				comment = Comment.find(params[:id])
				begin
					user = User.where(:uid => request.headers['Authorization']).first
					if user
						current_user = user
					end
				rescue Exception => e
					#empty
				end	
			    if current_user
			    	if !current_user.voted_for?(comment)
				      	comment.liked_by current_user
				      	render json: {status: 'SUCCESS', message: 'Vote saved', data: 
				      		[{"Actual votes": comment.get_upvotes.size}]}, status: :ok
				    else
				    	render json: {status: 'ERROR', message: 'User has already voted this comment', data: comment.errors}, status: :unprocessable_entity
				    end
			    else 
			      	render json: {status: 'ERROR', message: 'Error in authenticity', data: comment.errors}, 
							status: :unprocessable_entity
			    end
			end

			def unvote
				comment = Comment.find(params[:id])
				begin
					user = User.where(:uid => request.headers['Authorization']).first
					if user
						current_user = user
					end
				rescue Exception => e
					#empty
				end
			  	if current_user
				  	if current_user.voted_for?(comment)
				  		if current_user.id != comment.user.id
					      	comment.unliked_by current_user
					      	render json: {status: 'SUCCESS', message: 'Unvote saved', data: 
					      		[{"Actual votes": comment.get_upvotes.size}]}, status: :ok
					    else
							render json: {status: 'ERROR', message: 'User cannot unvote its own comment', data: comment.errors}, status: :unprocessable_entity
				    	end
				    else
				    	render json: {status: 'ERROR', message: 'User has already unvoted this comment', data: comment.errors}, status: :unprocessable_entity
			    	end
			    else
			      	render json: {status: 'ERROR', message: 'Error in authenticity', data: comment.errors}, 
							status: :unprocessable_entity
			    end
			end

			def update
				begin
					user = User.where(:uid => request.headers['Authorization']).first
					if user
						current_user = user
					end
				rescue Exception => e
					#empty
				end
				comment = Comment.find(params[:id])
				if current_user
					if current_user.id == comment.user.id
						comment.update(comment_params)
				    	render json: {status: 'SUCCESS', message: 'Comment updated correctly', data: comment}, status: :ok
					else
						render json: {status: 'ERROR', message: 'Can not update someones comment', data: comment.errors}, status: :unprocessable_entity
					end
				else
				    render json: {status: 'ERROR', message: 'Error in authenticity', data: comment.errors}, status: :unprocessable_entity
				end

			end

			def submission_comments
				comments = Comment.where("submission_id=?", params[:id]).order("created_at DESC")
				render json: {status: 'SUCCESS', message: 'Comments from submission', data: comments}, status: :ok
			end

			def threads
        		comments = Comment.where("user_id=?", params[:id]).order("created_at DESC")
				render json: {status: 'SUCCESS', message: 'User comments', data: comments}, status: :ok
      		end

      		def comment
      			 comment = Comment.find(params[:id])
      			 render json: {status: 'SUCCESS', message: 'Comment', data: comment}, status: :ok
      		end
      			
			def comment_params
				params.require(:comment).permit(:content, :submission_id)
			end

		end
	end
end