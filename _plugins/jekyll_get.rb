require 'csv'
require 'open-uri'
require 'json'

module Jekyll_Get
  class Generator < Jekyll::Generator
    safe true
    priority :highest

    ONG_CSV_URL = "https://docs.google.com/spreadsheets/d/1NQAfOgeO8CwYVzDDjkATrHZ9RssyyVzvl_CYYBVIU9U/pub?output=csv"

    def generate(site)
      site.data["ongs"] = CSV.new(open(ONG_CSV_URL).read, headers: :first_row).select { |row| row[5] == "Aprovado" }.map do |row|
        fetch_ong_from_csv_row(row)
      end
    end

    def fetch_ong_from_csv_row(row)
      {
        "name" => row[1].encode!("utf-8", "utf-8", :invalid => :replace),
        "email" => row[2].encode!("utf-8", "utf-8", :invalid => :replace),
        "description" => row[3].encode!("utf-8", "utf-8", :invalid => :replace),
        "needs" => row[4].encode!("utf-8", "utf-8", :invalid => :replace)
      }
    end
  end
end
