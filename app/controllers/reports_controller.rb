class ReportsController < ApplicationController
  def show
    @processed_document = ProcessedDocument.find(params[:id])
    @report_data = ReportGenerator.new([@processed_document]).generate.first

    @all_products = JSON.parse(@processed_document.produtos, symbolize_names: true)



    if params[:query].present?
      @filtered_results = search_in_document(@report_data, params[:query])
    end


    if params[:query].blank? && (params[:nome].present? || params[:ncm].present? || params[:cfop].present?)
      @filtered_products = filter_products(@all_products)
    end
  end

  def export_to_excel
    @processed_document = ProcessedDocument.find(params[:id])

    # Converte o JSON armazenado no campo 'produtos' para um array de hashes
    @products = JSON.parse(@processed_document.produtos)

    respond_to do |format|
      format.xlsx
    end
  end

  private

  def search_in_document(hash, query)
    query_downcased = query.downcase
    found = []

    hash.each do |key, value|
      if value.is_a?(Hash)
        found += search_in_document(value, query)
      else
        key_normalized = key.to_s.downcase.strip
        value_normalized = value.to_s.downcase.strip

        if key_normalized.include?(query_downcased) || value_normalized.include?(query_downcased)
          found << { key => value }
        end
      end
    end

    found
  end

  def filter_products(products)
    products.select do |product|
      (params[:nome].blank? || product[:nome]&.include?(params[:nome])) &&
        (params[:ncm].blank? || product[:ncm] == params[:ncm]) &&
        (params[:cfop].blank? || product[:cfop] == params[:cfop])
    end
  end
end
