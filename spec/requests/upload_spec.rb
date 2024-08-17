require 'rails_helper'
require 'devise/test/integration_helpers'

RSpec.describe "Document Uploads", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "POST /documents" do
    it "uploads a valid XML document" do
      post documents_path, params: { document: { title: "Test XML", file: fixture_file_upload('spec/fixtures/files/sample.xml', 'application/xml') } }
      expect(response).to redirect_to(documents_path)
      follow_redirect!
      expect(response.body).to include("Document successfully uploaded and processed.")
    end

    it "does not upload an invalid file type" do
      post documents_path, params: { document: { title: "Invalid file", file: fixture_file_upload('spec/fixtures/files/sample.txt', 'text/plain') } }
      expect(response.body).to include("File deve ser um arquivo XML")
    end
  end
end