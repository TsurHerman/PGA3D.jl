module PGA3D
include("util.jl")
include("types.jl")
include("show.jl")
include("arithmetic.jl")
include("products.jl")



export wedge
const ∧ = wedge
export ∧

greet() = print("Hello World!")

end # module
