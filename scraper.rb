require "icon_scraper"

IconScraper.scrape_with_params(
  url: "http://bizsearch.penrithcity.nsw.gov.au/ePlanning/Pages",
  period: "thismonth",
  types: ["DA", "DevApp"]
) do |record|
  record["address"] = record["address"].gsub(",", "")
  IconScraper.save(record)
end
