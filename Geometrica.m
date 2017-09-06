function prob = Geometrica( val, ~, p )
    prob = p * ( 1 - p ) .^ val;
end