class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items

  def self.total_revenue
    all.map { |o| o.amount }.sum
  end

  def self.recent
    Order.all.sort_by { |o| o.created_at }.last(10)
  end

  def send_confirmation
    UserMailer.confirmation(self).deliver_now
  end
end
