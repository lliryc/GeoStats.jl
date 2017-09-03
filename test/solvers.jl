@testset "Solvers" begin
  grid = RegularGrid{Float64}(100,100)

  @testset "Kriging" begin
    problem = EstimationProblem(data2D, grid, :value)
    solver = Kriging(:value => @NT(variogram=GaussianVariogram(range=20.)))

    solution = solve(problem, solver)

    # basic checks
    result = digest(solution)
    @test Set(keys(result)) == Set([:value])
    # TODO: check why the accuracy is low (≈ 1e-1)
    @test isapprox(result[:value][:mean][25,25], 1., atol=1e-1)
    @test isapprox(result[:value][:mean][50,75], 0., atol=1e-1)
    @test isapprox(result[:value][:mean][75,50], 1., atol=1e-1)

    if ismaintainer || istravis
      @testset "Plot recipe" begin
        function plot_solution(fname)
          plot(solution, size=(800,400))
          png(fname)
        end
        refimg = joinpath(datadir,"KrigingSolution.png")
        @test test_images(VisualTest(plot_solution, refimg), popup=!istravis) |> success
      end
    end
  end

  @testset "SeqGaussSim" begin
    # conditional simulation with SeqGaussSim
    problem = SimulationProblem(data2D, grid, :value, 1)
    solver = SeqGaussSim(:value => @NT(variogram=GaussianVariogram(range=20.)))
    solution = solve(problem, solver)

    # basic checks
    result = digest(solution)
    @test Set(keys(result)) == Set([:value])
    @test result[:value][1][25,25] == 1.
    @test result[:value][1][50,75] == 0.
    @test result[:value][1][75,50] == 1.

    # unconditional simulation with SeqGaussSim
    problem = SimulationProblem(grid, :value => Float64, 1)
    #solution = solve(problem, SeqGaussSim())
    # TODO: test solution correctness
  end
end
