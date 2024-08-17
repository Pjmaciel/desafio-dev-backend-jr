require 'rails_helper'

RSpec.describe ProcessXmlJob, type: :job do
  let(:document) { create(:document, file: fixture_file_upload('files/sample.xml', 'application/xml')) }

  describe "#perform" do

    context "when the document does not exist" do
      it "logs a warning and does not raise an error" do
        expect(Rails.logger).to receive(:warn).with("Document with ID 999 not found. Skipping job.")
        expect {
          ProcessXmlJob.perform_now(999)  # ID inexistente
        }.not_to raise_error
      end
    end


    it "does not create a ProcessedDocument" do
        expect {
          begin
            ProcessXmlJob.perform_now(document.id)
          rescue StandardError
            # Ignora o erro para continuar o teste
          end
        }.not_to change(ProcessedDocument, :count)
      end
  end
end
