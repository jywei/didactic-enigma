require 'redcarpet'

class Document
  def self.all
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    markdown.render("This is *bongos*, indeed.")
  end
end
