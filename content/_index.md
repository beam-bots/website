+++
title = "Beam Bots - Resilient Robotics on the BEAM"
template = "index.html"
+++

```elixir
defmodule MyRobot do
  use BB

  topology do
    link :base do
      joint :shoulder do
        type :revolute

        limit do
          lower ~u(-90 degree)
          upper ~u(90 degree)
          effort ~u(5 newton_meter)
          velocity ~u(60 degree_per_second)
        end

        link :arm
      end
    end
  end
end
```
