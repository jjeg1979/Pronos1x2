function [ media, chi, phi ] = AjustarZIP( val, freq )
    %% Step 1. Calculate relative frequency
    val = 0 : 1 : ( numel( val ) - 1 );
    relativeFrequency = freq / sum( freq );
    %% Step 2. For the relative frequecies we need seed values for phi and media
    %phi = 0.5;
    %media = 2;
    % Calculate the theoretical probability as per ZIP distribution
    %theoreticalProbability = ~val .* ( 1 - phi ) + phi * exp( -media ) * media .^ val ./ factorial( val );
    %% Step 3. Calculate the frequency weight
    frequencyWeights = 1 ./ ( relativeFrequency .* ( 1 - relativeFrequency ) );
    frequencyWeights( isinf( frequencyWeights ) ) = 0;    % Replace NaN in frequencyWeights
    %% Step 4. Calculate the squared deviations
    % squaredDeviations = ( relativeFrequency - theoreticalProbability ) .^ 2;
    %% Step 5. Calculate the weighted squared deviations
    % weightedSquaredDeviations = freq .* frecuencyWeights .* squaredDeviations;
    %% Step 6. Establish the objective function to be minimized
    ZIP = @( x ) ~val .* ( 1 - x( 1 ) ) + x( 1 ) * exp( -x( 2 ) ) * x( 2 ) .^ val ./ factorial( val );
    fun = @( x ) sum ( freq .* frequencyWeights .* ...
        ( relativeFrequency - ( ~val .* ( 1 - x( 1 ) ) + x( 1 ) * exp( -x( 2 ) ) * x( 2 ) .^ val ./ factorial( val ) ) ).^ 2  );
    %% Step 7. Minimize the objective function subjected to the restrictions, i.e. phi between 0 and
    %  1 and lambda greater than cero
    ub = [ 1, Inf ];    
    lb = [ 0, 0 ];
    options = optimoptions( 'fmincon', 'Display', 'off', 'Algorithm', 'sqp' );
    [ x, ~ ] = fmincon( fun, [ 0.5, 2 ], [], [], [], [], lb, ub, [], options );
    phi = x( 1 );
    media = x( 2 );
    %% Calculating predicted probability goals once phi and lambda (media) are estimated
    predictedProb = ZIP( x );
    predictedValues = predictedProb * sum( freq );
    chiTest = ( freq - predictedValues ) .^ 2 ./ predictedValues;
    chi = sum( chiTest );
    media = { x( 1 ), media };
end