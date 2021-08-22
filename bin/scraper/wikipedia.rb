#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'
require 'scraped'
require 'wikidata_ids_decorator'

require 'open-uri/cached'

class Government < Scraped::HTML
  field :country do
    country_link.attr('wikidata').tidy
  end

  field :countrylabel do
    country_link.attr('title').tidy
  end

  field :cabinet do
    cabinet_link.attr('wikidata').tidy
  end

  field :cabinetlabel do
    cabinet_link.attr('title').tidy
  end

  private

  def country_link
    noko.css('.flagicon a').first
  end

  def cabinet_link
    noko.css('a').last
  end
end

class ListPage < Scraped::HTML
  decorator WikidataIdsDecorator::Links

  field :governments do
    items.map { |p| fragment(p => Government).to_h }
  end

  private

  def items
    noko.css('.navbox-list li')
  end
end

url = 'https://en.wikipedia.org/wiki/Template:EU_governments'
data = ListPage.new(response: Scraped::Request.new(url: url).response).governments

header = data.first.keys.to_csv
rows = data.map { |row| row.values.to_csv }
abort 'No results' if rows.count.zero?

puts header + rows.join
