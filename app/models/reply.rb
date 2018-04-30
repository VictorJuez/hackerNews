class Reply < ApplicationRecord
    acts_as_votable
    belongs_to :user
    belongs_to :comment

    validates :content, presence: true
end
