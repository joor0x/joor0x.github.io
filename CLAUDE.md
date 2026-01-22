# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal blog built with Hugo using the PaperMod theme. Topics: Evolution, Algorithmic Trading, and Cybersecurity. Deploys to https://joseporiolcarne.github.io/

## Commands

```bash
# Start local development server
hugo server

# Start dev server with drafts visible
hugo server -D

# Build the site for production (outputs to /public)
hugo

# Create a new blog post
hugo new posts/my-new-post/index.md
```

## Architecture

- **Hugo static site** using [PaperMod](https://github.com/adityatelange/hugo-PaperMod) theme (git submodule in `themes/PaperMod`)
- **Configuration**: `hugo.toml` - site settings, menu structure, theme parameters
- **Content**: `content/` - blog posts in `content/posts/`, each post in its own directory with `index.md`
- **Custom layouts**: `layouts/partials/` - template overrides for PaperMod theme

## Content Structure

Blog posts use Hugo's page bundles pattern:
```
content/posts/my-post/
├── index.md          # Post content with front matter
└── images/           # Post-specific images (optional)
```

## Deployment

Site deploys automatically via GitHub Actions when pushing to `main`. The workflow (`.github/workflows/`) builds with Hugo and deploys to GitHub Pages.

Manual build for testing:
```bash
hugo --minify
```

## Blog Post Guidelines

When creating or editing blog posts, follow these SEO and readability guidelines:

- Write SEO-optimized content with relevant keywords naturally integrated
- Include a meta description (under 160 characters) in the front matter `description` field
- Ensure the reading level is suitable for a general audience
- Use clear headings and subheadings for better readability
- Choose tags that accurately reflect the post's content

## Image Style Guide

**Style:**
- Technical minimalism
- Dark/neutral palette
- Clean lines, vector/diagram look
- High contrast, no clutter

**Use for:**
- Diagrams, architectures, workflows
- Charts and data visuals
- Code or dashboard screenshots
- Concept illustrations (trading, AI, infra)

**Avoid:**
- Stock photos
- 3D people, office images
- Busy backgrounds
- Cartoon/playful styles


```

### Reusable Image Generation Prompt

```
Create a wide 16:9 technical–minimalist illustration about {TOPIC}, clean vector style, neutral palette, high contrast, thin geometric lines, spacious layout, no stock elements, no people, no clutter. Focus on horizontal composition with clear left-to-right information flow. Suitable for a modern developer blog.
```
