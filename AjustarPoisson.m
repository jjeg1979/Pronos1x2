function [ media, chi, phi ] = AjustarPoisson( val, freq )
    phi = 0;
    goles = val( : ) .* freq( : );
    media = sum( goles ) / sum( freq );
    predProb = Poisson( val, [], media );
    predVal  = predProb * sum( freq );
    chiTest = ( freq - predVal ) .^ 2 ./ predVal;
    chi = sum( chiTest );
    media = { media };
end