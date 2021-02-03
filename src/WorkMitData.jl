module WorkMitData

using Dates
using Random
using DataFrames
using Statistics

export 
	lag,
	lead,
	dttodate,
	dttodate!,
	stdze,
	rescale,
	intck


include("extra_fun.jl")
# Write your package code here.

end
