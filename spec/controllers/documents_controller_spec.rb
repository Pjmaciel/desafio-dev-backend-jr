require 'rails_helper'

RSpec.describe DocumentsController, type: :controller do
  let(:user) { create(:user) }
  let(:document) { create(:document) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "assigns all documents to @documents" do
      documents = create_list(:document, 3)
      get :index
      expect(assigns(:documents)).to match_array(documents)
    end
  end

  describe "GET #new" do
    it "assigns a new Document to @document" do
      get :new
      expect(assigns(:document)).to be_a_new(Document)
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new document" do
        expect {
          post :create, params: { document: attributes_for(:document) }
        }.to change(Document, :count).by(1)
      end

      it "calls ProcessXmlJob to process the document" do
        expect(ProcessXmlJob).to receive(:perform_now)
        post :create, params: { document: attributes_for(:document) }
      end

      it "redirects to the documents path with a success notice" do
        post :create, params: { document: attributes_for(:document) }
        expect(response).to redirect_to(documents_path)
        expect(flash[:notice]).to eq('Document successfully uploaded and processed.')
      end
    end

    context "with invalid attributes" do
      it "does not save the document" do
        expect {
          post :create, params: { document: attributes_for(:document, file: nil) }
        }.not_to change(Document, :count)
      end

      it "re-renders the new template" do
        post :create, params: { document: attributes_for(:document, file: nil) }
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET #generate_report" do
    context "when the document has a processed document" do
      let!(:processed_document) { create(:processed_document, document: document) }

      it "redirects to the report path" do
        get :generate_report, params: { id: document.id }
        expect(response).to redirect_to(report_path(processed_document.id))
      end
    end

    context "when the document does not have a processed document" do
      it "sets a flash alert and redirects to the documents path" do
        get :generate_report, params: { id: document.id }
        expect(response).to redirect_to(documents_path)
        expect(flash[:alert]).to eq("Report Not Available")
      end
    end
  end
end
