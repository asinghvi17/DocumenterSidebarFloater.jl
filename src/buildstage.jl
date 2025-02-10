
abstract type FloaterProcessing <: Documenter.Builder.DocumentPipeline end

Documenter.Selectors.order(::Type{FloaterProcessing}) = 1.2

"""
    struct FloaterConfig 
A configuration object for adding a sidebar floater to every page.

# Fields
- `link::String`  (default: `""`)
- `style::String` (default: `"tip"`)
- `title::String`
- `body::String`
"""
struct FloaterConfig <: Documenter.Plugin
    link::String
    style::String
    title::String
    body::String
end

FloaterConfig(title::String, body::String; link = "", style = "tip") = FloaterConfig(link, style, title, body)

FloaterConfig() = FloaterConfig("You didn't configure DocumenterSidebarFloater.jl!", "Click here to see the docs, nitwit!"; link = "asinghvi17.github.io/DocumenterSidebarFloater.jl/dev/", style = "danger")

function Documenter.Selectors.runner(::Type{FloaterProcessing}, doc::Documenter.Document)
    # Obtain our config from the Documenter plugin settings.
    config = Documenter.getplugin(doc, FloaterConfig)

    # For each page, insert a code block at the bottom representing `@sidebarfloater`
    for (filename, page) in doc.blueprint.pages
        MarkdownAST.insert_after!(
            last(page.mdast.children),
            MarkdownAST.@ast MarkdownAST.CodeBlock(
                "@sidebarfloater $(config.title); style=\"$(config.style)\", link=\"$(config.link)\"",
                config.body
            )
        )
    end

    # Copy "popup.js" from the local assets folder to doc.user.build/assets.

    # read the popup.js file
    nonreplaced_string = read(joinpath(dirname(@__DIR__), "assets", "popup-nonreplaced.js"), String)

    replaced_string = replace(
        nonreplaced_string, 
        "REPLACE_ME_DFC_FLOATER_STYLE" => config.style,
        "REPLACE_ME_DFC_FLOATER_LINK" => config.link,
    )

    mkpath(joinpath(doc.user.build, "assets"))
    write(  
        joinpath(doc.user.build, "assets", "popup.js"),
        replaced_string
    )

    # Check for HTML formatters in doc.user.format and add "assets/popup.js" to their assets.
    # but actually don't, because we want to add it as a script tag in the html.
    # this makes it incompatible with vitepress but w/e, we can make a component for that later.
    # for fmt in doc.user.format
    #     if fmt isa Documenter.HTML.HTML
    #         push!(fmt.assets, to_valid_documenterhtml_asset("assets/popup.js"))
    #     end
    # end


end



function to_valid_documenterhtml_asset(asset)
    isa(asset, Documenter.HTML.HTMLAsset) && return asset
    isa(asset, AbstractString) && return Documenter.HTML.HTMLAsset(Documenter.HTML.assetclass(asset), asset, true)
    error("Invalid value in assets: $(asset) [$(typeof(asset))]")
end
