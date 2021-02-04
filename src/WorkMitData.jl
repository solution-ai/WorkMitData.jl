module WorkMitData


using Reexport
using Dates
using Random
@reexport using DataFrames
using Statistics
@reexport using StatsBase

export 
	lag,
	lead,
	dttodate,
	dttodate!,
	stdze,
	rescale,
	intck,
	maximum,
	minimum,
	sum,
	mean,
	var,
	std,
	median,
	quantile


include("extra_fun.jl")

end
