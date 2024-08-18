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
      ProcessXmlJob.perform_now(@document.id)
      redirect_to documents_path, notice: 'Document successfully uploaded and processed.'
    else
      render :new
    end
  end

  def generate_report
    document = Document.find(params[:id])
    processed_document = document.processed_documents.last

    if processed_document.present?
      redirect_to report_path(processed_document.id)
    else
      flash[:alert] = "Report Not Available"
      redirect_to documents_path
    end
  end



  private

  def document_params
    params.require(:document).permit(:file)
  end
end
