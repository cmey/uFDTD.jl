# uFDTD.jl
Implementation of a simple FDTD solver.

## Installation

Until this package gets registered, do once per system:
```
(v1.1) pkg> dev uFDTD.jl
```

## Usage

```
using uFDTD

# run a simulation
p0, p1 = uFDTD.main();

# display probes
using PyPlot
figure(); plot(p0);
figure(); imshow(p1); colorbar();
```
