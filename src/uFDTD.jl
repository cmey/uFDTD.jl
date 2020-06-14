module uFDTD

using Parameters

export uFDTDParameters

"""
    uFDTDParameters

    Configuration for the simulation.
"""
@with_kw struct uFDTDParameters
    # Spatial grid size.
    spatial_size::Int = 200  # [cells] square
    # Max time evolution.
    max_time_steps::Int = 250*4  # [steps]
end

"""
    simulate(sim_params::uFDTDParameters, hard_source=false, additive_source=false, directional_source=true)

    Run the simulation.
"""
function simulate(sim_params::uFDTDParameters, hard_source=false, additive_source=false, directional_source=true)
    @unpack spatial_size, max_time_steps = sim_params

    ε0 = 8.85418782e-12  # permittivity of free space [F/m] (F=Farad)
    # ε = εr * ε0
    # Permittivity is a constant of proportionality between electric displacement
    # and electric field intensity in a given medium.
    # force = charge * electric field
    # F     = Q      * E
    # ∇ × E = 0 : Curl of electric field (∇ is the del or nabla operator)
    # (∇f is a vector field of the df/dx df/dy etc...)
    # (∇ × E is a vector field representing rotational displacement)
    # Electric flux density D = ε * E
    # ∇ · D = ρv : Divergence of electric flux density
    # (ρv: electric charge density [C/m3])
    # (a scalar measure of strength of source or sink)
    # E = D/e = −∇V
    # ∇²V = −ρ/e
    # Electrical conductivity: σ
    # Perfect electric conductors (PECs) have σ close to infinity
    # Current density J = σE (current in material, charges moving due to E field)
    # Charge Q moving at speed v in field B (magnetic flux density):
    # force = charge * speed cross-product magnetic flux density
    # F = Q * (v × B)
    # Magnetic Field H = B / µ (ignore local effect of material on flux):
    # B = μrμ0H = μH    (relative permeability and permeability of free space)
    µ0 = 4π * 1e-7  # permeability of free space [H/m] (H=Henry)
    # µ = µr * µ0
    η0 = sqrt(µ0 / ε0)  # Characteristic impedance of free space = ~ 377.0
    c = 1 / sqrt(ε0 * µ0)  # speed of light in free space [m/s]
    # Energy must no be able to propagate further than 1 spacial step: cΔt <= Δx
    Sc = 1  # Sc = c * Δt / Δx Courant number (we set it to 1, for now)
    # More generally: Δt must be <= 1/(c*sqrt(1/Δx^2 + 1/Δy^2 + 1/Δz^2))

    # Excitation function used in hard source and additive source
    peak_time = 30.0
    pulse_width = 10
    gaussian_pulse(t) = exp(-((t - peak_time) / pulse_width)^2)

    source_function = gaussian_pulse

    ez = zeros(Float64, spatial_size)  # z component of E field at a time step
    hy = zeros(Float64, spatial_size)  # y component of H field at a time step

    # setup material property (Elec): relative permittivity
    εr = zeros(Float64, spatial_size)
    εr_boundary_position = 100
    εr_material_value = 9
    for m = 1:spatial_size
        if m < εr_boundary_position
            εr[m] = 1.0
        else
            εr[m] = εr_material_value
        end
    end

    # setup material property (Mag): relative permeability
    µr = zeros(Float64, spatial_size)
    µr_material_value = 1
    for m = 1:spatial_size
        µr[m] = µr_material_value
    end

    probe0Dt = zeros(Float64, max_time_steps)
    probe1Dt = zeros(Float64, (spatial_size, max_time_steps))

    # Do time stepping, leap-frog method (update H then E)
    for qTime = 1:max_time_steps

        # Absorbing Boundary Condition on right side (works only when local Sc=1)
        hy[spatial_size] = hy[spatial_size-1]

        # Advance/update the Magnetic field
        for m = 1:spatial_size-1
            # in 1D:  µ * dH/dt = dE/dx  (continuous version)
            #   µ * (H[q+1/2] - H[q-1/2]) / Δt = (E[m+1] - E[m]) / Δx  (discrete version)
            #   H[q+1/2] = H[q-1/2] + (E[m+1] - E[m]) * Δt / µΔx
            hy[m] = hy[m] + (ez[m + 1] - ez[m]) * Sc / η0 / µr[m]
        end

        # Directional source
        # Total-Field/Scattered-Field correction for Hy adjacent to TFSF boundary
        if directional_source
            hy[50] -= source_function(qTime) / η0
        end

        # Absorbing Boundary Condition on left side
        ez[1] = ez[2]

        # Advance/update the Electric field
        for m = 2:spatial_size
            # in 1D:  ε * dE/dt = dH/dx  (continuous version)
            #   ε * (E[q+1] - E[q]) / Δt = (H[m+1/2] - H[m-1/2]) / Δx  (discrete version)
            #   E[q+1] = E[q] + (H[m+1/2] - H[m-1/2]) * Δt / εΔx
            ez[m] = ez[m] + (hy[m] - hy[m - 1]) * Sc * η0 / εr[m]
        end

        # Directional source
        # Total-Field/Scattered-Field correction for Ez adjacent to TFSF boundary
        if directional_source
            ez[51] += exp(-(qTime + 0.5 - (-0.5) - 30.) *
                           (qTime + 0.5 - (-0.5) - 30.) / 100.)
        end

        # Hardwire source on a node
        if hard_source
            ez[0] = source_function(qTime)
        end

        # Additive source on a node
        if additive_source
            ez[50] += source_function(qTime)
        end

        # add a point (0D) probe over time
        probe0Dt[qTime] = ez[50]

        # add a line (1D) probe over time
        probe1Dt[:, qTime] = ez
    end

    return probe0Dt, probe1Dt
end

end # module
