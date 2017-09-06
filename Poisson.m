function prob = Poisson( x, ~, lambda )
    try
        prob = exp( -lambda ) * ( lambda .^ x ./ factorial( x ) );
    catch err   
        error( err.message )
    end
end