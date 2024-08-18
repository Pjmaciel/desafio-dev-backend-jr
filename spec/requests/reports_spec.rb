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

    it "displays the 'Exportar para Excel' button" do
      get report_path(processed_document)

      # Verifica se o botão "Exportar para Excel" está presente na página
      expect(response.body).to include("Exportar para Excel")
    end

    it "exports the report to Excel when the button is clicked" do
      # Simula o clique no botão para exportar o relatório
      get export_to_excel_report_path(processed_document, format: :xlsx)

      # Verifica se a resposta é bem-sucedida (código de status 200) e o tipo de conteúdo esperado
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    end
  end
end
