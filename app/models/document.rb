class Document < ApplicationRecord
  has_one_attached :file
  has_one :processed_document, dependent: :destroy

  before_save :set_title_from_file_name, if: -> { file.present? }

  validate :correct_file_mime_type

  private

  def set_title_from_file_name
    self.title = file.filename.base if file.attached?
  end

  def correct_file_mime_type
    if file.attached? && !file.content_type.in?(%w(application/xml text/xml))
      errors.add(:file, I18n.t('errors.invalid_file_type'))
    elsif file.attached? == false
      errors.add(:file, I18n.t('errors.file_required'))
    end
  end
end
