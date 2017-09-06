function [ media, chi, phi ] = AjustarBinomialNegativa( val, freq )
    try
        phi = 0;
        k = zeros( 3, 1 );
        %% Step 1: Calculate the mean 
        media = sum( freq .* val ) / sum( freq );
        %% Step 2: Calculate the variance
        variance = sum( freq .* ( val - media ) .^ 2 ) / sum( freq );
        %% Step 3: Calculate the dispersion parameters
        k( 1, 1 ) = media ^ 2 / ( variance - media );
        %% Step 4: Calculate the predicted probability values
        predProb = BinomialNegativa( val, freq, k( 1, 1 ) );
        %% Step 5: Calculate the predicted values
        predVal = predProb * sum( freq );
        %% Step 6: Calculate the Chi-Square statistic
        chiTest = ( freq( : ) - predVal( : ) ) .^ 2 ./ predVal( : );
        chi1 = sum( chiTest );
        %% Step 7: Calculate the parameters via the enhanced methods of moments
        k( 2, 1 ) = ( media ^ 2 - variance / sum( freq ) ) / ( variance - media );
        %% Step 8: Calculate the predicted probability values
        predProb = BinomialNegativa( val, freq, k( 2, 1 ) );
        %% Step 9: Calculate the predicted values
        predVal = predProb * sum( freq );
        %% Step 10: Calculate the Chi-Square Statistic
        chiTest = ( freq( : ) - predVal( : ) ) .^ 2 ./ predVal( : );
        chi2 = sum( chiTest );
        %% Step 11: Calculate the minimum squared deviation
        %  Step 11.1 First calculate the relative frequency
        relativeFrequency = freq / sum( freq );
        %  Step 11.2 Calculate the frequency Weight
        frequencyWeights = 1 ./ ( relativeFrequency .* ( 1 - relativeFrequency ) );
        frequencyWeights( isinf( frequencyWeights ) ) = 0;
        %  Step 11.3 Determine objective function
        fun = @(x) sum( freq .* frequencyWeights .* ...
            ( relativeFrequency - BinomialNegativa( val, freq, x )' ).^ 2  );
        %  Step 11.4 Set up the minimization problem
        options = optimoptions( 'fmincon', 'Display', 'off', 'Algorithm', 'sqp' );
        [ x, ~ ] = fmincon( fun, k( 1, 1 ), [], [], [], [], 0, Inf, [], options );
        k( 3, 1 ) = x;
        %  Step 11.5 Calculate the predicted Probabilities
        predProb = BinomialNegativa( val, freq, x );
        %  Step 11.6 Calculate the predicted values
        predVal = predProb * sum( freq );
        %  Step 11.7 Chi-Test
        chiTest = ( freq( : ) - predVal( : ) ) .^ 2 ./ predVal( : );
        chi3 = sum( chiTest );
        %% Step 12. Evaluate the output values
        [ chi, idx ] = min( [ chi1, chi2, chi3 ] );
        media = { k( idx, 1 ) };
    catch
        media = Inf;
        chi = Inf;
        phi = Inf;        
    end
end