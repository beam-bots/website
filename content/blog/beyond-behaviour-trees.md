+++
title = "Beyond Behaviour Trees: Task Orchestration the Elixir Way"
date = 2026-01-09
description = "Why we chose Reactor sagas over behaviour trees for robot task orchestration, and what that means for resilience and safety."
tags = ['architecture']

[extra.author]
github = "jimsynz"
name = "James Harton"
+++

Robot arms don't just move to positions. They pick things up, put them down, respond to sensor feedback, and recover when something goes wrong. Orchestrating these multi-step sequences is one of the harder problems in robotics software.

The standard answer in ROS land is behaviour trees. We went a different direction.

## What's a Behaviour Tree?

*If you're already familiar with behaviour trees, [skip to the next section](#the-tick-problem).*

A behaviour tree is a way to structure complex robot behaviours as a tree of nodes. Each node is either a **leaf** (an action like "move arm" or a condition check like "is object detected?") or a **composite** that controls execution flow.

The key composite types are:

- **Sequence** - runs children left-to-right, stops on first failure
- **Selector** (or Fallback) - runs children left-to-right, stops on first success
- **Parallel** - runs all children simultaneously, with configurable success/failure policies

A pick-and-place behaviour tree might look like this:

```
Sequence
├── Selector
│   ├── Condition: "Object in gripper?"
│   └── Sequence
│       ├── Action: "Move to pick position"
│       ├── Action: "Close gripper"
│       └── Condition: "Grip force detected?"
├── Action: "Move to place position"
└── Action: "Open gripper"
```

The tree gets **ticked** - a clock pulse that propagates through the tree from root to leaves. Each node returns one of three states: **Success**, **Failure**, or **Running**. The composites use these return values to decide what to do next.

This pattern emerged from game AI, where characters need to evaluate their situation continuously and switch behaviours fluidly. It works well for reactive systems that need to constantly reassess their environment.

## The Tick Problem

Behaviour trees are designed for continuous polling.

Every tick, the tree re-evaluates from the root. Is the condition still true? Is the action still running? Should we abort and try a different branch? This polling model makes sense when you're a game character checking if an enemy is nearby sixty times per second.

For robot arms? Less so.

When I tell my WidowX-200 to move to a position, I don't need to poll it every 16 milliseconds to check if it's still moving. The servo controller knows when motion completes. It can tell me. This is what message-passing systems are built for.

Tick-based execution also means your tree traversal logic runs constantly, even when nothing is happening. That's fine on a desktop PC. On a Raspberry Pi running Nerves with other things to do? Every cycle counts.

*For Elixir developers:* Imagine implementing GenServer where instead of receiving messages, you had to poll a `check_state/0` function in a loop. That's essentially what tick-based behaviour trees ask you to do.

*For robotics developers:* Imagine if your motor controllers just sent you a message when motion completed instead of you having to poll them. That's what Elixir's message passing gives you for free.

## Enter Reactor

