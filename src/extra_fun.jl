"""
lag(x,k) Creates a lag-k of the provided array x. The output will be an array the
same size as x (the input array), and the its type will be Union{Missing, T} where T is the type of input.
"""
function lag(x,k)
    res=zeros(Union{typeof(x[1]),Missing},length(x))
    for i in 1:k
        res[i]=missing
    end
    for i in k+1:length(x)
        res[i]=x[i-k]
    end
    res
end

"""
lead(x,k) Creates a lead-k of the provided array x. The output will be an array the
same size as x (the input array), and the its type will be Union{Missing, T} where T is the type of input.
"""
function lead(x,k)
    res=zeros(Union{typeof(x[1]),Missing},length(x))
    for i in 1:length(x)-k
        res[i]=x[i+k]
    end
    for i in length(x)-k+1:length(x)
        res[i]=missing
    end
    res
end

"""
dttodate(x) converts SAS or STATA dates (which is the number of day after 1-1-1960) to a Julia Date object.
dttodate(DataFrame,cols) converts the given columns to Date object.
"""
dttodate(x::Missing)=missing
dttodate(x::Int16)=Date(1960,1,1)+Day(x)
dttodate(x::Date)=x
function dttodate!(df::DataFrame,cols)
    for i in cols
        df[!,i]=dttodate.(df[!,i])
    end
end