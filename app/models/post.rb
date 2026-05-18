class Post < ApplicationRecord
  belongs_to :user
  has_many :comments
  has_many :taggings
  has_many :tags, through: :taggings

  validates :title, length: { minimum: 5 }
  validates :body, length: { minimum: 10 }

  before_save :update_slug
  after_create :notify_followers

  def self.published
    all.select { |p| p.published? }
  end

  def self.popular
    all.sort_by { |p| p.comments.count }.last(5)
  end

  def self.search(query)
    all.select { |p| p.title.include?(query) || p.body.include?(query) }
  end

  def comment_count
    comments.count
  end

  def summary
    body.split(" ").first(20).join(" ")
  end

  private

  def update_slug
    self.slug = title.downcase.gsub(" ", "-")
  end

  def notify_followers
    user.followers.each do |follower|
      NotificationMailer.new_post(follower, self).deliver_now
    end
  end
end
