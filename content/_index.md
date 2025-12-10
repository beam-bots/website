+++
title = "Beam Bots - Resilient Robotics on the BEAM"
template = "index.html"
+++

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
