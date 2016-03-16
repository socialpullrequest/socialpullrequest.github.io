require 'csv'
require 'open-uri'
require 'json'

module Jekyll_Get
  class Generator < Jekyll::Generator
    safe true
    priority :highest

    ONG_CSV_URL = "https://docs.google.com/spreadsheets/d/1NQAfOgeO8CwYVzDDjkATrHZ9RssyyVzvl_CYYBVIU9U/pub?output=csv"
    DEV_CSV_URL = "https://docs.google.com/spreadsheets/d/1IT3Uo2YW5mv2iVjThRfj2Uc4Ac0yFXlWu4ZCnbKBVaU/pub?&output=csv"
    GITHUB_API  = "https://api.github.com"

    def generate(site)
      site.data["ongs"] = fetch_ongs
      site.data["devs"] = fetch_devs
    end

    def fetch_ongs
      fetch_csv(ONG_CSV_URL) { |row| fetch_ong_from_csv_row(row) }
    end

    def fetch_devs
      fetch_csv(DEV_CSV_URL) { |row| fetch_dev_from_csv_row(row) }
    end

    def fetch_csv(url)
      CSV.new(open(url), headers: :first_row).select { |row| row[-1] == "Aprovado" }.map do |row|
        yield(row)
      end
    end

    def fetch_dev_from_csv_row(row)
      {
        "name" =>  fetch_cell(row, 1),
        "email" =>  fetch_cell(row, 2),
        "description" =>  fetch_cell(row, 3),
        "github" =>  fetch_github(fetch_cell(row, 4))
      }
    end

    def fetch_ong_from_csv_row(row)
      {
        "name" => fetch_cell(row, 1),
        "email" =>  fetch_cell(row, 2),
        "description" =>  fetch_cell(row, 3),
        "needs" =>  fetch_cell(row, 4)
      }
    end

    def fetch_cell(row, cell)
      row[cell] && row[cell].encode!("utf-8", "utf-8", invalid: :replace)
    end

    def fetch_github(username)
      username && JSON.load(open("#{GITHUB_API}/users/#{username}"))
    end
  end
end
