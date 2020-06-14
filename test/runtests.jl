using uFDTD
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

function smoke_test()
    include("../src/main.jl")
end

smoke_test()