I wrote [Reactor](https://hexdocs.pm/reactor) as part of my work on the Ash Framework core team. It's a dynamic, concurrent, dependency-resolving saga orchestrator - a mouthful, but the core idea is simple: you define a series of steps with explicit dependencies, and Reactor figures out how to run them. Concurrently where possible, sequentially where necessary.

The "saga" part is crucial. In distributed systems, a saga is a sequence of operations where each step can define recovery actions:

- **`compensate`** - what to do if *this step* fails
- **`undo`** - what to do if *a downstream step* fails (roll back successful work)

This gives you transaction-like semantics across operations that can't actually be wrapped in a database transaction. Like, say, robot movements.

Reactor already handles all the hard parts: dependency graph resolution, concurrent execution, error propagation, rollback coordination. It's been battle-tested in production Ash applications. Building robotics-specific steps on top of it was straightforward.

## BB.Reactor

The `bb_reactor` package extends Reactor with robotics-specific steps. Here's the demo sequence from our WidowX-200 example:

```elixir
defmodule BB.Example.WX200.Reactor.DemoSequence do
  use Reactor, extensions: [BB.Reactor]

  wait_for_state :ready do
    states [:idle]
    timeout 5000
  end

  command :go_home do
    command :home
    wait_for :ready
  end

  command :trace_circle do
    command :demo_circle
    wait_for :go_home
  end

  command :return_home do
    command :home
    wait_for :trace_circle
  end

  return :return_home
end
```

![The demo sequence running in simulation](/reactor-demo-sequence.webp)

No tick loop. No polling. The reactor waits for the robot to reach idle state, then executes commands in sequence, each waiting for the previous to complete via message passing.

The DSL provides three step types:

**`command`** - executes a BB command (like moving or gripper control). Can specify a `compensate` handler for failure recovery.

**`wait_for_event`** - subscribes to the BB PubSub and waits for a matching message. Useful for sensor feedback like "wait until force sensor detects grip".

**`wait_for_state`** - waits for the robot state machine to reach a target state.

## Why This Matters

### Safe Failure Recovery

```elixir
command :move_to_place do
  command :move_to_pose
  argument :target, input(:place_pose)
  wait_for :grip_confirmed
  compensate :return_home
end
```

If this movement fails, the reactor runs the `:return_home` command to recover. The arm doesn't get left in an unknown state.

Behaviour trees have no built-in concept of compensation. You can implement it, but you're on your own.

### Dependency-Driven Concurrency

Reactor analyses the dependency graph and runs independent steps in parallel automatically. If two steps don't depend on each other, they execute concurrently.

```elixir
command :prepare_gripper do
  command :open_gripper
  wait_for :ready
end

command :move_to_approach do
  command :move_to_pose
  argument :target, input(:approach_pose)
  wait_for :ready
end

# Both run in parallel - they only depend on :ready
command :grip do
  command :close_gripper
  wait_for [:prepare_gripper, :move_to_approach]  # waits for both
end
```

With behaviour trees, you'd need explicit Parallel nodes and careful tree structure to achieve the same thing.

### Event-Driven, Not Poll-Driven

Steps block on actual events, not tick cycles:

```elixir
wait_for_event :grip_confirmed do
  path [:sensor, :force_torque]
  message_types [ForceTorque]
  filter &(&1.payload.force > 5.0)
  timeout 2000
end
```

This subscribes to the force/torque sensor topic and waits for a message where force exceeds 5N. No polling. The step completes the moment the message arrives.

### Safety Integration

BB.Reactor monitors for safety state changes. If the robot disarms mid-sequence (emergency stop, hardware fault, whatever), the reactor halts immediately with `{:halt, :safety_disarmed}`. No more steps execute.

The command step watches the command process and detects disarm events automatically. You don't have to sprinkle safety checks throughout your tree.

## The Trade-Off

Behaviour trees excel at reactive, continuous behaviours - things that need to constantly reassess the environment and switch strategies. A robot navigating a dynamic environment, dodging obstacles in real-time, might genuinely benefit from tick-based evaluation.

Reactor sagas excel at structured task sequences - things with clear steps, dependencies, and rollback requirements. Assembly operations, pick-and-place, inspection sequences.

Behaviour trees aren't wrong. They're just not the only tool, and for the kind of deterministic task orchestration that robot arms typically need, sagas are a better fit.

Plus, they're already built on the patterns Elixir gives you for free.

## Links

- [bb_reactor on Hex](https://hex.pm/packages/bb_reactor) (v0.2.0)
- [Reactor on Hex](https://hex.pm/packages/reactor)
- [bb on Hex](https://hex.pm/packages/bb)
- [bb_example_wx200 on GitHub](https://github.com/beam-bots/bb_example_wx200)
- [Discord](https://discord.gg/McZmMaR34P)

### Behaviour Tree Implementations (for comparison)

- [BehaviorTree.CPP](https://www.behaviortree.dev/) - C++ library used with ROS2
- [py_trees](https://py-trees.readthedocs.io/) - Python library, also used with ROS
- [SMACH](http://wiki.ros.org/smach) - ROS state machine library (predecessor pattern)
