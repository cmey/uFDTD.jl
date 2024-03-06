# uFDTD.jl

Implementation of a simple FDTD solver, based on [*Understanding the Finite-Difference Time-Domain Method*, John B. Schneider](https://www.eecs.wsu.edu/~schneidj/ufdtd/).

## Package status

![CI status](https://github.com/cmey/uFDTD.jl/actions/workflows/ci.yml/badge.svg)

## Installation

Until this package gets registered, open the Julia environment from inside the package folder:
```
julia --project=.
```

### To setup this package as a library in your own code

Until this package gets registered, you cannot simply do `pkg> add uFDTD`. Instead, activate your environment and do once per system:
```julia
(scratch) pkg> develop --local ~/path/to/uFDTD.jl  # (the package, not the file)
```

## Usage

```julia
using uFDTD

# Define simulation parameters (use many default values, see uFDTDParameters).
sim_params = uFDTDParameters()

# Run simulation.
p0, p1 = uFDTD.simulate(sim_params)

# Display probes.
using GLMakie
#   0D+t probe:
display(GLMakie.Screen(), lines(p0))
#   1D+t probe:
fig2d = Figure()
ax = Axis(fig2d[1, 1])
hm = heatmap!(ax, p1)
Colorbar(fig2d[1, 2], hm)
display(GLMakie.Screen(), fig2d)
```

## Tests

```julia
(scratch) pkg> test uFDTD
```

## Documentation

We use `Documenter.jl` as our doc builder, please install it first.

```julia
(scratch) pkg> add Documenter
```

Then, build the documentation.

```shell
$ cd docs
$ make
```

The generated doc is located at `docs/build`. Visualize it:
```shell
$ open docs/build/index.html
```
