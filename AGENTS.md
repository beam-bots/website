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
zola serve    # Local development server
zola build    # Build static site
```

## Structure

- `content/` - Markdown content (blog posts, pages)
- `templates/` - Zola templates (Tera)
- `sass/` - Stylesheets
- `static/` - Static assets (images, CSS)
- `scripts/` - Maintenance scripts

## Maintenance Tasks

### Keeping the Ecosystem Documentation in Sync

The website may include information about Beam Bots packages. Since the ecosystem evolves rapidly, periodically verify the package list is current:

```bash
./scripts/check-ecosystem.sh
```

This script queries github.com/beam-bots and hex.pm to show:
- All repositories in the beam-bots GitHub org
- All packages on hex.pm linked to beam-bots
- Discrepancies between the two

**When to run**: Before adding or updating ecosystem documentation, or when you suspect the package list may be stale.

**Expected discrepancies**:
- Repos not on hex.pm: `.github`, `proposals`, `website`, `bb_example_wx200` (example app, not a library)

**Note**: The `robotis` hex.pm package is NOT part of beam-bots. It was a temporary fork from pkinney/robotis while implementing features needed for bb_servo_robotis.

### Content Guidelines

- Keep hexdocs as the source of truth for API documentation
- The website should link to hexdocs rather than duplicate content
- Blog posts for announcements and tutorials that benefit from richer formatting
