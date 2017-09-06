function prob = BinomialNegativa( val, freq, ~ )
    %% Calculate parameter p
    media = sum( freq( : ) .* val( : ) ) / sum( freq );
    varianza = sum ( freq .* ( val - media ) .^ 2 ) / sum( freq );
    k = media ^ 2 / ( varianza - media );
    p = k * media;
    prob = zeros( numel( val ), 1 );
    prob( 1 ) = ( k / ( k + 1 ) ) ^ p;
    prob( 2 ) = prob( 1 ) * p / ( k + 1 );
    for cont = 3 : numel( val ) 
        prob( cont ) = prob( 1 ) * prod(  p : 1 : p + cont - 2 ) ...
            / ( factorial( cont - 1 ) * ( k + 1 ) ^ ( cont - 1 ) );
    end
    
    %% Make sum of prob equal to 1
    % Share among the lower values according to its probability
    defecto = 1 - sum( prob );
    prob( 1 : end - 1 ) = defecto * prob( 1 : end - 1 ) / sum( prob( 1 : end - 1 ) ) + prob( 1 : end - 1 );
end