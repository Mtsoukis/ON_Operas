# ONOperas

A Julia package to scrape and format a CSV of opera premieres from **Opening Night! Opera & Oratorio Premieres**, compiled by Stanford University Libraries- with permission. 

---

## Features

- **Scrape premiere data**: Fetch Opera Premiere MetaData. 
- **CSV export**: Optionally save the scraped data directly to a CSV file.

## Installation

```julia
using Pkg
Pkg.add("ONOperas")
```

## Usage

```julia
using ONOperas

# Example URL: Greek operas from 1821 to 2012
url = ["https://exhibits.stanford.edu/operadata/catalog?f%5Bcountry_ssim%5D%5B%5D=Greece&per_page=24&range%5Bpub_year_tisim%5D%5Bbegin%5D=1821&range%5Bpub_year_tisim%5D%5Bend%5D=2021&sort=pub_year_isi+asc%2C+title_sort+asc"]

# Load all Operas to DataFrame
df = scrape_operas(url; pages=7)

# Scrape and save to CSV
df = scrape_operas([url]; pages=1, save_to="data/greece_operas.csv")
```

The returned `df` is a `DataFrame` with the following columns:

- `Opera_Name`
- `Premiere_Date` (Year)
- `Composer`
- `Librettist_Literary_Source`
- `Genre`
- `City`
- `State_Region`
- `Country`
- `Theater`

---

## API Reference

### `scrape_operas(base_urls::Vector{String}; pages::Integer=1, save_to::Union{Nothing,String}=nothing) -> DataFrame`

Fetches metadata for opera premieres listed under each URL in `base_urls`, iterating pages 1 through `pages`. Returns a `DataFrame` with the columns described above. If `save_to` is provided, writes the DataFrame to the given CSV path before returning it.

### `last4(s::AbstractString) -> SubString`

Returns the year of Premiere. This is essentially because in some cases (rare), year might have season or other string before the year data. This measure allows us to get the year, which can be used as numeric. 

---

Missing Fields are left blank.
---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

**Author:** Marios Tsoukis (<mt5656@nyu.edu>)

