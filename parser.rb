require 'nokogiri'
require 'open-uri'
require 'iconv'
require 'sanitize'
require 'json'

require_relative 'book.rb'


BASE_DIR = "webpages"
Dir.chdir(BASE_DIR)

files = Dir.glob("*")
ic = Iconv.new("utf-8//translit//IGNORE","big5")

books = []

files.each do |file|
  f = File.open(file)
  doc = Nokogiri::HTML(ic.iconv(f.read))

  values = doc.css('td[width="59%"] tr').map {|row|
    row.css('td').last.text.strip
  }

  # oc.css('table[width="100%"][cellpadding="4"][cellspacing="4"] > tr').first.css('td').last
  long_contents = 
    doc.css('table[width="100%"][cellpadding="4"][cellspacing="4"] > tr').map {|row|
      Sanitize.clean(row.css('td').last.to_html, Sanitize::Config::RELAXED)
    }
  long_contents.pop

  image_url = doc.css('td[width="41%"] img').first['src']

  price = values[4]

  books << Book.new({
    "isbn_13" => values[0],
    "isbn_10" => values[1],
    "name" => values[2],
    "author" => values[3],
    "price" => price[3..price.length],
    "publisher" => values[5],
    "revision" => values[6],
    "year" => values[7],
    "content" => long_contents[0],
    "cover_img" => image_url,
    "url" => "http://www.tunghua.com.tw/books_detail.php?oid=#{file[0..file.length-6]}",
    "author_intro" => long_contents[1]
  }).to_hash

end


Dir.chdir("..")

File.open('book.json', 'w') do |f|
  f.write(JSON.pretty_generate(books))
end



# doc.css('td[width="59%"] tr').first.css('td').last.text.empty?

