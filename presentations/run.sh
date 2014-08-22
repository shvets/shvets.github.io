http://wkhtmltopdf.org/

slideshow build 01/vagrant-and-chef.md
slideshow build 02/better-code-quality-with-tests.md
slideshow build 03/nodejs-for-enterprise.md

wkhtmltopdf --outline --orientation Landscape --lowquality vagrant-and-chef.pdf.html 01/vagrant-and-chef.pdf

wkhtmltopdf --outline --orientation Landscape --lowquality better-code-quality-with-tests.pdf.html 02/better-code-quality-with-tests.pdf

wkhtmltopdf --outline --orientation Landscape --lowquality nodejs-for-enterprise.pdf.html 03/nodejs-for-enterprise.pdf

