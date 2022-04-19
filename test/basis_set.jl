using Test
using SparseIR

@testset "basis.jl" begin
    @testset "consistency" begin
        β = 2.0
        wmax = 5.0
        ε = 1e-5

        sve_result = sve_logistic[β * wmax]
        basis_f, basis_b = finite_temp_bases(β, wmax, ε, sve_result)
        smpl_τ_f = TauSampling(basis_f)
        smpl_τ_b = TauSampling(basis_b)
        smpl_wn_f = MatsubaraSampling(basis_f)
        smpl_wn_b = MatsubaraSampling(basis_b)

        bs = FiniteTempBasisSet(β, wmax, ε; sve_result)
        @test smpl_τ_f.sampling_points == smpl_τ_b.sampling_points
        @test bs.smpl_tau_f.matrix == smpl_τ_f.matrix
        @test bs.smpl_tau_b.matrix == smpl_τ_b.matrix

        @test bs.smpl_wn_f.matrix == smpl_wn_f.matrix
        @test bs.smpl_wn_b.matrix == smpl_wn_b.matrix
    end
end
