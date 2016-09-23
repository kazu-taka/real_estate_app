class Comment < ActiveRecord::Base
  belongs_to :house

  validates :body,     presence: true
  validates :house_id, presence: true
end
