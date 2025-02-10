module DocumenterSidebarFloater

using Documenter
using Documenter.MarkdownAST
import Markdown

include("genericfloater.jl")
include("buildstage.jl")

# what has to happen here is:
# 1. a documenter block that is a floater but with custom html that pops it out
# 2. a documenter build stage that adds the floater to each page
# 3. a JS file that gets added to the header in the documenter metadata by the 
#    documenter build stage on each page, that does this popping out

# for the block, there need to be customizable styles:
# - HTMLStyle
# - MultiDocumenterStyle
# - VitepressStyle
# - AutoStyle that looks at the format in the metadata and picks it
# This style is dictated by the build stage / plugin NOT the block
# though the block may define its category and have a css field for custom style scoped css

# finally, we need the js to have a close option
# and we need the entire popup to be a link you can click on 
# we also need a space for a logo in the title - but that can be completely html

end
