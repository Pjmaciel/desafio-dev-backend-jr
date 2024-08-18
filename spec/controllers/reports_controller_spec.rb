require 'rails_helper'

RSpec.describe ReportsController, type: :controller do
  let(:user) { create(:user) }
  let(:document) { create(:document) }
  let!(:processed_document) { create(:processed_document, document: document) }

  before do
    sign_in user
    allow(controller).to receive(:render).and_return(nil)
  end

  describe "GET #show" do
    it "assigns the requested processed document to @processed_document" do
      get :show, params: { id: processed_document.id }
      expect(assigns(:processed_document)).to eq(processed_document)
    end

    it "generates a report and assigns it to @report_data" do
      get :show, params: { id: processed_document.id }
      expect(assigns(:report_data)).not_to be_nil
    end

    it "assigns all products to @all_products" do
      get :show, params: { id: processed_document.id }

      expected_products = assigns(:report_data)[:produtos]

      assigns(:all_products).each_with_index do |product, index|
        expect(product).to include(
                             nome: expected_products[index][:nome],
                             ncm: expected_products[index][:ncm],
                             cfop: expected_products[index][:cfop]
                           )
      end
    end



    context "when query is present" do
      it "assigns the filtered results to @filtered_results" do
        get :show, params: { id: processed_document.id, query: 'Produto A' }
        filtered_products = assigns(:filtered_results).first[:produtos]
        expect(filtered_products.map { |p| p.transform_keys(&:to_sym) }).to include(hash_including(nome: 'Produto A'))
      end
    end

    context "when filters are applied" do
      it "assigns the filtered products to @filtered_products" do
        get :show, params: { id: processed_document.id, nome: 'Produto A' }
        filtered_products = assigns(:filtered_products).map { |p| p.transform_keys(&:to_sym) }
        expect(filtered_products).to include(hash_including(nome: 'Produto A'))
      end
    end
  end
end
