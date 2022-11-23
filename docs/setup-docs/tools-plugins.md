# Tools & Plugins

## markdownlint-cli

When you have a project with markdown (`.md`) files, or when building documentation sites based on markdown files (e.
g., with Mkdocs), you can use [markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli) to improve your 
markdown code.

Install with homebrew:

```bash
brew install markdownlint-cli
```

It uses a default ruleset to check your files, but you can also tweak that ruleset by including a `.markdownlint.
yml` or `.markdownlint.jsonc` file in your project's root. In this file you can change the ruleset. See this [yml
file](https://github.com/DavidAnson/markdownlint/blob/main/schema/.markdownlint.yaml) for an example. This file also
explains the rules and their behaviour.

### template

I use the following `.markdownlint.yml` template:

```yaml
---
default: true

# MD003/heading-style/header-style - Heading style
MD003:
  style: atx

# MD004/ul-style - Unordered list style
MD004:
  style: asterisk

# MD007/ul-indent - Unordered list indentation
MD007:
  indent: 4

# MD013/line-length - Line length
MD013: false

# MD025/single-title/single-h1 - Multiple top-level headings
# in the same document
MD025: false

# MD030/list-marker-space - Spaces after list markers
MD030:
  ul_multi: 1
  ol_multi: 2

# MD035/hr-style - Horizontal rule style
MD035:
  style: ---

# MD046/code-block-style - Code block style
MD046: false
```
