class AddFileNameToProcessedDocuments < ActiveRecord::Migration[7.1]
  def change
    add_column :processed_documents, :file_name, :string
  end
end
