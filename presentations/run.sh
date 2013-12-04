slideshow build 01/vagrant-and-chef.md -t s6blank
slideshow build 02/better-code-quality-with-tests.md -t s6blank
slideshow build 03/nodejs-for-enterprise.md -t s6blank

wkhtmltopdf --outline --orientation Landscape vagrant-and-chef.pdf.html 01/vagrant-and-chef.pdf

wkhtmltopdf --outline --orientation Landscape better-code-quality-with-tests.html 02/better-code-quality-with-tests.pdf

wkhtmltopdf --outline --orientation Landscape nodejs-for-enterprise.pdf.html 03/nodejs-for-enterprise.pdf

