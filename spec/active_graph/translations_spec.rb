RSpec.describe ActiveGraph::Translations do
  class Article
    include ActiveGraph::Node
    include ActiveGraph::Translations

    translates :name, :description
  end

  it "has a version number" do
    expect(ActiveGraph::Translations::VERSION).not_to be nil
  end

  %w[
    name
    description
  ].each do |field|
    it "is possible to set and load #{field}" do
      article = Article.new

      I18n.locale = :en
      article.name = "Article name"

      I18n.locale = :da
      expect(article.name).not_to eql "Article name"
      article.name = "Ny artikel"

      I18n.locale = :en
      expect(article.name).to eql "Article name"
    end
  end
end
