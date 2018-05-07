class Reply < ApplicationRecord
    acts_as_votable
    belongs_to :user
    belongs_to :comment
    belongs_to :parent, :class_name => "Reply", :foreign_key => "parent_reply_id"

    has_many :child_replies, :class_name => "Reply", :foreign_key => "child_reply_id"

    validates :content, presence: true
end
