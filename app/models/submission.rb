class Submission < ApplicationRecord
	belongs_to :user
	validates_presence_of :user_id, :message => "you have to log in to create a submission" 
  	validates :title, presence: true
end
