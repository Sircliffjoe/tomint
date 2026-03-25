module Admin
  class BlogPostsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_blog_post, only: %i[ show edit update destroy ]

    def index
      @blog_posts = BlogPost.all.order(created_at: :desc)
    end

    def show
    end

    def new
      @blog_post = BlogPost.new
    end

    def edit
    end

    def create
      @blog_post = BlogPost.new(blog_post_params)
      @blog_post.author = current_user

      if @blog_post.save
        redirect_to admin_blog_posts_path, notice: "Post was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @blog_post.update(blog_post_params)
        redirect_to admin_blog_posts_path, notice: "Post was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @blog_post.destroy
      redirect_to admin_blog_posts_path, notice: "Post was successfully destroyed."
    end

    private

    def set_blog_post
      @blog_post = BlogPost.find(params[:id])
    end

    def blog_post_params
      params.require(:blog_post).permit(:title, :body, :published_at)
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized." unless current_user.super_admin?
    end
  end
end
