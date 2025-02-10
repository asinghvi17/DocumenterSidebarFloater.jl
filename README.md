# DocumenterSidebarFloater

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://asinghvi17.github.io/DocumenterSidebarFloater.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://asinghvi17.github.io/DocumenterSidebarFloater.jl/dev/)
[![Build Status](https://github.com/asinghvi17/DocumenterSidebarFloater.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/asinghvi17/DocumenterSidebarFloater.jl/actions/workflows/CI.yml?query=branch%3Amain)

## Overview

DocumenterSidebarFloater.jl is a small plugin for the [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl) documentation generator. It automatically inserts a floating admonition (or “floater”) on your documentation pages, giving you a customizable message area that can include links, titles, or any content you want to highlight.

## Key Features
- Floaters can be configured with different styles, links, and text content.  
- They’re inserted automatically at the bottom of every documentation page during the build process.  
- A JavaScript module (popup.js) manages the floater’s display and can be customized or replaced.

## Usage

### Make File (@make.jl)
In `docs/make.jl`, simply include

```julia
plugins = [FloaterConfig("Commercial user?", "Click here for commercial support!"; link = "https://juliahub.com")]
```
as a keyword argument to `makedocs`.  (Of course, this requires `using DocumenterSidebarFloater` in that file.)