module uFDTD

function main()
    const spatial_size = 200
    ez = zeros(Float64, spatial_size)
    hy = zeros(Float64, spatial_size)
    const imp0 = 377.0
    m = 0
    qTime = 0
    const maxTime = 250*4

    probe0Dt = zeros(Float64, maxTime)
    probe1Dt = zeros(Float64, (spatial_size, maxTime))

    # do time stepping
    for qTime = 1:maxTime

        # Absorbing Boundary Condition on right side
        hy[spatial_size] = hy[spatial_size-1]

        # update magnetic field
        for m = 1:spatial_size-1
            hy[m] = hy[m] + (ez[m + 1] - ez[m]) / imp0
        end

        # Absorbing Boundary Condition on left side
        ez[1] = ez[2]

        # update electric field
        for m = 2:spatial_size
            ez[m] = ez[m] + (hy[m] - hy[m - 1]) * imp0
        end

        # hardwire source node
        # ez[0] = exp(-(qTime - 30.0) * (qTime - 30.0) / 100.0)

        # additive source node
        ez[50] += exp(-(qTime - 30.0) * (qTime - 30.0) / 100.0)

        # add a point (0D) probe over time
        probe0Dt[qTime] = ez[50]

        # add a line (1D) probe over time
        probe1Dt[:, qTime] = ez
    end

    return probe0Dt, probe1Dt
end

end # module
