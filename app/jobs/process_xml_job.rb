class ProcessXmlJob < ApplicationJob
  queue_as :default

  def perform(document_id)
    document = Document.find(document_id)
    xml_data = document.file.download
    parsed_data = Nokogiri::XML(xml_data)

    namespaces = { "nfe" => "http://www.portalfiscal.inf.br/nfe" }

    numero_serie = parsed_data.xpath('//nfe:ide/nfe:serie', namespaces).text
    numero_nf = parsed_data.xpath('//nfe:ide/nfe:nNF', namespaces).text
    data_hora_emissao = parsed_data.xpath('//nfe:ide/nfe:dhEmi', namespaces).text
    emitente_nome = parsed_data.xpath('//nfe:emit/nfe:xNome', namespaces).text
    emitente_cnpj = parsed_data.xpath('//nfe:emit/nfe:CNPJ', namespaces).text
    destinatario_nome = parsed_data.xpath('//nfe:dest/nfe:xNome', namespaces).text
    destinatario_cnpj = parsed_data.xpath('//nfe:dest/nfe:CNPJ', namespaces).text

    produtos = parsed_data.xpath('//nfe:det', namespaces).map do |det|
      {
        nome: det.xpath('nfe:prod/nfe:xProd', namespaces).text,
        ncm: det.xpath('nfe:prod/nfe:NCM', namespaces).text,
        cfop: det.xpath('nfe:prod/nfe:CFOP', namespaces).text,
        unidade_comercializada: det.xpath('nfe:prod/nfe:uCom', namespaces).text,
        quantidade_comercializada: det.xpath('nfe:prod/nfe:qCom', namespaces).text.to_f * 100,
        valor_unitario: (det.xpath('nfe:prod/nfe:vUnCom', namespaces).text.to_f * 100).to_i
      }
    end

    icms = parsed_data.xpath('//nfe:imposto/nfe:ICMS/*/nfe:vICMS', namespaces).map { |node| (node.text.to_f * 100).to_i }
    ipi = parsed_data.xpath('//nfe:imposto/nfe:IPI/*/nfe:vIPI', namespaces).map { |node| (node.text.to_f * 100).to_i }
    pis = parsed_data.xpath('//nfe:imposto/nfe:PIS/*/nfe:vPIS', namespaces).map { |node| (node.text.to_f * 100).to_i }
    cofins = parsed_data.xpath('//nfe:imposto/nfe:COFINS/*/nfe:vCOFINS', namespaces).map { |node| (node.text.to_f * 100).to_i }

    # Totalizadores
    total_produtos = (parsed_data.xpath('//nfe:total/nfe:ICMSTot/nfe:vProd', namespaces).text.to_f * 100).to_i
    total_impostos = (parsed_data.xpath('//nfe:total/nfe:ICMSTot/nfe:vTotTrib', namespaces).text.to_f * 100).to_i

    ProcessedDocument.create!(
      document_id: document.id,
      numero_serie: numero_serie,
      numero_nf: numero_nf,
      data_hora_emissao: data_hora_emissao,
      emitente_nome: emitente_nome,
      emitente_cnpj: emitente_cnpj,
      destinatario_nome: destinatario_nome,
      destinatario_cnpj: destinatario_cnpj,
      produtos: produtos.to_json,
      icms: icms.sum,
      ipi: ipi.sum,
      pis: pis.sum,
      cofins: cofins.sum,
      total_produtos: total_produtos,
      total_impostos: total_impostos
    )
  end
end
