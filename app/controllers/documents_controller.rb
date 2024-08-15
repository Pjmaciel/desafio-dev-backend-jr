class DocumentsController < ApplicationController
  def index
    @documents = Document.all
  end

  def new
    @document = Document.new
  end

  def create
    @document = Document.new(document_params)
    if @document.save
      redirect_to documents_path, notice: I18n.t('notices.document_uploaded')
    else
      render :new
    end
  end

  private

  def document_params
    params.require(:document).permit(:title, :file)
  end
end
