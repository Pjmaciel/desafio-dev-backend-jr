class CreateProcessedDocuments < ActiveRecord::Migration[7.1]
  def change
    create_table :processed_documents do |t|
      t.references :document, null: false, foreign_key: true
      t.string :numero_serie
      t.string :numero_nf
      t.datetime :data_hora_emissao
      t.string :emitente_nome
      t.string :emitente_cnpj
      t.string :destinatario_nome
      t.string :destinatario_cnpj
      t.text :produtos
      t.text :icms
      t.text :ipi
      t.text :pis
      t.text :cofins
      t.integer :total_produtos
      t.integer :total_impostos

      t.timestamps
    end
  end
end
