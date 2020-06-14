using uFDTD


function main()
    # Define simulation parameters (use many default values, see uFDTDParameters).
    sim_params = uFDTDParameters()

    # Run simulation.
    p0, p1 = uFDTD.simulate(sim_params)
end


main()
