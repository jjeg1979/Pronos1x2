function [ media, chi, phi ] = AjustarUniforme( val, freq )
    phi = 0;
    %% Step 1. Calculate average
    media = sum( val .* freq ) / sum( freq );
    %% Step 2. Calculate parameters of Uniform distribution
    b = ceil( 2 * media );
    if b >= numel( val )
        b = numel( val ) - 1;
    end
    a = 0;
    x = [ a b ];
    %% Step 3. Calculate predicted probability
    predProb = Uniforme( val, [], x );
    %% Step 4. Calculate predicted values
    predVal = predProb * sum( freq );
    %% Step 5. Chi-Square Test
    chiTest = ( predVal - freq ) .^ 2 ./ predVal;
    chiTest( isinf( chiTest ) ) = 0;
    chiTest( isnan( chiTest ) ) = 0;
    %% Step 6. chi Value
    chi = sum( chiTest );
    media = { b - a + 1 };
end