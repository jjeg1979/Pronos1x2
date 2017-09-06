function Estadisticas = crearEstadisticas( Resultados )
% Estadisticas = crearEstadisticas( Resultados )

    %% Get the fieldnames (to match with Estadisticas)
    tablas = fieldnames( Resultados );
    
    pooledGoals = 5;    % Maximum number of goals per match
    
    %% Generate statistics per match
    
    for tabla = 1 : numel( tablas )
        % Create teams' list
        Equipos = sort( unique( Resultados.( tablas{ tabla } ).Locales ) );
        % Create table for output
        FrecuenciaGoles = table;
        FrecuenciaGolesPooled = table;
        FrecuenciaGoles.Equipo = Equipos;
        FrecuenciaGolesPooled.Equipo = Equipos;
        % Up to how many goals to count
        maxGoals = max([ max( Resultados.( tablas{ tabla } ).GolesLocal ) ...
            max( Resultados.( tablas{ tabla } ).GolesVisitante ) ] );
        Nombres = cell( maxGoals, 1 );
        goles = 0 : 1 : maxGoals;
        for nombre = 1 : numel( goles )
            Nombres{ nombre } = [ 'Goles_' num2str( goles( nombre ) ) ];
        end % nombre = 1 : numel( goles )

        Resul = zeros( numel( Equipos ), numel( goles ) );
        % Fill up matches result
        for equipo = 1 : numel(Equipos)
            for gol = 1 : numel( goles )
                Resul( equipo, gol ) = ...
                    sum( Resultados.( tablas{ tabla } ).GolesLocal( Resultados.( tablas{ tabla } ).Locales == ...
                    Equipos( equipo ) ) == goles( gol ) ) + ...
                    sum( Resultados.( tablas{ tabla } ).GolesVisitante( Resultados.( tablas{ tabla } ).Visitantes == ...
                    Equipos( equipo ) ) == goles( gol ) );
            end % gol = 1 : numel( goles )
        end % equipo = 1 : numel(Equipos)
        
        ResulPooled = Resul( :, 1 :  pooledGoals );
        %% Take into account pooled Goals
        ResulPooled( :, pooledGoals + 1 ) = sum( Resul( :, pooledGoals + 1 : end ), 2 ); % Sum goals
       
        % Present results in a coherent way
        for contador = 1 : numel( Nombres )
            FrecuenciaGoles.( Nombres{ contador } ) = Resul( :, contador );
            if contador <= pooledGoals + 1
                FrecuenciaGolesPooled.( Nombres{ contador } ) = ResulPooled( :, contador );
            end
        end % contador = 1 : numel( Nombres )
        
        %% Assign it to the statistics
        Estadisticas.( tablas{ tabla } ) = FrecuenciaGoles;
        Estadisticas.( [ tablas{ tabla } 'Pooled' ] ) = FrecuenciaGolesPooled;
    end % tabla = 1 : numel( tablas )
end % function