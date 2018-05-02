class Comment < ApplicationRecord
  acts_as_votable
  belongs_to :user
  belongs_to :submission
    
  validates :content, presence: true
end  