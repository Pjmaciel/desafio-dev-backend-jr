FactoryBot.define do
  factory :processed_document do
    document
    numero_serie { "123" }
    numero_nf { "456" }
    data_hora_emissao { "2024-08-15T12:34:56" }
    emitente_nome { "Emitente Teste" }
    emitente_cnpj { "12345678000195" }
    destinatario_nome { "Destinatário Teste" }
    destinatario_cnpj { "98765432000154" }
    produtos { [{ nome: 'Produto A', ncm: '1234', cfop: '5678' }, { nome: 'Produto B', ncm: '2345', cfop: '6789' }].to_json }
    icms { 100 }
    ipi { 50 }
    pis { 20 }
    cofins { 30 }
    total_produtos { 1000 }
    total_impostos { 200 }
  end
end
