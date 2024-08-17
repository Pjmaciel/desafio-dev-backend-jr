FactoryBot.define do
  factory :document do
    title { "Test Document" }

    file { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/sample.xml'), 'application/xml') }
  end
end
