class ProcessedDocument < ApplicationRecord
  belongs_to :document

  def parsed_produtos
    JSON.parse(produtos)
  end

end
