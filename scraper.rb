require 'scraperwiki'
require 'rss/2.0'
require 'date'
require 'mechanize'

url = 'http://bizsearch.penrithcity.nsw.gov.au/ePlanning/Pages/XC.Track/SearchApplication.aspx?d=thismonth&k=LodgementDate&t=DA&o=rss'

agent = Mechanize.new

# For some incomprehensible reason, there's an "I agree" page for an RSS feed.
page = agent.get(url)
form = page.forms.first
form.checkbox_with(:name => /Agree/).check
page2 = form.submit(form.button_with(:name => /Agree/))

t = page2.content.to_s

# I've no idea why the RSS feed says it's encoded as utf-16 when as far as I can tell it isn't
# Hack it by switching it back to utf-8
t.gsub!("utf-16", "utf-8")


# Now we can fetch the data
feed = RSS::Parser.parse(t, false)

feed.channel.items.each do |item|
  record = {
    'council_reference' => item.title.split(' ')[0],
    'description'       => item.description.split('.')[1].strip,
    # Have to make this a string to get the date library to parse it
    'date_received'     => Date.parse(item.pubDate.to_s),
    'address'           => item.description.split('.')[0].strip,
    'info_url'          => item.link,
    # Comment URL is actually an email address but I think it's best
    # they go to the detail page
    'comment_url'       => item.link,
    'date_scraped'      => Date.today.to_s
  }
  
  if ScraperWiki.select("* from data where `council_reference`='#{record['council_reference']}'").empty? 
    ScraperWiki.save_sqlite(['council_reference'], record)
  else
     puts "Skipping already saved record " + record['council_reference']
  end
end

