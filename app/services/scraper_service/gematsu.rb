class ScraperService
  class Gematsu < ScraperService
    SOURCE = 'Gematsu'.freeze
    base_uri 'www.gematsu.com'

    def to_object
      {
        source: SOURCE,
        category: ScraperCategories::GENERAL,
        articles: latest_news
      }
    end

    private
    def document
      @document ||= Nokogiri::HTML(fetch('/').body)
    end

    def content
      @content ||= document.at_css('#content')
    end

    def latest_news
      content.css('td.details').map { |article| parse_article(article) }
    end

    def parse_article(fragment)
      href = fragment.at_css('div.title > a')['href']
      article_doc = Nokogiri::HTML(fetch(href).body)
      {
        href: href,
        image: article_doc.at_css('meta[property="og:image"]')['content'],
        title: article_doc.at_css('#post .title').content,
        summary: summarize(article_doc.css('#post .entry').text),
        metadata: {
          author: article_doc.at_css('#post .meta a[rel="author"]').content,
          pubdate: DateTime.parse(article_doc.at_css('meta[property="article:published_time"]')['content'])
        }
      }
    end
  end
end
