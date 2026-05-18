class OrdersController < ApplicationController
  def index
    @orders = Order.all
    render json: @orders
  end

  def create
    @order = Order.new(params[:order])
    if @order.save
      render json: @order, status: 201
    else
      render json: @order.errors, status: 400
    end
  end

  def update
    @order = Order.find(params[:id])
    @order.update(params[:order])
    render json: @order
  end

  def destroy
    @order = Order.find(params[:id])
    @order.delete
    render json: { message: "deleted" }
  end

  def user_orders
    user = User.find_by(email: params[:email])
    @orders = Order.where("user_id = #{user.id}")
    render json: @orders
  end

  def search
    @orders = Order.all.select { |o| o.status == params[:status] }
    render json: @orders
  end
end
