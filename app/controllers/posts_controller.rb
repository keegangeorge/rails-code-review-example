class PostsController < ApplicationController
  def index
    @posts = Post.all
    result =
      @posts.map do |post|
        {
          id: post.id,
          title: post.title,
          author: post.user.name,
          comment_count: post.comments.count,
          tag_names: post.tags.map(&:name)
        }
      end
    render json: result
  end

  def show
    @post = Post.find(params[:id])
    render json: @post
  end

  def create
    @post = Post.new(params[:post])
    @post.user_id = params[:user_id]

    if @post.save
      @post.user.followers.each do |follower|
        NotificationMailer.new_post(follower, @post).deliver_now
      end
      render json: @post, status: 201
    else
      render json: @post.errors, status: 422
    end
  end

  def update
    @post = Post.find(params[:id])
    @post.update_attribute(:title, params[:post][:title])
    @post.update_attribute(:body, params[:post][:body])
    render json: @post
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    render json: { message: "Post deleted" }
  end

  def published
    @posts = Post.all.select { |p| p.published == true }
    render json: @posts
  end

  def stats
    posts = Post.all
    render json: {
             total: posts.count,
             published: posts.select(&:published?).count,
             draft: posts.reject(&:published?).count,
             average_comments:
               posts.map { |p| p.comments.count }.sum.to_f / posts.count
           }
  end
end
