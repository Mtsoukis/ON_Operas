using Test
using ONOperas
using DataFrames

@testset "Basic scrape" begin
    url = "https://exhibits.stanford.edu/operadata/catalog?f%5Bcountry_ssim%5D%5B%5D=Italy&per_page=96&search_field=composer"
    df  = scrape_operas([url]; pages=1)
    @test nrow(df) > 0
    @test "Opera_Name" in names(df)
end
