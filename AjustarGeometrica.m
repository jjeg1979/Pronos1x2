function [ media, chi, phi ] = AjustarGeometrica( val, freq )
    phi = 0;
    %% Step 1. Calculate mean
    media = sum( val .* freq ) / sum( freq );
    %% Step 2. Calculate parameter p
    p = 1 / ( 1 + media );
    %% Step 3. Predicted probability
    predProb = Geometrica( val, [], p );
    %% Step 4. Predicted Values
    predVal = predProb * sum( freq );
    %% Step 5. Chi-Square Test
    chiTest = ( predVal - freq ) .^ 2 ./ predVal;
    %% Step 6. chi
    chi = sum( chiTest );
    media = { p };    
end