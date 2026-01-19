#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 James Harton
# SPDX-License-Identifier: Apache-2.0

# Check Beam Bots ecosystem against GitHub and hex.pm sources of truth
# Usage: ./scripts/check-ecosystem.sh

set -euo pipefail

echo "Fetching repositories from github.com/beam-bots..."
github_repos=$(curl -s "https://api.github.com/orgs/beam-bots/repos?per_page=100" | \
  jq -r '.[].name' | sort)

echo "Fetching packages from hex.pm..."
# hex.pm doesn't have an org endpoint, so we check known packages
# and filter bb_* search results by checking GitHub links
hex_packages=""

# Known packages to check (including those without bb_ prefix)
# Note: robotis is NOT part of beam-bots - it was a temporary fork from pkinney
known_packages="bb feetech"

for pkg in $known_packages; do
  if curl -s "https://hex.pm/api/packages/$pkg" | jq -e '.name' > /dev/null 2>&1; then
    hex_packages=$(echo -e "$hex_packages\n$pkg")
  fi
done

# Search for bb_* packages and verify they link to beam-bots GitHub
bb_search=$(curl -s "https://hex.pm/api/packages?search=bb_")
for pkg in $(echo "$bb_search" | jq -r '.[].name'); do
  pkg_info=$(curl -s "https://hex.pm/api/packages/$pkg")
  # Check all link values for beam-bots (could be under Source, GitHub, etc.)
  all_links=$(echo "$pkg_info" | jq -r '.meta.links | values[]' 2>/dev/null || echo "")
  if echo "$all_links" | grep -q "beam-bots"; then
    hex_packages=$(echo -e "$hex_packages\n$pkg")
  fi
done

hex_packages=$(echo "$hex_packages" | grep -v '^$' | sort -u)

echo ""
echo "=== GitHub Repositories (beam-bots org) ==="
echo "$github_repos"

echo ""
echo "=== Hex.pm Packages (bb_* prefix + known others) ==="
echo "$hex_packages"

echo ""
echo "=== Summary ==="
echo "GitHub repos: $(echo "$github_repos" | wc -l | tr -d ' ')"
echo "Hex packages: $(echo "$hex_packages" | wc -l | tr -d ' ')"

echo ""
echo "=== Packages on hex.pm but not on GitHub ==="
comm -23 <(echo "$hex_packages") <(echo "$github_repos") || echo "(none)"

echo ""
echo "=== Repos on GitHub but not on hex.pm ==="
comm -13 <(echo "$hex_packages") <(echo "$github_repos") || echo "(none - this is expected for non-library repos like website, proposals, etc.)"
