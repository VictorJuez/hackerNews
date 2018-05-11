module Api
	module V1
		class RepliesController < ApplicationController
			skip_before_action :verify_authenticity_token

			# Comments replies 
			def create
				begin
					user = User.where(:api_key => request.headers['Authorization']).first
					if user
						current_user = user
					end
				rescue Exception => e
					#empty
				end	
				reply = Reply.new(reply_params)
				if current_user
					replyorcomment = Comment.where("id = ?", params[:id]).first
					#replyorcomment = Reply.where("id = ?", params[:id])
					if replyorcomment.nil?
						render json: {status: 'ERROR', message: 'Comment does not exist', data: nil}, :status => 404
					else
						if !reply_params[:content].blank?
							#puts replyorcomment.inspect
							reply.comment = replyorcomment
							reply.user = current_user
							reply.submission = replyorcomment.submission

							if reply.save
								reply.vote_by :voter => current_user
								render json: {status: 'SUCCESS', message: 'Reply created correctly', data: reply}, status: :ok
							else
								render json: {status: 'ERROR', message: 'Error in data base', data: nil}, status: :unprocessable_entity
							end
						else
							render json: {status: 'ERROR', message: 'Reply can not be blank', data: nil}, status: :unprocessable_entity
						end
					end
				else
					render json: {status: 'ERROR', message: 'Error in authenticity', data: nil}, :status => 403
				end
			end

			# Replies reply
			def create_reply
				begin
					user = User.where(:api_key => request.headers['Authorization']).first
					if user
						current_user = user
					end
				rescue Exception => e
					#empty
				end	
				reply = Reply.new(reply_params)
				if current_user
					replyorcomment = Reply.where("id = ?", params[:id]).first
					#replyorcomment = Reply.where("id = ?", params[:id])
					if replyorcomment.nil?
						render json: {status: 'ERROR', message: 'Reply does not exist', data: nil}, :status => 404
					else
						if !reply_params[:content].blank?
							#puts replyorcomment.inspect
							reply.parent = replyorcomment
							reply.user = current_user
							reply.submission = replyorcomment.submission

							if reply.save
								reply.vote_by :voter => current_user
								render json: {status: 'SUCCESS', message: 'Reply created correctly', data: reply}, status: :ok
							else
								render json: {status: 'ERROR', message: 'Error in data base', data: nil}, status: :unprocessable_entity
							end
						else
							render json: {status: 'ERROR', message: 'Reply can not be blank', data: nil}, status: :unprocessable_entity
						end
					end
				else
					render json: {status: 'ERROR', message: 'Error in authenticity', data: nil}, :status => 403
				end
			end

			def vote
				begin
					user = User.where(:api_key => request.headers['Authorization']).first
					if user
						current_user = user
					end
				rescue Exception => e
					#empty
				end	
				if current_user
					reply = Reply.where("id = ?" , params[:id]).first
					if reply.nil?
						render json: {status: 'ERROR', message: 'Reply does not exist', data: nil}, :status => 404
					else				
						if !current_user.voted_for?(reply)
							reply.liked_by current_user
							render json: {status: 'SUCCESS', message: 'Vote saved', data: 
								[{"votes": reply.get_upvotes.size}]}, status: :ok
						else
							render json: {status: 'ERROR', message: 'User has already voted this reply', data: nil}, status: :unprocessable_entity
						end
					end
				else 
					render json: {status: 'ERROR', message: 'Error in authenticity', data: nil}, 
							:status => 403
				end
			end

			def unvote
				begin
					user = User.where(:api_key => request.headers['Authorization']).first
					if user
						current_user = user
					end
				rescue Exception => e
					#empty
				end
				if current_user
					reply = Reply.where("id = ?" , params[:id]).first
					if reply.nil?
						render json: {status: 'ERROR', message: 'Reply does not exist', data: nil}, :status => 404
					else
						reply = Reply.find(params[:id])
						if current_user.voted_for?(reply)
							if current_user.id != reply.user.id
								reply.unliked_by current_user
								render json: {status: 'SUCCESS', message: 'Unvote saved', data: 
									[{"votes": reply.get_upvotes.size}]}, status: :ok
							else
								render json: {status: 'ERROR', message: 'User cannot unvote its own reply', data: nil}, status: :unprocessable_entity
							end
						else
							render json: {status: 'ERROR', message: 'User has already unvoted this reply', data: nil}, status: :unprocessable_entity
						end
					end
				else
					render json: {status: 'ERROR', message: 'Error in authenticity', data: nil}, 
								:status => 403
				end
			end

			def update
				begin
					user = User.where(:api_key => request.headers['Authorization']).first
					if user
						current_user = user
					end
				rescue Exception => e
					#empty
				end
				if current_user
					reply = Reply.where("id = ?", params[:id]).first
					puts reply.inspect
					if reply.nil?
						render json: {status: 'ERROR', message: 'Reply does not exist', data: nil}, :status => 404
					else
						if current_user.id == reply.user.id
							reply.update(reply_params)
							if !reply.comment.nil?
								replyResponse = {
									id: reply.id,
									user_id: reply.user.id,
									submission_id: reply.submission.id,
									content: reply.content,
									reply_parent_id: nil,
									comment_id: reply.comment.id,
									created_at: reply.created_at,
									updated_at: reply.updated_at
								}
							else
								replyResponse = {
									id: reply.id,
									user_id: reply.user.id,
									submission_id: reply.submission.id,
									content: reply.content,
									reply_parent_id: reply.parent.id,
									comment_id: nil,
									created_at: reply.created_at,
									updated_at: reply.updated_at
								}
							end
							
							render json: {status: 'SUCCESS', message: 'Reply updated correctly', data: replyResponse}, status: :ok
						else
							render json: {status: 'ERROR', message: 'Can not update someones reply', data: nil}, status: :unprocessable_entity
						end
					end
				else
					render json: {status: 'ERROR', message: 'Error in authenticity', data: nil}, :status => 403
				end
			end

			def submission_comments
				submission = Submission.where("id = ?", params[:id])
				if submission.empty?
					render json: {status: 'ERROR', message: 'Submission does not exist', data: nil}, :status => 404
				else
					comments = Comment.where("submission_id=?", params[:id]).order("created_at DESC")
					render json: {status: 'SUCCESS', message: 'Comments from submission', data: comments}, status: :ok
				end
			end

			def threads
				user = User.where("id = ?", params[:id])
				if user.empty?
					render json: {status: 'ERROR', message: 'User does not exist', data: nil}, :status => 404
				else
        			comments = Comment.where("user_id=?", params[:id]).order("created_at DESC")
					render json: {status: 'SUCCESS', message: 'User comments', data: comments}, status: :ok
				end
      		end

			  def comment
				comment = Comment.where("id = ?", params[:id])
				if comment.empty?
					render json: {status: 'ERROR', message: 'Comment does not exist', data: nil}, :status => 404
				else
					comment = Comment.find(params[:id])
					   render json: {status: 'SUCCESS', message: 'Comment', data: comment}, status: :ok
				end
      		end
      			
			def reply_params
				params.require(:reply).permit(:content, :submission_id, :reply_parent_id)
			end

		end
	end
end