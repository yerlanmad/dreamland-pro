require 'rails_helper'

RSpec.describe "Communications", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/communications/create"
      expect(response).to have_http_status(:success)
    end
  end

end
