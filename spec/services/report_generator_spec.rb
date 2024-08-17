require 'rails_helper'

RSpec.describe ReportGenerator, type: :service do
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

  let(:processed_document2) do
    create(:processed_document, produtos: [
      {
        "nome" => "Produto Teste 2",
        "ncm" => "5678",
        "cfop" => "6102",
        "unidade_comercializada" => 3000,
        "quantidade_comercializada" => 4000,
        "valor_unitario" => 25000
      }
    ].to_json)
  end

  it "generates a report with the correct product details" do
    generator = ReportGenerator.new([processed_document])
    report = generator.generate

    expect(report.first[:produtos].first[:nome]).to eq("Produto Teste")
    expect(report.first[:produtos].first[:ncm]).to eq("1234")
    expect(report.first[:produtos].first[:cfop]).to eq("5102")
    expect(report.first[:produtos].first[:quantidade_comercializada]).to eq(20.0)
    expect(report.first[:produtos].first[:valor_unitario]).to eq(150.0)
  end

  it "generates a report with multiple processed documents" do
    generator = ReportGenerator.new([processed_document, processed_document2])
    report = generator.generate

    expect(report.size).to eq(2)
    expect(report[0][:produtos].first[:nome]).to eq("Produto Teste")
    expect(report[1][:produtos].first[:nome]).to eq("Produto Teste 2")
  end
end
