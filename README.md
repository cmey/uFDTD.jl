# uFDTD.jl
Implementation of a simple FDTD solver

```
include("src/uFDTD.jl")
using uFDTD

# run simulation
p0, p1 = uFDTD.main();

# display probes
using PyPlot
figure(); plot(p1);
figure(); imshow(p1); colorbar();
```
