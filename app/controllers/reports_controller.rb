class ReportsController < ApplicationController
  def show
    @processed_document = ProcessedDocument.find(params[:id])
    @report_data = ReportGenerator.new([@processed_document]).generate.first
  end
end
