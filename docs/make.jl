using DocumenterSidebarFloater
using Documenter

DocMeta.setdocmeta!(DocumenterSidebarFloater, :DocTestSetup, :(using DocumenterSidebarFloater); recursive=true)

makedocs(;
    modules=[DocumenterSidebarFloater],
    authors="Anshul Singhvi <anshulsinghvi@gmail.com> and contributors",
    sitename="DocumenterSidebarFloater.jl",
    format=Documenter.HTML(;
        canonical="https://asinghvi17.github.io/DocumenterSidebarFloater.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/asinghvi17/DocumenterSidebarFloater.jl",
    devbranch="main",
)
