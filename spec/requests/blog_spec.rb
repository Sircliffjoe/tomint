require 'rails_helper'

RSpec.describe "Blogs", type: :request do
  describe "GET /blog" do
    it "returns http success and renders the blog layout" do
      post = create_blog_post(title: "Training Update")

      get blog_index_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("tom-blog-layout")
      expect(response.body).to include("tom-blog-post-grid")
      expect(response.body).to include(post.title)
    end
  end

  describe "GET /blog/:id" do
    it "returns http success" do
      post = create_blog_post(title: "Camp Testimony")

      get blog_path(post)

      expect(response).to have_http_status(:success)
    end
  end

  def create_blog_post(title:)
    user = User.create!(
      first_name: "Blog",
      last_name: "Author",
      email: "#{title.parameterize}@example.com",
      password: "password"
    )

    BlogPost.create!(
      title: title,
      author: user,
      published_at: 1.day.ago,
      body: "A helpful ministry update for teenagers and workers."
    )
  end

end
