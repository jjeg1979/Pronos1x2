function prob = ZIP( val, ~, x )
    prob = ~val .* ( 1 - x( 1 ) ) + x( 1 ) * exp( -x( 2 ) ) * x( 2 ) .^ val ./ factorial( val );
    %% Make sum of prob equal to 1. 
    % Share proportional to probability except for the possible outliers
    defecto = 1 - sum( prob );
    prob( 1 : end - 1 ) = defecto * prob( 1 : end - 1 ) / sum( prob( 1 : end - 1 ) ) + prob( 1 : end - 1 );
end