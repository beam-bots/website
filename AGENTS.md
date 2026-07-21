<!--
SPDX-FileCopyrightText: 2026 James Harton

SPDX-License-Identifier: Apache-2.0
-->

# AGENTS.md

This file provides guidance to coding assistants while working with this project.

## Project Overview

This is the Beam Bots documentation website, built with [Zola](https://www.getzola.org/).

## Common Commands

```bash
zola serve          # Local development server
zola build          # Build static site
pipx run reuse lint # Check REUSE license compliance
```

## Structure

- `content/` - Markdown content (blog posts, pages)
- `templates/` - Zola templates (Tera)
- `sass/` - Stylesheets
- `static/` - Static assets (images, CSS)

## Content Guidelines

- Keep hexdocs as the source of truth for API documentation; the nav "Docs" link points straight at it rather than mirroring guides on the site.
- The ecosystem is surfaced by linking to bb's [dependents on Hex](https://hex.pm/packages/bb/dependents), not a hand-maintained package list.
- The website should link out rather than duplicate content that lives on hexdocs or hex.pm.
- Blog posts for announcements and tutorials that benefit from richer formatting.

## Licensing headers

Every source file must carry an SPDX header — a `#`-style comment for code, an
HTML comment for Markdown, or a `<file>.license` sidecar for files that can't
hold comments (binaries, JSON, lockfiles). `mix check` runs `reuse lint` and
fails the build if one is missing.

When you create a new file, its `SPDX-FileCopyrightText` line must credit **the
user you are working for** — not you (the agent), and not this repo's original
author. Take their name from `git config user.name` (add their `user.email` if
you include one) and use the current year. Match the neighbouring files'
`SPDX-License-Identifier` (usually `Apache-2.0`):

```
SPDX-FileCopyrightText: <current year> <your user's name>

SPDX-License-Identifier: Apache-2.0
```

Never copy an existing file's copyright line onto a new file — that credits the
wrong person. When you only edit an existing file, leave its headers unchanged.
