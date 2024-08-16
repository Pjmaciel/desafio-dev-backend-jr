class ReportsController < ApplicationController
  include ReportsHelper
  def show
    @processed_document = ProcessedDocument.find(params[:id])
    @report_data = ReportGenerator.new([@processed_document]).generate.first

    @filtered_products = filter_products(@report_data[:produtos])
  end

  private

  def filter_products(products)
    products.select do |product|
      matches_general_search?(product) &&
        (params[:nome].blank? || product[:nome].include?(params[:nome])) &&
        (params[:ncm].blank? || product[:ncm] == params[:ncm]) &&
        (params[:cfop].blank? || product[:cfop] == params[:cfop])
    end
  end

  def matches_general_search?(product)
    return true if params[:query].blank?

    searchable_fields = [
      product[:nome].downcase,
      product[:ncm],
      product[:cfop],
      product[:unidade_comercializada].downcase
    ]

    searchable_fields.any? { |field| field.include?(params[:query].downcase) }
  end
end
