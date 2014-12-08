require 'nokogiri'
require 'open-uri'
require 'iconv'


BASE_DIR = "webpages"
ic = Iconv.new("utf-8//translit//IGNORE","big5")
# 13712
(0..15000).each do |i|
  filename = "#{BASE_DIR}/#{i}.html"
  if File.exist?(filename)  && File.size(filename) > 50000
    next
  end    

  k = open("http://www.tunghua.com.tw/books_detail.php?oid=#{i}")
  print "i = #{i}, "
  doc = Nokogiri::HTML(ic.iconv(k.read))

  book_name = doc.css('td[width="59%"] tr').first.css('td').last.text
  if book_name.empty? || book_name.nil?
    next
  else
    if File.exist?(filename)  && File.size(filename) > 50000
      next
    end    
    File.open(filename, 'w') do |f|
      k.rewind
      f.write(k.read)
    end
  end

end