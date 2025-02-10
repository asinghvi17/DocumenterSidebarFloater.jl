abstract type SidebarFloaterBlocks <: Documenter.Expanders.ExpanderPipeline end

# Order doesn't really matter, because the expansion is done based on page location first.
Documenter.Selectors.order(::Type{SidebarFloaterBlocks}) = 12.0
Documenter.Selectors.matcher(::Type{SidebarFloaterBlocks}, node, page, doc) = Documenter.iscode(node, r"^@sidebarfloater")


function Documenter.Selectors.runner(::Type{<: SidebarFloaterBlocks}, node, page, doc)
    # just add an admonition to the page in the general case
    # this will never be seen

    # TODO: 
    # Parse the node and retrieve:
    #=
    We want the syntax to look like:
    ```@sidebarfloater MyTitleHere; style="tip"
    Here are some contents in [the Markdown language](https://docs.julialang.org/en/v1/manual/markdown-content/).
    ```
    In order to do that, we need 
    =#

    # The title is the first argument after the `@sidebarfloater`
    # The style is the kwarg after the `;`
    # The contents are the contents of the code block, they'll be a String initially
    # but we need to parse them to MarkdownAST somehow...
    # maybe using the interop from Markdown.parse?
    

    # Extract the code block info (e.g. "@sidebarfloater MyTitleHere; style=\"tip\"")
    # so we can parse out the title and any kwargs.
    info_str = node.element.info
    m = match(r"@sidebarfloater\s+(.*)", info_str)
    extracted = m === nothing ? "" : m.captures[1]

    # Split into a title segment (before the semicolon) and a kwarg segment (after the semicolon).
    parts = split(extracted, ";", limit=2)
    title_str = strip(parts[1])
    kwarg_str = length(parts) == 2 ? strip(parts[2]) : ""

    # Default style
    style = "tip"

    # Attempt to parse style="something"
    if !isempty(kwarg_str)
        kwmatch = match(r"style\s*=\s*\"([^\"]+)\"", kwarg_str)
        style = kwmatch === nothing ? "tip" : kwmatch.captures[1]
    end

    # Now parse the code block body as Markdown, so we can insert it properly as children of our admonition.
    parsed_body = convert(MarkdownAST.Node, Markdown.parse(node.element.code))

    # Insert the new Admonition with the parsed title, style, and body.
    admonition_node = MarkdownAST.@ast MarkdownAST.Admonition("tip-floater", title_str) do
    end

    for childnode in parsed_body.children
        push!(admonition_node.children, childnode)
    end

    MarkdownAST.insert_after!(
        last(page.mdast.children),
        admonition_node
    )

    MarkdownAST.insert_after!(
        last(page.mdast.children),
        MarkdownAST.@ast Documenter.RawNode(:html, "<script src=\"/assets/popup.js\"></script>")
    )
    # This will be expanded to a div with the class 
    # ".admonition.is-category-tip-floater
    # and maybe after the Sass build those dots are replaced by spaces, I'm not
    # 100% sure.

    # After the final step, we effectively nullify the element
    # by inserting a MetaNode.
    node.element = Documenter.MetaNode(node.element, page.globals.meta)

    println("Inserted admonition node: $title_str")
end
