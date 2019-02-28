module uFDTD

function main(hard_source=false, additive_source=false, directional_source=true)
    spatial_size = 200
    maxTime = 250*4
    imp0 = 377.0

    ez = zeros(Float64, spatial_size)
    hy = zeros(Float64, spatial_size)
    er = zeros(Float64, spatial_size)

    # setup relative permittivity
    er_boundary_position = 100
    er_material_value = 9
    for m = 1:spatial_size
        if m < er_boundary_position
            er[m] = 1.0
        else
            er[m] = er_material_value
        end
    end

    m = 0
    qTime = 0

    probe0Dt = zeros(Float64, maxTime)
    probe1Dt = zeros(Float64, (spatial_size, maxTime))

    # do time stepping
    for qTime = 1:maxTime

        # Absorbing Boundary Condition on right side (works only when local Sc=1)
        hy[spatial_size] = hy[spatial_size-1]

        # update magnetic field
        for m = 1:spatial_size-1
            hy[m] = hy[m] + (ez[m + 1] - ez[m]) / imp0
        end

        # Directional source
        # Total-Field/Scattered-Field correction for Hy adjacent to TFSF boundary
        if directional_source
            hy[50] -= exp(-(qTime - 30.) * (qTime - 30.) / 100.) / imp0
        end

        # Absorbing Boundary Condition on left side
        ez[1] = ez[2]

        # update electric field
        for m = 2:spatial_size
            ez[m] = ez[m] + (hy[m] - hy[m - 1]) * imp0 / er[m]
        end

        # Directional source
        # Total-Field/Scattered-Field correction for Ez adjacent to TFSF boundary
        if directional_source
            ez[51] += exp(-(qTime + 0.5 - (-0.5) - 30.) *
                           (qTime + 0.5 - (-0.5) - 30.) / 100.)
        end

        # Hardwire source on a node
        if hard_source
            ez[0] = exp(-(qTime - 30.0) * (qTime - 30.0) / 100.0)
        end

        # Additive source on a node
        if additive_source
            ez[50] += exp(-(qTime - 30.0) * (qTime - 30.0) / 100.0)
        end

        # add a point (0D) probe over time
        probe0Dt[qTime] = ez[50]

        # add a line (1D) probe over time
        probe1Dt[:, qTime] = ez
    end

    return probe0Dt, probe1Dt
end

end # module
