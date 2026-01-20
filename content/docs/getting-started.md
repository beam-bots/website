+++
title = "Getting Started"
description = "Get up and running with Beam Bots in minutes"
weight = 1
+++

## Installation

Add BB to your Elixir project using Igniter:

<div class="install-box">
  <code>mix igniter.install bb</code>
</div>

This will add `bb` to your dependencies and set up the initial configuration.

<div class="getting-started-steps">
  <div class="getting-started-step">
    <span class="step-number">1</span>
    <div class="step-content">
      <h3>Define your robot</h3>
      <p>Use the BB DSL to describe your robot's structure, including links, joints, and actuators.</p>
    </div>
  </div>
  <div class="getting-started-step">
    <span class="step-number">2</span>
    <div class="step-content">
      <h3>Configure your hardware</h3>
      <p>Connect actuator drivers for your servo hardware (PCA9685, Dynamixel, pigpio, etc.).</p>
    </div>
  </div>
  <div class="getting-started-step">
    <span class="step-number">3</span>
    <div class="step-content">
      <h3>Run and visualise</h3>
      <p>Start your robot's supervision tree and use Livebook widgets or the LiveView dashboard to control it.</p>
    </div>
  </div>
</div>

## Next Steps

Ready to dive deeper? Start with the first tutorial:

<p style="text-align: center; margin-top: 2rem;">
  <a href="https://hexdocs.pm/bb/01-first-robot.html" class="btn btn-primary btn-lg">Your First Robot &rarr;</a>
</p>
