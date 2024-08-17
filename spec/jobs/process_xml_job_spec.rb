require 'rails_helper'
require 'zip'

RSpec.describe ProcessXmlJob, type: :job do
  describe '#perform' do
    let(:document_id) { 1 }
    let!(:document) { create(:document, id: document_id) }

    before do
      # Tornando o método privado 'process_zip_file' público apenas para este bloco de testes
      ProcessXmlJob.send(:public, :process_zip_file)
    end

    after do
      # Revertendo o método para privado após os testes
      ProcessXmlJob.send(:private, :process_zip_file)
    end

    before do
      allow(Document).to receive(:find_by).and_return(document)
    end

    context 'when document does not exist' do
      let(:document) { nil }

      it 'logs a warning and returns early' do
        expect(Rails.logger).to receive(:warn).with(/Document with ID #{document_id} not found/)
        expect(ProcessXmlJob.new.perform(document_id)).to be_nil
      end
    end

    context 'when document is a ZIP file' do
      let(:zip_content) { File.read(Rails.root.join('spec/fixtures/sample.zip')) }
      let!(:document) { create(:document, id: document_id, file: fixture_file_upload('sample.zip', 'application/zip')) }

      it 'processes each XML file within the ZIP' do
        expect_any_instance_of(ProcessXmlJob).to receive(:process_zip_file).with(document)
        ProcessXmlJob.new.perform(document_id)
      end
    end

    context 'when document is an individual XML file' do
      let(:xml_content) { File.read(Rails.root.join('spec/fixtures/sample.xml')) }
      let!(:document) { create(:document, id: document_id, file: fixture_file_upload('sample.xml', 'application/xml')) }

      it 'processes the single XML file directly' do
        expect_any_instance_of(ProcessXmlJob).to receive(:process_single_xml).with(document, anything(), anything())
        ProcessXmlJob.new.perform(document_id)
      end
    end

    context 'when processing a valid XML file' do
      let(:xml_content) { File.read(Rails.root.join('spec/fixtures/sample.xml')) }
      let!(:document) { create(:document, id: document_id, file: fixture_file_upload('sample.xml', 'application/xml')) }

      it 'processes the single XML file successfully' do
        expect_any_instance_of(ProcessXmlJob).to receive(:process_single_xml).with(document, anything(), anything()).and_call_original
        expect { ProcessXmlJob.new.perform(document_id) }.not_to raise_error
      end
    end

    context 'when processing an invalid XML file' do
      let(:invalid_xml_content) { '<NFe xmlns="http://www.portalfiscal.inf.br/nfe"><infNFe></infNFe></NFe>' } # XML inválido e incompleto
      let(:blob) do
        ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new(invalid_xml_content),
          filename: 'invalid.xml',
          content_type: 'application/xml'
        )
      end
      let!(:document) { create(:document, id: document_id, file: blob) }

      it 'logs an error and does not create a ProcessedDocument' do
        expect(Rails.logger).to receive(:error).with(/Missing essential elements in XML/)
        expect { ProcessXmlJob.new.perform(document_id) }.not_to change(ProcessedDocument, :count)
      end
    end

    context 'when the XML is missing essential elements' do
      let(:xml_content) do
        <<-XML
    <nfeProc xmlns="http://www.portalfiscal.inf.br/nfe">
      <NFe>
        <infNFe>
          <!-- Falta o elemento 'emit' -->
          <dest>
            <CNPJ>99999999999999</CNPJ>
            <xNome>Destinatário Teste</xNome>
          </dest>
          <det>
            <prod>
              <cProd>123</cProd>
              <xProd>Produto Teste</xProd>
            </prod>
          </det>
        </infNFe>
      </NFe>
    </nfeProc>
    XML
      end

      let(:blob) do
        ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new(xml_content),
          filename: 'missing_elements.xml',
          content_type: 'application/xml'
        )
      end

      let!(:document) { create(:document, id: document_id, file: blob) }

      it 'logs an error and does not create a ProcessedDocument' do
        expect(Rails.logger).to receive(:error).with(/Missing essential elements in XML/)
        expect { ProcessXmlJob.new.perform(document_id) }.not_to change(ProcessedDocument, :count)
      end
    end

    context 'when the ZIP contains only PDF files' do
      let(:zip_content) do
        Zip::OutputStream.write_buffer do |zos|
          zos.put_next_entry('document.pdf')
          zos.write '%PDF-1.4'
        end.string
      end
      let(:blob) { ActiveStorage::Blob.create_and_upload!(io: StringIO.new(zip_content), filename: 'pdf_only.zip', content_type: 'application/zip') }
      let!(:document) { create(:document, id: document_id, file: blob) }

      it 'ignores PDF files and does not create any ProcessedDocument' do
        expect { ProcessXmlJob.new.process_zip_file(document) }.not_to change(ProcessedDocument, :count)
      end
    end


  end
end
