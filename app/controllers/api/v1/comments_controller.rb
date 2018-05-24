module Api
	module V1
		class CommentsController < ApplicationController
			skip_before_action :verify_authenticity_token

			def create
				begin
					user = User.where(:api_key => request.headers['Authorization']).first
					if user
						current_user = user
					end
				rescue Exception => e
					#empty
				end
				comment = Comment.new(comment_params)
				if current_user
					submission = Submission.where("id = ?" , params[:id])
					if submission.empty?
						render json: {status: 'ERROR', message: 'Submission does not exist', data: nil}, :status => 404
					else
						if !comment_params[:content].blank?
							comment.user = current_user
							submission = Submission.find(params[:id])
							comment.submission = submission
							if comment.save
								comment.vote_by :voter => current_user
								render json: {status: 'SUCCESS', message: 'Comment created correctly', data: comment}, status: :ok
							else
								render json: {status: 'ERROR', message: 'Error in data base', data: nil}, status: :unprocessable_entity
							end
						else
							render json: {status: 'ERROR', message: 'Comment can not be blank', data: nil}, status: :unprocessable_entity
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
					comment = Comment.where("id = ?" , params[:id])
					if comment.empty?
						render json: {status: 'ERROR', message: 'Comment does not exist', data: nil}, :status => 404
					else
						comment = Comment.find(params[:id])
						if !current_user.voted_for?(comment)
							comment.liked_by current_user
							render json: {status: 'SUCCESS', message: 'Vote saved', data:
								[{"votes": comment.get_upvotes.size}]}, status: :ok
						else
							render json: {status: 'ERROR', message: 'User has already voted this comment', data: nil}, status: :unprocessable_entity
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
					comment = Comment.where("id = ?" , params[:id])
					if comment.empty?
						render json: {status: 'ERROR', message: 'Comment does not exist', data: nil}, :status => 404
					else
						comment = Comment.find(params[:id])
						if current_user.voted_for?(comment)
							if current_user.id != comment.user.id
								comment.unliked_by current_user
								render json: {status: 'SUCCESS', message: 'Unvote saved', data:
									[{"votes": comment.get_upvotes.size}]}, status: :ok
							else
								render json: {status: 'ERROR', message: 'User cannot unvote its own comment', data: nil}, status: :unprocessable_entity
							end
						else
							render json: {status: 'ERROR', message: 'User has already unvoted this comment', data: nil}, status: :unprocessable_entity
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
					comment = Comment.where("id = ?", params[:id])
					if comment.empty?
						render json: {status: 'ERROR', message: 'Comment does not exist', data: nil}, :status => 404
					else
						comment = Comment.find(params[:id])
						if current_user.id == comment.user.id
							comment.update(comment_params)
							commentResponse = {
								id: comment.id,
								user_id: comment.user.id,
								submission_id: comment.submission.id,
								content: comment.content,
								created_at: comment.created_at,
								updated_at: comment.updated_at
							}
							render json: {status: 'SUCCESS', message: 'Comment updated correctly', data: commentResponse}, status: :ok
						else
							render json: {status: 'ERROR', message: 'Can not update someones comment', data: nil}, status: :unprocessable_entity
						end
					end
				else
					render json: {status: 'ERROR', message: 'Error in authenticity', data: nil}, :status => 403
				end
			end

			def submission_commentsjson(comments)
				response = []
				comments.each do |comment|
					comResponse = {
						id: comment.id,
						content: comment.content,
						user_id: comment.user_id,
						submission_id: comment.submission_id,
						created_at: comment.created_at,
						updated_at: comment.updated_at,
						user_name: comment.user.name,
						votes: comment.cached_votes_total
					}
					response.push(comResponse)
				end
				return response
			end

			def submission_comments
				submission = Submission.where("id = ?", params[:id])
				if submission.empty?
					render json: {status: 'ERROR', message: 'Submission does not exist', data: nil}, :status => 404
				else
					comments = Comment.where("submission_id=?", params[:id]).order("created_at DESC")
					response = submission_commentsjson(comments)
					render json: {status: 'SUCCESS', message: 'Comments from submission', data: response}, status: :ok
				end
			end

			def submission_comments_replies_json(comments)
				response = []

				commentJson = {
					id: 0,
					content: "",
					user_id: 0,
					submission_id: 0,
					created_at: 0,
					updated_at: 0,
					user_name: "",
					votes: 0,
					replies: []
				}

				comments.each do |comment|
					repliesJson1 = {
						id: 0,
						content: "",
						user_id: 0,
						user_name: "",
						comment_id: 0,
						created_at: 0,
						updated_at: 0,
						reply_parent_id: 0,
						submission_id: 0,
						cached_votes_total: 0,
						replies: []
					}

					repliesJson2 = {
						id: 0,
						content: "",
						user_id: 0,
						user_name: "",
						comment_id: 0,
						created_at: 0,
						updated_at: 0,
						reply_parent_id: 0,
						submission_id: 0,
						cached_votes_total: 0,
						replies: []
					}

					repliesJson3 = {
						id: 0,
						content: "",
						user_id: 0,
						user_name: "",
						comment_id: 0,
						created_at: 0,
						updated_at: 0,
						reply_parent_id: 0,
						submission_id: 0,
						cached_votes_total: 0,
						replies: []
					}

					repliesJson4 = {
						id: 0,
						content: "",
						user_id: 0,
						user_name: "",
						comment_id: 0,
						created_at: 0,
						updated_at: 0,
						reply_parent_id: 0,
						submission_id: 0,
						cached_votes_total: 0,
						replies: []
					}


					repliesResponse1 = []
					repliesResponse2 = []
					repliesResponse3 = []
					repliesResponse4 = []
					replies1 = Reply.where("comment_id = ?", comment.id).order("created_at DESC")
					replies1.each do |reply|
						user1 = User.find(reply.user_id)
						repliesJson1['id'] = reply.id
						repliesJson1['content'] = reply.content
						repliesJson1['user_id'] = reply.user_id
						repliesJson1['comment_id'] = reply.comment_id
						repliesJson1['created_at'] = reply.created_at
						repliesJson1['updated_at'] = reply.updated_at
						repliesJson1['reply_parent_id'] = reply.reply_parent_id
						repliesJson1['submission_id'] = reply.submission_id
						repliesJson1['cached_votes_total'] = reply.cached_votes_total
						repliesJson1['user_name'] = user1.name

						replies2 = Reply.where("reply_parent_id = ?", reply.id).order("created_at DESC")
						replies2.each do |reply2|
							user2 = User.find(reply2.user_id)
							repliesJson2['id'] = reply2.id
							repliesJson2['content'] = reply2.content
							repliesJson2['user_id'] = reply2.user_id
							repliesJson2['comment_id'] = reply2.comment_id
							repliesJson2['created_at'] = reply2.created_at
							repliesJson2['updated_at'] = reply2.updated_at
							repliesJson2['reply_parent_id'] = reply2.reply_parent_id
							repliesJson2['submission_id'] = reply2.submission_id
							repliesJson2['cached_votes_total'] = reply2.cached_votes_total
							repliesJson1['user_name'] = user2.name

							replies3 = Reply.where("reply_parent_id = ?", reply2.id).order("created_at DESC")

							replies3.each do |reply3|
								user3 = User.find(reply3.user_id)
								repliesJson3['id'] = reply3.id
								repliesJson3['content'] = reply3.content
								repliesJson3['user_id'] = reply3.user_id
								repliesJson3['comment_id'] = reply3.comment_id
								repliesJson3['created_at'] = reply3.created_at
								repliesJson3['updated_at'] = reply3.updated_at
								repliesJson3['reply_parent_id'] = reply3.reply_parent_id
								repliesJson3['submission_id'] = reply3.submission_id
								repliesJson3['cached_votes_total'] = reply3.cached_votes_total
								repliesJson1['user_name'] = user3.name

								replies4 = Reply.where("reply_parent_id = ?", reply3.id).order("created_at DESC")

								replies4.each do |reply4|
									user4 = User.find(reply4.user_id)
									repliesJson4['id'] = reply4.id
									repliesJson4['content'] = reply4.content
									repliesJson4['user_id'] = reply4.user_id
									repliesJson4['comment_id'] = reply4.comment_id
									repliesJson4['created_at'] = reply4.created_at
									repliesJson4['updated_at'] = reply4.updated_at
									repliesJson4['reply_parent_id'] = reply4.reply_parent_id
									repliesJson4['submission_id'] = reply4.submission_id
									repliesJson4['cached_votes_total'] = reply4.cached_votes_total
									repliesJson1['user_name'] = user4.name

									repliesResponse4.push(repliesJson4.dup)

								end
								repliesJson3['replies'] = repliesResponse4.dup
								repliesResponse3.push(repliesJson3.dup)
								repliesResponse4.clear()

							end
							repliesJson2['replies'] = repliesResponse3.dup
							repliesResponse2.push(repliesJson2.dup)
							repliesResponse3.clear()
						end
						repliesJson1['replies'] = repliesResponse2.dup
						repliesResponse1.push(repliesJson1.dup)
						repliesResponse2.clear()

					end

					commentJson['id'] = comment.id
					commentJson['content'] = comment.content
					commentJson['user_id'] = comment.user_id
					commentJson['submission_id'] = comment.submission_id
					commentJson['created_at'] = comment.created_at
					commentJson['updated_at'] = comment.updated_at
					commentJson['user_name'] = comment.user.name
					commentJson['cached_votes_total'] = comment.cached_votes_total
					commentJson['replies'] = repliesResponse1.dup
					response.push(commentJson.dup)
					repliesResponse1.clear()

				end
				return response
			end

			def submission_comments_replies
				submission = Submission.where("id = ?", params[:id])
				if submission.empty?
					render json: {status: 'ERROR', message: 'Submission does not exist', data: nil}, :status => 404
				else
					comments = Comment.where("submission_id=?", params[:id]).order("created_at DESC")
					response = submission_comments_replies_json(comments)
					render json: {status: 'SUCCESS', message: 'Comments and replies from submission', data: response}, status: :ok
				end
			end

			def threadsjson(comments, replies)
				response = []
				comments.each do |comment|
					submission = Submission.find(comment.submission.id)
					comResponse = {
						id: comment.id,
						content: comment.content,
						user_id: comment.user_id,
						submission_id: comment.submission_id,
						created_at: comment.created_at,
						updated_at: comment.updated_at,
						user_name: comment.user.name,
						votes: comment.cached_votes_total,
						submission_title: submission.title
					}
					response.push(comResponse)
				end
				response2 = []
				replies.each do |reply|
					submission = Submission.find(reply.submission.id)
					threadsResponse = {
						id: reply.id,
						content: reply.content,
						user_id: reply.user_id,
						submission_id: reply.submission_id,
						created_at: reply.created_at,
						updated_at: reply.updated_at,
						user_name: reply.user.name,
						votes: reply.cached_votes_total,
						submission_title: submission.title
					}
					response2.push(threadsResponse)
				end
				return response + response2
			end

			def threads
				user = User.where("id = ?", params[:id])
				if user.empty?
					render json: {status: 'ERROR', message: 'User does not exist', data: nil}, :status => 404
				else
					comments = Comment.where("user_id=?", params[:id]).order("created_at DESC")
					replies = Reply.where("user_id=?", params[:id]).order("created_at DESC")
					response = threadsjson(comments, replies)
					render json: {status: 'SUCCESS', message: 'User comments', data: response}, status: :ok
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

      		def destroy
      			current_user = nil
				begin
					user = User.where(:api_key => request.headers['Authorization']).first
					if user
						current_user = user
					end
				rescue Exception => e
					#empty
				end
				if current_user
					if Comment.where(id: params[:id]).present?
						comment = Comment.find(params[:id])
						if comment.user_id == current_user.id
							comment.reply.each do |child_reply|
								delete_replies(child_reply)
							end

							if comment.destroy
						        render json: {status: 'SUCCESS', message: 'Comment deleted', data: nil},
									status: :ok
					    	else
					    		render json: {status: 'ERROR', message: 'Comment not deleted', data: nil},
									:status => 500
					    	end
					    else
					    	render json: {status: 'ERROR', message: 'Cannot delete others comments', data: nil},
							:status => 403
					    end
				    else
				    	render json: {status: 'ERROR', message: 'Comment does not exists', data: nil},
								status: :unprocessable_entity
				    end
				else
			    	render json: {status: 'ERROR', message: 'Error in authenticity', data: nil},
							:status => 403
		    	end
			end

			def delete_replies(reply)
				if(reply.child_replies.size == 0)
					reply.destroy
					return
				end
				reply.child_replies.each do |child_reply|
					delete_replies(child_reply)
				end
				reply.destroy
			end

			def comment_params
				params.require(:comment).permit(:content, :submission_id)
			end

		end
	end
end
