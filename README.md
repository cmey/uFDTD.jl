# uFDTD.jl
Implementation of a simple FDTD solver, based on [*Understanding the Finite-Difference Time-Domain Method*, John B. Schneider](https://www.eecs.wsu.edu/~schneidj/ufdtd/).

## Package status

| macOS | Linux | Windows |
|-------|-------|---------|
|[![Build Status](https://travis-matrix-badges.herokuapp.com/repos/cmey/uFDTD.jl/branches/master/2)](https://travis-ci.org/cmey/uFDTD.jl)|[![Build Status](https://travis-matrix-badges.herokuapp.com/repos/cmey/uFDTD.jl/branches/master/1)](https://travis-ci.org/cmey/uFDTD.jl)|[![Build status](https://ci.appveyor.com/api/projects/status/8asn340ovfwurmqf?svg=true)](https://ci.appveyor.com/project/cmey/ufdtd-jl)|

## Setup

### To run code in the package directly

Start julia with `julia --project=.` from inside this git repo.

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

# display probes
using PyPlot
figure(); plot(p0);
figure(); imshow(p1); colorbar();
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
