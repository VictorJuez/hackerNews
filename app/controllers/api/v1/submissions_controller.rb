module Api
	module V1
		class SubmissionsController < ApplicationController
			skip_before_action :verify_authenticity_token
			
			def index
				submissions = Submission.all.where.not(url:"").order("created_at DESC")
				render json: {status: 'SUCCESS', message: 'URL submissions', data: submissions}, status: :ok				
			end

			def newest
			    submissions = Submission.all.order("created_at DESC")
			    render json: {status: 'SUCCESS', message: 'All submissions', data: submissions}, status: :ok
			end

			def ask
				submissions = Submission.all.where(url:"").order("created_at DESC")
				render json: {status: 'SUCCESS', message: 'ASK submissions', data: submissions}, status: :ok
			end

			def show
				submission = Submission.find(params[:id])
				render json: {status: 'SUCCESS', message: 'Submission', data: submission}, status: :ok
			end

			def xor(a, b)
			   	(a and (not b)) or ((not a) and b)
			end

			def new
				@submission = Submission.new
			end

			def create
				current_user = nil
				begin
					user = User.where(:uid => request.headers['Authorization']).first
					if user
						print("ENTRAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
						current_user = user
					end
				rescue Exception => e
					#empty
				end
				submission = Submission.new(submission_params)
				if current_user
				    if xor(submission_params[:url].blank?, submission_params[:text].blank?) && !submission_params[:title].blank?
				      	parameters = submission_params
				      	if !submission_params[:url].starts_with?('http') && submission_params[:text].blank?
				        	parameters[:url] = 'http://' + submission_params[:url]
				      	end
						submission = Submission.new(parameters)	
						submission.user = current_user
				        subuser = submission.user
				        subuser.karma = subuser.karma + 1
						if submission.save && subuser.save
							submission.vote_by :voter => current_user
							render json: {status: 'SUCCESS', message: 'Submission saved', data: submission}, status: :ok
						else
							render json: {status: 'ERROR', message: 'Submission not saved', data: submission.errors}, 
							status: :unprocessable_entity
						end	
					else
						render json: {status: 'ERROR', message: 'Error in parameters', data: submission.errors}, 
							status: :unprocessable_entity
					end
				else
					render json: {status: 'ERROR', message: 'Error in authenticity', data: submission.errors}, 
							status: :unprocessable_entity
				end
			end

			private

			def submission_params
				params.require(:submission).permit(:title, :url, :text, :user_id)
			end
		end
	end
end