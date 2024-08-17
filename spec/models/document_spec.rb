require 'rails_helper'

RSpec.describe Document, type: :model do
  describe 'callbacks' do
    context 'before_save' do
      let(:document) { build(:document, title: nil) }  # Ensure title is not set by default

      it 'sets the title from the file name if file is attached' do
        document.file.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'sample.xml')), filename: 'sample.xml', content_type: 'application/xml')
        document.save!
        expect(document.title).to eq('sample')
      end

      it 'does not set the title if no file is attached' do
        document.file = nil
        document.save
        expect(document.title).to be_nil
      end
    end
  end

  describe 'validations' do
    let(:document) { build(:document) }

    it 'is valid with a valid XML file' do
      document.file.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'sample.xml')), filename: 'sample.xml', content_type: 'application/xml')
      expect(document).to be_valid
    end

    it 'is invalid with an unsupported file type' do
      document.file.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'sample.txt')), filename: 'sample.txt', content_type: 'text/plain')
      expect(document).not_to be_valid
      expect(document.errors[:file]).to include(I18n.t('errors.invalid_file_type'))
    end

    it 'is invalid without an attached file' do
      document.file = nil
      expect(document).not_to be_valid
      expect(document.errors[:file]).to include(I18n.t('errors.file_required'))
    end
  end
end
