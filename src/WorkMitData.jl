module WorkMitData

using Dates
using Random
using DataFrames
using Statistics
using StatsBase

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
# Write your package code here.

end
