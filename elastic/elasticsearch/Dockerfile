FROM elasticsearch:7.3.2

RUN mkdir config/certs

COPY elastic-certificates.p12 config/certs

RUN chmod 666 config/certs/elastic-certificates.p12