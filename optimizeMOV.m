function errorSquared = optimizeMOV( Partidos, x )
    % First find index for Equipo
    [ uniqueLocal, ~, indicesLocales ] = unique( Partidos.Local );
    [ uniqueVisitantes, ~, indicesVisitantes ] = unique( Partidos.Visitante );
    if ( uniqueLocal ~= uniqueVisitantes )
        error( 'Matlab::optimizeMOV::TeamMispelling', 'Teams are not the same in Local and Away Rows' );        
    end
    indicesLocales = indicesLocales + 1;
    indicesVisitantes = indicesVisitantes + 1;
    homeRating = x( indicesLocales );
    awayRating = x( indicesVisitantes );
    predictedMOV = marginofvictory( x( 1 ), homeRating, awayRating );
    errorSquared = sum( ( predictedMOV( : ) - Partidos.ActualMOV( : ) ) .^ 2 );    
end % function errorSquared = optimizeMOV( Partidos, Equipos, x )