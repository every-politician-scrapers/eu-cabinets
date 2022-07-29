#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/wikidata_query'

query = <<SPARQL
  SELECT DISTINCT (STRAFTER(STR(?countryItem), STR(wd:)) AS ?country) (STRAFTER(STR(?cabinetItem), STR(wd:)) AS ?cabinet)
    ?countryItemLabel ?cabinetItemLabel
  WHERE
  {
    ?countryItem p:P463 ?ms .
    ?ms ps:P463 wd:Q458 .
    FILTER NOT EXISTS { ?ms pq:P582 [] }

    OPTIONAL {
      ?cabinetItem wdt:P31/wdt:P279* wd:Q640506 ; wdt:P1001 ?countryItem ; wdt:P571 ?start .
      OPTIONAL { ?cabinetItem wdt:P582 ?end }
      OPTIONAL { ?cabinetItem wdt:P576 ?end }
      FILTER (!BOUND(?end) || (?end > NOW()))
    }
    SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
  }
  ORDER BY ?countryItemLabel ?cabinet
SPARQL

agent = 'every-politican-scrapers/eu-cabinets'
puts EveryPoliticianScraper::WikidataQuery.new(query, agent).csv
