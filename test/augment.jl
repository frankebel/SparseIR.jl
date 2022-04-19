using Test
using SparseIR

@testset "augment.jl" begin
    @testset "LegendreBasis" begin
        for stat in [fermion, boson]
            β = 1.0
            Nl = 10
            cl = sqrt.(2 * collect(0:(Nl - 1)) .+ 1)
            basis = SparseIR.LegendreBasis(stat, β, Nl; cl=cl)

            τ = Float64[0, 0.1 * β, 0.4 * β, β]
            uval = basis.u(τ)

            ref = Matrix{Float64}(undef, Nl, length(τ))
            for l in 0:(Nl - 1)
                x = 2τ / β .- 1
                ref[l + 1, :] .= cl[l + 1] * (√(2l + 1) / β) * SparseIR.legendreP.(l, x)
            end
            @test uval ≈ ref

            sign = stat == fermion ? -1 : 1

            # G(iv) = 1/(iv-pole)
            # G(τ) = -e^{-τ*pole}/(1 + e^{-β*pole}) [F]
            #        = -e^{-τ*pole}/(1 - e^{-β*pole}) [B]
            pole = 1.0
            τ_smpl = TauSampling(basis)
            gτ = -exp.(-τ_smpl.sampling_points * pole) / (1 - sign * exp(-β * pole))
            gl_from_τ = fit(τ_smpl, gτ)

            matsu_smpl = MatsubaraSampling(basis)
            giv = 1 ./ ((im * π / β) * matsu_smpl.sampling_points .- pole)
            gl_from_matsu = fit(matsu_smpl, giv)

            #println(maximum(abs.(gl_from_τ-gl_from_matsu)))
            #println(maximum(abs.(gl_from_τ)))
            #println("gl_from_τ", gl_from_τ[1:4])
            #println("gl_from_matsu", gl_from_matsu[1:4])
            @test isapprox(gl_from_τ, gl_from_matsu;
                           atol=1e-10 * maximum(abs, gl_from_matsu), rtol=0)
        end
    end
end
