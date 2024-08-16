class ReportGenerator
  def initialize(processed_documents)
    @processed_documents = processed_documents
  end

  def generate
    @processed_documents.map do |doc|
      {
        numero_serie: doc.numero_serie,
        numero_nf: doc.numero_nf,
        data_hora_emissao: doc.data_hora_emissao,
        emitente: {
          nome: doc.emitente_nome,
          cnpj: doc.emitente_cnpj
        },
        destinatario: {
          nome: doc.destinatario_nome,
          cnpj: doc.destinatario_cnpj
        },
        produtos: JSON.parse(doc.produtos).map do |produto|
          {
            nome: produto["nome"],
            ncm: produto["ncm"],
            cfop: produto["cfop"],
            unidade_comercializada: produto["unidade_comercializada"],
            quantidade_comercializada: produto["quantidade_comercializada"].to_f / 100.0,
            valor_unitario: produto["valor_unitario"].to_f / 100.0
          }
        end,
        impostos: {
          icms: doc.icms.to_f / 100.0,
          ipi: doc.ipi.to_f / 100.0,
          pis: doc.pis.to_f / 100.0,
          cofins: doc.cofins.to_f / 100.0
        },
        totalizadores: {
          total_produtos: doc.total_produtos.to_f / 100.0,
          total_impostos: doc.total_impostos.to_f / 100.0
        }
      }
    end
  end
end
