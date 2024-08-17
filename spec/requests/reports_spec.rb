require 'rails_helper'

RSpec.describe "Reports", type: :request do
  let(:user) { create(:user) }
  let(:document) { create(:document) }
  let!(:processed_document) { create(:processed_document, document: document) }

  before do
    sign_in user
  end

  describe "GET /reports/:id" do
    it "renders the report page" do
      get report_path(processed_document)
      expect(response).to be_successful

      expect(response.body).to include("Número da Série")
      expect(response.body).to include("Nome do Emitente")
      expect(response.body).to include("CNPJ do Emitente")
      expect(response.body).to include("Total de Produtos")
    end
  end
end
