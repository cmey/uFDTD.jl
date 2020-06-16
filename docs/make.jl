using Documenter
using uFDTD

makedocs(
    sitename = "uFDTD.jl",
    format = Documenter.HTML(),
    modules = [uFDTD]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
