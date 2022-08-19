"""
Intermediate representation (IR) for many-body propagators.
"""
module SparseIR

export Fermionic, Bosonic
export MatsubaraFreq, BosonicFreq, FermionicFreq, pioverbeta
export FiniteTempBasis, FiniteTempBasisSet
export SparsePoleRepresentation
export overlap
export LogisticKernel, RegularizedBoseKernel
export AugmentedBasis, TauConst, TauLinear, MatsubaraConst
export TauSampling, MatsubaraSampling, evaluate, fit, evaluate!, fit!,
       MatsubaraSampling64F, MatsubaraSampling64B, TauSampling64

using MultiFloats: Float64x2
using LinearAlgebra: LinearAlgebra, cond, dot, svd, SVD, QRIteration, mul!
using LinearAlgebra.BLAS: gemm!
using QuadGK: gauss, kronrod, quadgk
using Bessels: sphericalbesselj

Base.sinh(x::Float64x2) = setprecision(() -> Float64x2(sinh(big(x))), precision(Float64x2))
Base.cosh(x::Float64x2) = setprecision(() -> Float64x2(cosh(big(x))), precision(Float64x2))
# FIXME: remove if MultiFloats is fixed
Base.Math.hypot(x::Float64x2, y::Float64x2) = Base.Math._hypot(x, y)

include("_linalg.jl")
include("_roots.jl")
include("_specfuncs.jl")
using ._LinAlg: tsvd

include("freq.jl")
include("abstract.jl")
include("svd.jl")
include("gauss.jl")
include("poly.jl")
include("kernel.jl")
include("sve.jl")
include("basis.jl")
include("augment.jl")
include("sampling.jl")
include("spr.jl")
include("basis_set.jl")

# Precompile
precompile(FiniteTempBasis, (Statistics, Float64, Float64, Float64))
for cls in [:TauSampling, :MatsubaraSampling]
    for func in [:fit, :evaluate]
        for vartype in [:Float64, :ComplexF64]
            for dim in [:1, :2, :3, :4, :5, :6, :7]
                @eval precompile($(func), ($(cls), Array{$(vartype),$(dim)}))
            end
        end
    end
end

end # module
