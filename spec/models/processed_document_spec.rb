require 'rails_helper'

RSpec.describe ProcessedDocument, type: :model do
  let(:processed_document) do
    create(:processed_document, produtos: [
      {
        "nome" => "Produto Teste",
        "ncm" => "1234",
        "cfop" => "5102",
        "unidade_comercializada" => 1000,
        "quantidade_comercializada" => 2000,
        "valor_unitario" => 15000
      }
    ].to_json)
  end

  describe "#parsed_produtos" do
    it "returns parsed JSON of produtos" do
      expect(processed_document.parsed_produtos).to be_a(Array)
      expect(processed_document.parsed_produtos.first["nome"]).to eq("Produto Teste")
      expect(processed_document.parsed_produtos.first["ncm"]).to eq("1234")
    end
  end
end
