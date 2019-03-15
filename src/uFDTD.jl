module uFDTD

function main(hard_source=false, additive_source=false, directional_source=true)
    spatial_size = 200
    maxTime = 250*4
    # ε0 = 8.85418782e-12  # permittivity of free space [F/m] (F=Farad)
    # ε = εr * ε0
    # Permittivity is a constant of proportionality between electric displacement
    # and electric field intensity in a given medium.
    # force = charge * electric field
    # F     = Q      * E
    # Electric flux density D = εr * ε0 * E
    # ∇ × E = 0 : Curl of electric field (∇ is the del or nabla operator)
    # (∇f is a vector field of the df/dx df/dy etc...)
    # (∇ × E is a vector field representing rotational displacement)
    # ∇ · D = ρv : Divergence of electric flux density
    # (a scalar measure of strength of source or sink)
    # (ρv: electric charge density [C/m3])

    # µ0 = 4π * 1e-7 [H/m]  # permeability of free space
    # µ = µr * µ0
    # speed of light in free space: c = 1 / sqrt(ε0 * µ0)
    # Characteristic impedance of free space: η0 = sqrt(µ0 / ε0)
    imp0 = 377.0
    # Energy must no be able to propagate further than 1 spacial step: cΔt <= Δx
    # Courant number: Sc = c * Δt / Δx (we set it to 1)

    ez = zeros(Float64, spatial_size)  # z component of E field at a time step
    hy = zeros(Float64, spatial_size)  # y component of H field at a time step

    er = zeros(Float64, spatial_size)  # material property: relative permittivity

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

    # Do time stepping, leap-frog method (update H then E)
    for qTime = 1:maxTime

        # Absorbing Boundary Condition on right side (works only when local Sc=1)
        hy[spatial_size] = hy[spatial_size-1]

        # Advance/update the Magnetic field
        for m = 1:spatial_size-1
            # in 1D:  µ * dH/dt = dE/dx  (continuous version)
            #   µ * (H[q+1/2] - H[q-1/2]) / Δt = (E[m+1] - E[m]) / Δx  (discrete version)
            #   H[q+1/2] = H[q-1/2] + (E[m+1] - E[m]) * Δt / µΔx
            hy[m] = hy[m] + (ez[m + 1] - ez[m]) / imp0
        end

        # Directional source
        # Total-Field/Scattered-Field correction for Hy adjacent to TFSF boundary
        if directional_source
            hy[50] -= exp(-(qTime - 30.) * (qTime - 30.) / 100.) / imp0
        end

        # Absorbing Boundary Condition on left side
        ez[1] = ez[2]

        # Advance/update the Electric field
        for m = 2:spatial_size
            # in 1D:  ε * dE/dt = dH/dx  (continuous version)
            #   ε * (E[q+1] - E[q]) / Δt = (H[m+1/2] - H[m-1/2]) / Δx  (discrete version)
            #   E[q+1] = E[q] + (H[m+1/2] - H[m-1/2]) * Δt / εΔx
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
