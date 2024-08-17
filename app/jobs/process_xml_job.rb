require 'zip'
require 'nokogiri'

class ProcessXmlJob < ApplicationJob
  queue_as :default

  def perform(document_id)
    document = Document.find_by(id: document_id)
    unless document
      Rails.logger.warn("Document with ID #{document_id} not found. Skipping job.")
      return
    end

    begin
      if document.file.blob.content_type == 'application/zip'
        # Se for um ZIP, extrair e processar cada XML
        process_zip_file(document)
      else
        # Se for um arquivo XML único, processá-lo diretamente
        xml_data = document.file.download
        process_single_xml(document, xml_data, document.file.filename.to_s)
      end
    rescue StandardError => e
      Rails.logger.error("Error processing document ID #{document.id}: #{e.message}")
      raise e
    end
  end

  private

  def process_zip_file(document)
    zip_data = document.file.download

    Zip::File.open_buffer(zip_data) do |zip_file|
      zip_file.each do |entry|
        next unless entry.file?

        # Ignora arquivos PDF
        next if entry.name.downcase.end_with?('.pdf')

        # Procesa arquivos XML
        if entry.name.downcase.end_with?('.xml')
          xml_data = entry.get_input_stream.read
          process_single_xml(document, xml_data, entry.name)
        else
          # Aqui você pode adicionar lógica para tratar outros tipos de arquivos, se necessário
          Rails.logger.info("Ignored non-XML file: #{entry.name}")
        end
      end
    end
  end

  def process_single_xml(document, xml_data, file_name)
    begin
      parsed_data = Nokogiri::XML(xml_data)
      namespaces = { "nfe" => "http://www.portalfiscal.inf.br/nfe" }

      # Verificações de presença de elementos essenciais
      unless parsed_data.at_xpath('//nfe:ide', namespaces) &&
        parsed_data.at_xpath('//nfe:emit', namespaces) &&
        parsed_data.at_xpath('//nfe:dest', namespaces) &&
        parsed_data.at_xpath('//nfe:det', namespaces)

        Rails.logger.error("Error processing document ID #{document.id}: Missing essential elements in XML.")
        return
      end

      # Procedimento normal de extração de dados
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

      icms = parsed_data.xpath('//nfe:imposto/nfe:ICMS/*/nfe:vICMS', namespaces).map { |node| (node.text.to_f * 100).to_i }.sum
      ipi = parsed_data.xpath('//nfe:imposto/nfe:IPI/*/nfe:vIPI', namespaces).map { |node| (node.text.to_f * 100).to_i }.sum
      pis = parsed_data.xpath('//nfe:imposto/nfe:PIS/*/nfe:vPIS', namespaces).map { |node| (node.text.to_f * 100).to_i }.sum
      cofins = parsed_data.xpath('//nfe:imposto/nfe:COFINS/*/nfe:vCOFINS', namespaces).map { |node| (node.text.to_f * 100).to_i }.sum

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
        icms: icms,
        ipi: ipi,
        pis: pis,
        cofins: cofins,
        total_produtos: total_produtos,
        total_impostos: total_impostos,
        file_name: file_name # Nome do arquivo XML ou do ZIP
      )
    rescue Nokogiri::XML::SyntaxError => e
      Rails.logger.error("Error processing document ID #{document.id}: Invalid XML - #{e.message}")
      return
    end
  end
end
