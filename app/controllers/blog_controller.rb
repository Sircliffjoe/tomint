class BlogController < ApplicationController
  layout "public"
  def index
    @posts = BlogPost.published.order(published_at: :desc)
  end

  def show
    @post = BlogPost.published.friendly_find(params[:id])
  end
end
