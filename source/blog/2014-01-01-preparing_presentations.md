---
title: Preparing presentations
date: 2014-01-01
tags: ruby, parade, presentation
---

# Preparing presentations



```ruby
group :presentation do
  gem "rmagick"
  gem "pdf-inspector"
  gem "pdfkit"
  gem "wkhtmltopdf-binary", '0.9.5.3'
  # http://hocuspokus.net/2010/03/installing-rmagick-on-snow-leopard-leopard/
  # git clone git://github.com/masterkain/ImageMagick-sl.git
  # cd ImageMagick-sl
  # sh install_im.sh

  #  # brew update
  #  # brew install imagemagick

  gem "parade"
  #gem "parade-liveruby"
end
```

[parade gem home]: https://github.com/burtlo/parade