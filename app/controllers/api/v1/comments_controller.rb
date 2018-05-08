module Api
	module V1
		class CommentsController < ApplicationController
			skip_before_action :verify_authenticity_token

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

			def submission_comments
				comments = Comment.where("submission_id=?", params[:id]).order("created_at DESC")
				render json: {status: 'SUCCESS', message: 'Comments from submission', data: comments}, status: :ok
			end

			def threads
				@pre = Comment.all.order("created_at DESC") | Reply.all.order("created_at DESC");
      			@commentsandreplies = @pre.sort_by { |t| t.created_at }.reverse!;
      		end
		end
	end
end