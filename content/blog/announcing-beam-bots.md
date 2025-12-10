+++
title = "Announcing Beam Bots: Resilient Robotics on the BEAM"
date = 2025-12-09
description = "Introducing Beam Bots, a framework for building fault-tolerant robotics applications in Elixir using familiar OTP patterns."
+++

I've been working on something I'm excited to share: [Beam Bots](https://github.com/beam-bots/bb), a framework for building resilient robotics applications in Elixir. It's early days - the code hasn't controlled any physical robots yet - but the core is there and I'm looking for feedback and contributors.

If you're an Elixir developer who's ever been curious about robotics, read on.

## Why Not Just Use ROS?

As a hobby roboticist I've looked at [ROS](https://www.ros.org/) (Robot Operating System) for my projects. ROS is the industry standard, and for good reason - it solves real problems around inter-process communication, hardware abstraction, and tooling for robotics development.

But ROS is designed for a different context than my hobby projects. You're expected to deploy a full Ubuntu system with a stack of packages on top of it. There are no OS images, no A/B firmware systems, no turnkey deployment story. ROS gives you the flexibility to design systems using many different technologies, but that flexibility comes with complexity.

For my hobby projects, I wanted something lighter.

## ROS Looks a Lot Like OTP

This isn't a new observation for me. I wrote about this back in 2020 hoping someone else would build the tooling. Five years later, nobody had, so here we are.

When reading about ROS2's architecture, the pattern becomes obvious: so much of what ROS provides are just stock BEAM/OTP/Elixir patterns.

- ROS2's **pubsub** for inter-node communication? Elixir has `Phoenix.PubSub`, `Registry`, and built-in process messaging.
- ROS2's **Services** (request/response)? That's `GenServer.call/3`.
- ROS2's **Actions** (long-running tasks with feedback)? That's a supervised `Task` with progress messages.
- ROS2's **Controllers** managing robot behaviour? GenServers with state machines.
- ROS2's **lifecycle nodes**? GenServers with explicit state transitions.
- ROS2's **parameter system**? That's ETS.

The BEAM already gives you fault tolerance, massive concurrency, soft real-time performance, and excellent behaviour in resource-constrained environments. Why reinvent all of that?

## What Beam Bots Provides

Beam Bots builds on this insight. It provides:

**A Spark DSL for declarative robot definitions.** Your robot's topology - links, joints, sensors, actuators - is defined in code that mirrors the physical structure. Here's a simple pan-tilt camera mount:

```elixir
defmodule PanTiltCamera do
  use BB

  topology do
    link :base_link do
      visual do
        cylinder do
          radius ~u(0.03 meter)
          height ~u(0.02 meter)
        end
      end

      joint :pan_joint do
        type :revolute
        origin do
          z ~u(0.015 meter)
        end

        limit do
          lower ~u(-170 degree)
          upper ~u(170 degree)
        end

        link :pan_link do
          joint :tilt_joint do
            type :revolute

            limit do
              lower ~u(-45 degree)
              upper ~u(90 degree)
            end

            link :camera_link
          end
        end
      end
    end
  end
end
```

The nesting in the code directly reflects the nesting in the physical robot. If you can read the code, you can understand the structure.

Because it's a DSL built on Elixir macros, you can metaprogram your robots. Something as simple as `for arm <- [:left, :right], do: joint(...)` to avoid repetition, or as sophisticated as writing a Spark DSL extension that transforms your robot definition at compile time.

**Topology-based supervision.** When you start a robot, Beam Bots builds a supervision tree that mirrors your robot's physical topology. Why does this matter? Fault isolation. If code controlling a gripper crashes repeatedly, the restart intensity propagates up through the supervision tree. A failing component further down the topology takes longer to impact the entire system, giving your robot more time to reach a safe state.

**Physical units with the `~u` sigil.** Express measurements naturally - `~u(90 degree)`, `~u(0.5 meter)`, `~u(10 newton_meter)` - with automatic conversion to SI base units internally.

**Forward kinematics using [Nx](https://github.com/elixir-nx).** Compute the position of any link in your robot's kinematic chain using efficient tensor operations. On supported systems, these calculations can run on the GPU.

**Hierarchical PubSub for sensor data.** Subscribe to sensor topics using path-based addressing with optional message type filtering. Want all IMU data from the left arm? `subscribe(MyRobot, [:sensor, :left_arm], message_types: [BB.Message.Sensor.Imu])`.

**URDF export.** Need to visualise your robot in Gazebo or integrate with ROS tools? Export your robot definition to URDF with `mix bb.to_urdf MyRobot -o robot.urdf`.

## Where It Runs

Beam Bots runs anywhere Elixir runs:

- **Nerves devices** - from Raspberry Pi to custom hardware, managed at scale via NervesHub with proper OTA updates and A/B firmware
- **Distributed Erlang clusters** - multiple devices inside a single robot system can communicate transparently
- **A single PC running Livebook** - prototype and experiment interactively

The only requirement is Nx support for the kinematics calculations.

## Current Status

I want to be upfront: Beam Bots hasn't controlled any physical robots yet. The framework compiles, the tests pass, the DSL works, but I haven't closed the loop with actual hardware.

That's changing. I'm currently building a Mars-style rover with rocker-bogie suspension and YOLO-based object detection and avoidance. Updates will follow as I make progress.

## What's Next

The roadmap includes:

- **Inverse kinematics** using the FABRIK algorithm
- **Simulation support** with Gazebo and/or Webots integration
- **Protocol bridges** for MAVLINK, MSP, Crossfire, and other common robotics protocols
- **Extension packages** providing out-of-the-box support for common sensors and actuators
- **LiveView-based introspection** for monitoring and debugging running robots
- **Kino plugins** for rich robotics interactions in Livebook

## Get Involved

Beam Bots is published on Hex as [`bb`](https://hex.pm/packages/bb). The easiest way to get started is with Igniter:

```bash
mix igniter.install bb
```

If this sounds interesting, I'd love your feedback:

- **[GitHub: beam-bots/bb](https://github.com/beam-bots/bb)** - browse the code, open issues, send PRs
- **[Documentation](https://hexdocs.pm/bb/readme.html)** - tutorials and API reference
- Try defining a robot and let me know where the DSL feels awkward
- If you have robotics hardware, help me close the loop with real-world testing

This isn't production ready. But it's ready for exploration, and I think there's something here worth building together.
