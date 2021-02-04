"""
intck(x,y) computes the difference between two date objects and return number of day. Any of x and y can be missing value.
"""
intck(x::Missing,y::Missing) = missing
intck(x::Missing,y) = missing
intck(x,y::Missing) = missing
intck(x::Date,y::Date) = (x-y).value

"""
rescale(x,minx,maxx,minval,maxval) rescales x to run from minval and maxval, given x originaly runs from minx to maxx.
"""
function rescale(x,minx,maxx,minval,maxval)
    -(-maxx*minval+minx*maxval)/(maxx-minx)+(-minval+maxval)*x/(maxx-minx)
end
rescale(x::Missing,minx,maxx,minval,maxval) = missing
rescale(x::Vector,minx,maxx,minval,maxval) = rescale.(x,minx,maxx,minval,maxval)
rescale(x,minx,maxx) = rescale(x,minx,maxx,0.0,1.0)

"""
stdze(x) standardizes an array. It return missing for missing data points.
"""
function stdze(x)
    all(ismissing,x) && return x
    meandata = mean(skipmissing(x))
    vardata = var(skipmissing(x))
    (x .- meandata) ./ sqrt(vardata)
end



"""
lag(x,k) Creates a lag-k of the provided array x. The output will be an array the
same size as x (the input array), and the its type will be Union{Missing, T} where T is the type of input.
"""
function lag(x,k)
    res=zeros(Union{typeof(x[1]),Missing},length(x))
    for i in 1:k
        res[i] = missing
    end
    for i in k+1:length(x)
        res[i] = x[i-k]
    end
    res
end

lag(x)=lag(x,1)

"""
lead(x,k) Creates a lead-k of the provided array x. The output will be an array the
same size as x (the input array), and the its type will be Union{Missing, T} where T is the type of input.
"""
function lead(x,k)
    res=zeros(Union{typeof(x[1]),Missing},length(x))
    for i in 1:length(x)-k
        res[i] = x[i+k]
    end
    for i in length(x)-k+1:length(x)
        res[i] = missing
    end
    res
end
lead(x)=lead(x,1)

"""
dttodate(x) converts SAS or STATA dates (which is the number of days after 01-01-1960) to a Julia Date object.
dttodate(DataFrame,cols) converts the given columns to Date object.
"""
dttodate(x::Missing) = missing
dttodate(x) = Date(1960,1,1)+Day(x)
dttodate(x::Date) = x
function dttodate!(df::DataFrame,cols)
    for i in cols
        df[!,i] = dttodate.(df[!,i])
    end
end

# modifying some Base functions to suit for working with data with missing values

Base.maximum(x::AbstractArray{Missing,1})=missing
function Base.maximum(x::AbstractArray{Union{T,Missing},1}) where {T <: Number}
    res=typemin(T)
    cnt_miss=0
    for i in 1:length(x)
        if !ismissing(x[i])
            if x[i]>res
                res=x[i]
            end
        else
            cnt_miss+=1
        end
    end
    if cnt_miss==length(x)
        res=missing
    end
    res
end

Base.minimum(x::AbstractArray{Missing,1})=missing
function Base.minimum(x::AbstractArray{Union{T,Missing},1}) where {T <: Number}
    res=typemax(T)
    cnt_miss=0
    for i in 1:length(x)
        if !ismissing(x[i])
            if res>x[i]
                res=x[i]
            end
        else
            cnt_miss+=1
        end
    end
    if cnt_miss==length(x)
        res=missing
    end
    res
end

Base.sum(x::AbstractArray{Missing,1})=missing
function Base.sum(x::AbstractArray{Union{T,Missing},1}) where {T <: Number}
    res=zero(T)
    cnt_miss=0
    for i in 1:length(x)
        if !ismissing(x[i])
            res+=x[i]
        else
            cnt_miss+=1
        end
    end
    if cnt_miss==length(x)
        res=missing
    end
    res
end

Statistics.mean(x::AbstractArray{Missing,1})=missing
function Statistics.mean(x::AbstractArray{Union{T,Missing},1}) where {T <: Number}
    res=0.0
    cnt_nonmiss=0
    for i in 1:length(x)
        if !ismissing(x[i])
            res+=x[i]
            cnt_nonmiss+=1
        end
    end
    if cnt_nonmiss>0
        res=res/cnt_nonmiss
    else
        res=missing
    end
    res
end

Statistics.var(x::AbstractArray{Missing,1},df=true)=missing
function Statistics.var(x::AbstractArray{Union{T,Missing},1},df=true) where {T <: Number}
    res=0.0
    ss=0.0
    sval=0.0
    cnt_nonmiss=0
    for i in 1:length(x)
        if !ismissing(x[i])
            sval+=x[i]
            ss+=x[i] * x[i]
            cnt_nonmiss+=1
        end
    end
    if cnt_nonmiss>1
        res=ss/cnt_nonmiss - (sval/cnt_nonmiss)*(sval/cnt_nonmiss)
        if df
            res=(cnt_nonmiss/(cnt_nonmiss-1))*res
        end
    elseif cnt_nonmiss==1
        res=0.0
    else
        res=missing
    end
    res
end
Statistics.std(x::AbstractArray{Missing,1},df=true)=missing
function Statistics.std(x::AbstractArray{Union{T,Missing},1},df=true) where {T <: Number}
    sqrt(var(x,df))
end


function Statistics.median(v::AbstractArray{T,1}) where T
    isempty(v) && throw(ArgumentError("median of an empty array is undefined, $(repr(v))"))
    eltype(v)>:Missing && all(ismissing, v) && return missing
    (eltype(v)<:AbstractFloat || eltype(v)>:AbstractFloat) && any(isnan, v) && return convert(eltype(v), NaN)
    any(ismissing,v) ? v2=collect(skipmissing(v)) : v2=v
    inds = axes(v2, 1)
    n = length(inds)
    mid = div(first(inds)+last(inds),2)
    if isodd(n)
        return middle(partialsort!(v2,mid))
    else
        m = partialsort!(v2, mid:mid+1)
        return middle(m[1], m[2])
    end
end

function Statistics.quantile(x::Array{T,1},v) where T
    all(ismissing,x) && return missing
    quantile(skipmissing(x),v)
end

