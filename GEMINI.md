# Project Overview

This is a personal blog built with the [Hugo](https://gohugo.io/) static site generator and the [PaperMod](https://github.com/adityatelange/hugo-PaperMod) theme. The blog's content focuses on topics like Evolution, Algorithmic Trading, and Cybersecurity.

## Building and Running

To run the blog locally for development, you need to have Hugo installed. You can run the following command to start the local server:

```bash
hugo server
```

To create a new post, you can use the following command:

```bash
hugo new posts/your-post-title/index.md
```

## Deployment

The blog is deployed automatically via GitHub Actions. Any changes pushed to the `main` branch will trigger a new build and deployment.

To publish changes, you can use the `publish.sh` script:

```bash
./publish.sh "Your commit message"
```

This script will add all changes, commit them, and push them to the remote repository.

## Development Conventions

*   All content is written in Markdown.
*   Blog posts are located in the `content/posts` directory. Each post should be in its own directory with an `index.md` file.
*   Images and other assets for a post should be placed in the same directory as the `index.md` file.
