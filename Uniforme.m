function prob = Uniforme( val, ~, x )
    if numel( x ) == 2    
        width = x( 2 ) - x( 1 ) + 1;
        prob = ( val <= x( 2 ) ) * 1 / width;
    else
        prob = ( val < x ) * 1 / x;
    end
end