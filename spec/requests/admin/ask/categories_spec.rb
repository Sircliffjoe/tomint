# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Ask::CategoriesController", type: :request do
  let!(:admin) do
    User.create!(
      first_name: "Admin", last_name: "User", email: "admin_cat_test@tomint.org",
      password: "password123", role: :super_admin
    )
  end
  let!(:category) { AskCategory.create!(name: "Faith & God", slug: "faith-god", color: "emerald", position: 1, active: true) }

  before do
    sign_in admin
  end

  describe "GET /admin/ask/categories" do
    it "renders the categories index" do
      get admin_ask_categories_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Faith &amp; God")
    end
  end

  describe "GET /admin/ask/categories/new" do
    it "renders the new category form" do
      get new_admin_ask_category_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Category Name")
    end
  end

  describe "POST /admin/ask/categories" do
    it "creates a new category" do
      expect {
        post admin_ask_categories_path, params: {
          ask_category: { name: "Identity & Purpose", color: "purple", active: true }
        }
      }.to change(AskCategory, :count).by(1)

      expect(response).to redirect_to(admin_ask_categories_path)
    end
  end

  describe "GET /admin/ask/categories/:id/edit" do
    it "renders the edit category form" do
      get edit_admin_ask_category_path(category)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Faith &amp; God")
    end
  end

  describe "PATCH /admin/ask/categories/:id" do
    it "updates category attributes" do
      patch admin_ask_category_path(category), params: {
        ask_category: { name: "Faith, Bible & God" }
      }
      expect(response).to redirect_to(admin_ask_categories_path)
      expect(category.reload.name).to eq("Faith, Bible & God")
    end
  end
end
