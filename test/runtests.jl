using uFDTD
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

function smoke_test()
    # run a simulation
    p0, p1 = uFDTD.main()
end

smoke_test()
