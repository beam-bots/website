+++
title = "Community"
description = "Get Beam Bots, ask questions, report bugs, request features, and contribute"
+++

Beam Bots is a young, fast-moving project built in the open. Whether you want to
drive your first servo, write a hardware driver, improve the docs, or just follow
along, there's room for you here.

## Get Beam Bots

The core framework is published on Hex. The quickest way to start is with Igniter,
which adds the dependency and sets up the initial configuration for you:

<div class="install-box">
  <code>mix igniter.install bb</code>
</div>

- **Package:** [hex.pm/packages/bb](https://hex.pm/packages/bb)
- **Documentation:** [hexdocs.pm/bb](https://hexdocs.pm/bb)
- **Source:** [github.com/beam-bots](https://github.com/beam-bots)

New to the framework? Work through [Your First Robot](https://hexdocs.pm/bb/01-first-robot.html)
on HexDocs.

The wider ecosystem (servo drivers, IK solvers, sensors, visualisation, and more) is
published on Hex as [packages that build on bb](https://hex.pm/packages/bb/dependents).

## Ask a Question

The fastest way to get help is {{ discord() }}. Drop in,
say hello, and ask away. Questions from newcomers are genuinely welcome.

You can also open an issue on the relevant repository if a question is better
tracked in writing.

## Report a Bug

Found something broken? Open an issue on the repository where the problem lives.
For the core framework, that's [beam-bots/bb](https://github.com/beam-bots/bb/issues).
Each package in the ecosystem has its own issue tracker on [GitHub](https://github.com/beam-bots).

A good bug report includes what you expected to happen, what actually happened, and
the smallest set of steps that reproduces it.

For **security vulnerabilities**, please don't open a public issue. Follow the
[security policy](/security/) instead.

## Request a Feature

Feature requests and larger changes are tracked in the
[proposals repository](https://github.com/beam-bots/proposals). Before building
anything significant, open a proposal there first. The best proposals focus on the
*use case* (what you're trying to do and why) rather than the implementation
details.

Smaller enhancements are fine as an issue on the relevant repository.

## Contribute

Contributions of every size are welcome, from typo fixes to new hardware drivers.
The [contributing guide](https://github.com/beam-bots/.github/blob/main/CONTRIBUTING.md)
covers how to set up a development environment, the documentation workflow, and the
ground rules.

A few good places to start:

- **Documentation**: the most valuable contribution you can make. Spotted a typo
  or an unclear explanation? A pull request is preferred over an issue.
- **Hardware drivers**: got a servo, sensor, or board that isn't supported yet?
  The existing [packages on GitHub](https://github.com/beam-bots) are worth reading as templates.
- **Pick up a proposal**: the [proposals repository](https://github.com/beam-bots/proposals)
  is where planned work lives. Find one you'd like to build and say so on
  {{ discord() }} so we don't double up.

Not sure where to start? Ask on {{ discord() }} and we'll point you at
something that needs doing.

All participation is governed by our
[Code of Conduct](https://github.com/beam-bots/.github/blob/main/CODE_OF_CONDUCT.md).

## Follow Along

New developments land roughly every month on the [blog](/blog/), and the
[Atom feed](/atom.xml) will keep you up to date.

## Support the Project

Beam Bots is solo-maintained. If it's useful to you and you'd like to help keep the
work going, you can sponsor development via
[GitHub Sponsors](https://github.com/sponsors/jimsynz).
