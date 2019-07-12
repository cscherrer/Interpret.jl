module Interpret

using MLStyle

function interpret(expr)
    ctx = Dict{Symbol, Any}()
    interpret!(ctx, expr)
end

function interpret!(ctx , s::Symbol)
    # We'd use `get` for this, but `eval(s)` needs to be lazy
    haskey(ctx, s) && return ctx[s]
    eval(s)
end

interpret!(ctx, ::LineNumberNode) = nothing
interpret!(ctx, n::Number) = n
interpret!(ctx , x) = x

function interpret!(ctx, expr:: Expr)
    # @show ctx, expr
    r(x) = interpret!(ctx,x)

    result = @match expr begin
        Expr(:block, xs...) => for x∈xs r(x) end
        :($f($(args...)))   => r(f)(map(r,args)...)
        :($f($x,$y))        => r(f)(r(x),r(y))
        :($k = $v)          => (ctx[k] = r(v))
        :(return $x)        => (return x)
        x                   => error("Not yet implemented")
    end

    return result
end



end # module
