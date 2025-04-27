module ONOperas

export scrape_operas, last4

using HTTP, Gumbo, Cascadia, DataFrames, CSV
using FilePathsBase: dirname  # for mkpath

"""
    last4(s::AbstractString) -> SubString

Return the last four characters of `s` (or `s` itself if shorter).
"""
last4(s::AbstractString) = length(s) ≥ 4 ? s[end-3:end] : s

"""
    scrape_operas(base_urls::Vector{String};
                  pages::Integer = 1,
                  save_to::Union{Nothing,AbstractString} = nothing)

Fetch metadata for operas listed under each URL in `base_urls`, iterating
pages 1 through `pages`. Returns a DataFrame with columns:

  • Opera_Name  
  • Premiere_Date  
  • Composer  
  • Librettist_Literary_Source  
  • Genre  
  • City  
  • State_Region  
  • Country  
  • Theater  

If `save_to` is a file path (e.g. `"data/italy.csv"`), the DataFrame is
also written to that CSV before being returned.
"""
function scrape_operas(base_urls::Vector{String};
                       pages::Integer = 1,
                       save_to::Union{Nothing,AbstractString} = nothing)

    df = DataFrame(
        Opera_Name                 = String[],
        Premiere_Date              = String[],
        Composer                   = String[],
        Librettist_Literary_Source = String[],
        Genre                      = String[],
        City                       = String[],
        State_Region               = String[],
        Country                    = String[],
        Theater                    = String[]
    )

    for base in base_urls, p in 1:pages
        # build the actual URL string
        url = "$base&page=$p"

        # fetch and parse
        html = parsehtml(String(HTTP.get(url;
                                         headers = ["User-Agent"=>"Mozilla/5.0"]).body))

        for rec in eachmatch(Selector("article.document"), html.root)
            # Opera Name
            title_nodes = eachmatch(Selector("h3.index_title a"), rec)
            name = isempty(title_nodes) ? "" : strip(text(title_nodes[1]))

            # metadata dt/dd pairs
            dts = eachmatch(Selector("dl.document-metadata dt"), rec)
            dds = eachmatch(Selector("dl.document-metadata dd"), rec)
            meta = Dict{String,String}()
            for (dt, dd) in zip(dts, dds)
                key = replace(strip(text(dt)), ":" => "")
                meta[key] = strip(text(dd))
            end

            push!(df, (
                Opera_Name                 = name,
                Premiere_Date              = last4(get(meta, "Premiere Date", "")),
                Composer                   = get(meta, "Composer", ""),
                Librettist_Literary_Source = get(meta, "Librettist / Literary Source", ""),
                Genre                      = get(meta, "Genre", ""),
                City                       = get(meta, "City", ""),
                State_Region               = get(meta, "State / Region", ""),
                Country                    = get(meta, "Country", ""),
                Theater                    = get(meta, "Theater", "")
            ))
        end
    end

    if save_to !== nothing
        mkpath(dirname(String(save_to)))
        CSV.write(String(save_to), df)
    end

    return df
end

end # module ON_Operas
