%% 
clear, clc;
%% Import the data
nombreLibro = 'Resultados.xlsx';
Resultados = leerResultados( fullfile( pwd, nombreLibro ) );

%% Substitute teams not anymore in the corresponding division
oldTeamsPrimera = { 'Real S. de Gijón', 'C. At. Osasuna', 'Granada C.F.' };
newTeamsPrimera = { 'Levante U.D.', 'Girona F.C.', 'Getafe C.F.' };
oldTeamsSegunda = { 'UCAM Murcia C.F.', 'R.C.D. Mallorca', 'Elche C.F.', 'C.D. Mirandés'  };
newTeamsSegunda = { 'Cultural Leonesa', 'Barcelona B', 'Lorca Deport. C.F.', 'Albacete Balomp.' };

campos = fieldnames( Resultados );
% For first division (upgrade from 2A to 1)
for equipo = 1 : numel( oldTeamsPrimera )
    indiceLocal = strfind( cellstr( Resultados.( campos{ 1 } ).Locales ), oldTeamsPrimera{ equipo } );
    indiceLocal = find( not( cellfun( 'isempty', indiceLocal ) ) );
    Resultados.( campos{ 1 } ).Locales( indiceLocal ) = newTeamsPrimera{ equipo };
    indiceVisitante = strfind( cellstr( Resultados.( campos{ 1 } ).Visitantes ), oldTeamsPrimera{ equipo } );
    indiceVisitante = find( not( cellfun( 'isempty', indiceVisitante ) ) );
    Resultados.( campos{ 1 } ).Visitantes( indiceVisitante ) = newTeamsPrimera{ equipo };
end % for equipo = 1 : numel( oldTeamsPrimera )

% For second division (downgrade 1 to 2A)
for equipo = 1 : numel( newTeamsPrimera )
    indiceLocal = strfind( cellstr( Resultados.( campos{ 2 } ).Locales ), newTeamsPrimera{ equipo } );
    indiceLocal = find( not( cellfun( 'isempty', indiceLocal ) ) );
    Resultados.( campos{ 2 } ).Locales( indiceLocal ) = oldTeamsPrimera{ equipo };
    indiceVisitante = strfind( cellstr( Resultados.( campos{ 2 } ).Visitantes ), newTeamsPrimera{ equipo } );
    indiceVisitante = find( not( cellfun( 'isempty', indiceVisitante ) ) );
    Resultados.( campos{ 2 } ).Visitantes( indiceVisitante ) = oldTeamsPrimera{ equipo };
end % for equipo = 1 : numel( oldTeamsPrimera )
% For second division (upgrade from 2A to 2)
for equipo = 1 : numel( oldTeamsSegunda )
    indiceLocal = strfind( cellstr( Resultados.( campos{ 2 } ).Locales ), oldTeamsSegunda{ equipo } );
    indiceLocal = find( not( cellfun( 'isempty', indiceLocal ) ) );
    Resultados.( campos{ 2 } ).Locales( indiceLocal ) = newTeamsSegunda{ equipo };
    indiceVisitante = strfind( cellstr( Resultados.( campos{ 2 } ).Visitantes ), oldTeamsSegunda{ equipo } );
    indiceVisitante = find( not( cellfun( 'isempty', indiceVisitante ) ) );
    Resultados.( campos{ 2 } ).Visitantes( indiceVisitante ) = newTeamsSegunda{ equipo };
end % for equipo = 1 : numel( oldTeamsSegunda )

%% Proccess the data
Estadisticas = crearEstadisticas( Resultados );
nombreHojas = fieldnames( Estadisticas );

%% Guardamos en un libro Excel ambas
libroSalida = 'EstadisticasGoles.xlsx';

for hoja = 1 : numel( nombreHojas )
    warning off;
    writetable( Estadisticas.( nombreHojas{ hoja } ), libroSalida, 'Sheet', nombreHojas{ hoja } );
end

warning off;

%% Remove unwanted sheets
% Get all sheet names
[ ~, sheets ] = xlsfinfo( libroSalida );
% Make up list of sheets to remove
sheetNames2remove = setdiff( sheets, nombreHojas ); 
% Establish and Excel Object and Open Book
ExcelWorkbook = actxserver( 'Excel.Application' );
ExcelWorkbook.Workbooks.Open( fullfile( pwd, libroSalida ) );
% Delete sheets
try
    for hoja = 1 : numel( sheetNames2remove )
        ExcelWorkbook.Worksheets.Item( sheetNames2remove{ hoja } ).Delete;
    end
catch
    % Do nothing
end
% Save, close and cleanup
ExcelWorkbook.ActiveWorkbook.Save;
ExcelWorkbook.ActiveWorkbook.Close;
ExcelWorkbook.Quit;
ExcelWorkbook.delete;

% Remove teams who have been upgraded to first division
for equipo = 1 : numel( newTeamsPrimera )
    indiceTeam = strfind( cellstr( Estadisticas.SegundaPooled.Equipo ), newTeamsPrimera{ equipo } );
    indiceTeam = find( not( cellfun( 'isempty', indiceTeam ) ) );
    Estadisticas.SegundaPooled( indiceTeam, : ) = [];
end % for equipo = 1 : numel( newTeamsPrimera )

%% Fit distributions to data and see which is best
Ajustes = struct;
Ajustes.PrimeraPooled = table;
Ajustes.SegundaPooled = table;
Ajustes.PrimeraPooled.Equipos = Estadisticas.PrimeraPooled.Equipo;
Ajustes.SegundaPooled.Equipos = Estadisticas.SegundaPooled.Equipo;

campos = fieldnames( Ajustes );
distribuciones = { '@AjustarPoisson', '@AjustarZIP', '@AjustarBinomialNegativa', ...
    '@AjustarGeometrica', '@AjustarUniforme' };
numGoles = 0:1:5;
numGoles = numGoles';

%% Fit distributions
for campo = 1 : numel( campos )
    Goles = Estadisticas.( campos{ campo } ){ :, 2 : end };
    Equipos = Estadisticas.( campos{ campo } ).Equipo;
    Frecuencias = ( Goles' .* numGoles )';
    param.( campos{ campo } ) = cell( numel( Equipos ), numel( distribuciones ) );
    chi    = zeros( numel( Equipos ), numel( distribuciones ) );
    phi    = chi;
    for equipo = 1 : numel( Equipos )
        for distribucion = 1 : numel( distribuciones )
            % Convert one string into a function handle
            fun = str2func( distribuciones{ distribucion } );
            [ param.( campos{ campo } ){ equipo, distribucion }, chi( equipo, distribucion ), phi( equipo, distribucion ) ] = ...
                fun(  numGoles', Goles( equipo, : ) );
        end % for distribucion = 1 : numel( distribuciones )
    end % for equipo = 1 : numel( Ajustes.( fieldname{ campo } ).Equipo )
    chi( chi < 0 ) = Inf;
    [ ~, idx ] = min( chi, [], 2 );
    %% Extract optimum adjustments
    ajustesOptimos = distribuciones( idx )';
    ajustesOptimos = strrep( ajustesOptimos, '@Ajustar', '' );
    Ajustes.( campos{ campo } ).Distribuciones = ajustesOptimos;
    Ajustes.( campos{ campo } ).Frecuencias = Frecuencias;
    Ajustes.( campos{ campo } ).Goles = Goles;
    Ajustes.( campos{ campo } ).idx = idx;
end % for campo = 1 : fieldnames( Ajustes )

%% Made forecast for actual date
% Make up actual matches
% EquiposPrimera = cellstr( Ajustes.PrimeraPooled.Equipos );
% EquiposSegunda = cellstr( Ajustes.SegundaPooled.Equipos );
% Load matches
% load( 'Jornada3.mat' );
Jornada = importarQuiniela( 'Quiniela.xlsx', 'Quiniela', 'A1:B15' );
numGoles = numGoles';
% Calculate probabilities for each team
for campo = 1 : numel( campos )
    Equipos = Ajustes.( campos{ campo } ).Equipos;
    Probabilidades.( campos{ campo } ) = table;
    Probabilidades.( campos{ campo } ).Resultados = zeros( numel( Equipos ), numel( numGoles ) );
    Probabilidades.( campos{ campo } ).Properties.RowNames = cellstr( char( Equipos ) );
    Frecuencias = Ajustes.( campos{ campo } ).Frecuencias;
    idx = Ajustes.( campos{ campo } ).idx;
    for equipo = 1 : numel( Equipos )
        dist = str2func( Ajustes.( campos{ campo } ).Distribuciones{ equipo } );
        Probabilidades.( campos{ campo } ).Resultados( equipo, : ) = ...
            dist( numGoles, Frecuencias( equipo, : ), ...
            cell2mat( param.( campos{ campo } ){ equipo, idx( equipo ) } ) );
    end % for equipo = 1 : numel( Equipos )    
end % for campo = 1 : numel( campos )

%% Merge all probabilities in one
Probabilidades = [ Probabilidades.PrimeraPooled; Probabilidades.SegundaPooled ];

%% Start calculating probabilities between teams
%% Build up matches 
enfrentamientos = cell( size( Jornada, 1 ), 1 );
Variables = { 'Casa', 'Empate', 'Fuera', 'Quiniela' };
for partido = 1 : size( Jornada, 1 )
    enfrentamientos{ partido, 1 } = [ Jornada{ partido, 1 }, '-', Jornada{ partido, 2 } ];
end % for partido = 1 : numel( Jornada )

tie = zeros( size( Jornada, 1 ), 1 );
homeWin = tie;
outWin = tie;
quiniela = cell( size( Jornada, 1 ), 1 );
relleno = { '1', 'X', '2' };

for partido = 1 : size( Jornada, 1 )
    % Find probabilities for both teams
    localTeam = strfind( cellstr( Probabilidades.Properties.RowNames ), Jornada{ partido, 1 } );
    localTeam = find( not( cellfun( 'isempty', localTeam ) ) );
    visitorTeam = strfind( cellstr( Probabilidades.Properties.RowNames ), Jornada{ partido, 2 } );
    visitorTeam = find( not( cellfun( 'isempty', visitorTeam ) ) );
    % Build up probability matrix
    probLocal = Probabilidades.Resultados( localTeam, : );
    probVisitor = Probabilidades.Resultados( visitorTeam, : );
    % Make sure dimensions are ok for both vectors
    probLocal = probLocal( : );     % Column vector Nx1
    probVisitor = reshape( probVisitor, 1, numel( probVisitor ) );  % Row vector 1xN    
    estimaciones = probLocal * probVisitor; % NxN Matrix
    % Percentages estimation
    tie( partido, 1 )     = trace( estimaciones );
    homeWin( partido, 1 ) = sum( sum( tril( estimaciones - diag( diag( estimaciones ) ) ) ) );
    outWin( partido, 1 )  = sum( sum( triu( estimaciones ) - diag( diag( estimaciones ) ) ) );
    [ ~, indice ] = max( [ homeWin( partido, 1 ), tie( partido, 1 ), outWin( partido, 1 ) ] );
    quiniela{ partido, 1 } = relleno{ indice };
end % for partido = 1 : size( Jornada, 1 )
%% Table with all forecast
Pronosticos = table( homeWin, tie, outWin, quiniela, 'RowNames', enfrentamientos, 'VariableNames', Variables );

%% Margin of victory model
% Import data
Partidos.Primera = importarPartidos( 'Partidos.xlsx', 'Primera', 1, 400 );
Partidos.Segunda = importarPartidos( 'Partidos.xlsx', 'Segunda', 1, 484 );
% Update names of Teams
campos = fieldnames( Partidos );
for equipo = 1 : numel( oldTeamsPrimera )
    indiceLocal = strfind( cellstr( Partidos.( campos{ 1 } ).Local ), oldTeamsPrimera{ equipo } );
    indiceLocal = find( not( cellfun( 'isempty', indiceLocal ) ) );
    Partidos.( campos{ 1 } ).Local( indiceLocal ) = newTeamsPrimera( equipo );
    indiceVisitante = strfind( cellstr( Partidos.( campos{ 1 } ).Visitante ), oldTeamsPrimera{ equipo } );
    indiceVisitante = find( not( cellfun( 'isempty', indiceVisitante ) ) );
    Partidos.( campos{ 1 } ).Visitante( indiceVisitante ) = newTeamsPrimera( equipo );
end % for equipo = 1 : numel( oldTeamsPrimera )

% For second division (downgrade 1 to 2A)
for equipo = 1 : numel( newTeamsPrimera )
    indiceLocal = strfind( cellstr( Partidos.( campos{ 2 } ).Local ), newTeamsPrimera{ equipo } );
    indiceLocal = find( not( cellfun( 'isempty', indiceLocal ) ) );
    Partidos.( campos{ 2 } ).Local( indiceLocal ) = oldTeamsPrimera( equipo );
    indiceVisitante = strfind( cellstr( Partidos.( campos{ 2 } ).Visitante ), newTeamsPrimera{ equipo } );
    indiceVisitante = find( not( cellfun( 'isempty', indiceVisitante ) ) );
    Partidos.( campos{ 2 } ).Visitante( indiceVisitante ) = oldTeamsPrimera( equipo );
end % for equipo = 1 : numel( oldTeamsPrimera )
% For second division (upgrade from 2A to 2)
for equipo = 1 : numel( oldTeamsSegunda )
    indiceLocal = strfind( cellstr( Partidos.( campos{ 2 } ).Local ), oldTeamsSegunda{ equipo } );
    indiceLocal = find( not( cellfun( 'isempty', indiceLocal ) ) );
    Partidos.( campos{ 2 } ).Local( indiceLocal ) = newTeamsSegunda( equipo );
    indiceVisitante = strfind( cellstr( Partidos.( campos{ 2 } ).Visitante ), oldTeamsSegunda{ equipo } );
    indiceVisitante = find( not( cellfun( 'isempty', indiceVisitante ) ) );
    Partidos.( campos{ 2 } ).Visitante( indiceVisitante ) = newTeamsSegunda( equipo );
end % for equipo = 1 : numel( oldTeamsSegunda )

% Save memory
for campo = 1 : numel( campos )
    Partidos.( campos{ campo } ).Local = categorical( Partidos.( campos{ campo } ).Local );
    Partidos.( campos{ campo } ).Visitante = categorical( Partidos.( campos{ campo } ).Visitante );
end

% Create total gols per team and division
GolesTotales.Primera = table;
GolesTotales.Segunda = table;
GolesTotales.Primera.Equipos = Estadisticas.Primera.Equipo;
GolesTotales.Segunda.Equipos = Estadisticas.Segunda.Equipo;
numGolesPrimera = 0: 1 : width( Estadisticas.Primera ) - 2;
numGolesSegunda = 0: 1 : width( Estadisticas.Segunda ) - 2;
GolesTotales.Primera.Totales = sum(numGolesPrimera .* table2array( Estadisticas.Primera( :, 2 : end ) ), 2 );
GolesTotales.Segunda.Totales = sum(numGolesSegunda .* table2array( Estadisticas.Segunda( :, 2 : end ) ), 2 );
% Get index for ranking in every division
[ ~, indexPrimera ] = sortrows( GolesTotales.Primera, 2, 'descend' );
[ ~, indexSegunda ] = sortrows( GolesTotales.Segunda, 2, 'descend' );
rankingPrimera = ( 1 : 1 : numel( indexPrimera ) )';
rankingSegunda = ( 1 : 1 : numel( indexSegunda ) )';
rankingPrimera = [ indexPrimera rankingPrimera ];
rankingSegunda = [ indexSegunda rankingSegunda ];
rankingPrimera = sortrows( rankingPrimera, 1 );
rankingSegunda = sortrows( rankingSegunda, 1 );
rankingPrimera = rankingPrimera( :, 2 );
rankingSegunda = rankingSegunda( :, 2 );
GolesTotales.Primera.Ranking = rankingPrimera;
GolesTotales.Segunda.Ranking = rankingSegunda;
% Calculate Rating and Zero-Based Rating
GolesTotales.Primera.Rating = GolesTotales.Primera.Totales / mean( GolesTotales.Primera.Totales );
GolesTotales.Segunda.Rating = GolesTotales.Segunda.Totales / mean( GolesTotales.Segunda.Totales );
GolesTotales.Primera.ZeroRating = GolesTotales.Primera.Rating - 1;
GolesTotales.Segunda.ZeroRating = GolesTotales.Segunda.Rating - 1;
% Calculate degree of error
homeAdv = 0.5;  % Initial guess for home advantage
for campo = 1 : numel( campos )
    Partidos.( campos{ campo } ).ActualMOV = Partidos.( campos{ campo } ).GolesLocal - ...
        Partidos.( campos{ campo } ).GolesVisitante;
    % Predicted Margin Of Victory
    % TODO: Vectorize next portion of code
    for partido = 1 : numel( Partidos.( campos{ campo } ).Fecha )
        % homeRating
        homeRating = GolesTotales.( campos{ campo } ).ZeroRating( contains( cellstr( GolesTotales.( campos{ campo } ).Equipos ), ...
            cellstr( Partidos.( campos{ campo } ).Local( partido ) ) ) );     
        % awayRating
        awayRating = GolesTotales.( campos{ campo } ).ZeroRating( contains( cellstr( GolesTotales.( campos{ campo } ).Equipos ) , ...
            cellstr( Partidos.( campos{ campo } ).Visitante( partido ) ) ) ); 
        Partidos.( campos{ campo } ).PredictedMOV( partido ) = marginofvictory( homeAdv, homeRating, awayRating );
    end % for partido = 1 : numel( Partidos.Fecha )
    % Error
    Partidos.( campos{ campo } ).Error = Partidos.( campos{ campo } ).PredictedMOV - ...
        Partidos.( campos{ campo } ).ActualMOV;
    Partidos.( campos{ campo } ).Error =  Partidos.( campos{ campo } ).Error .^ 2;
    % Define optimization problem
    x = [ homeAdv GolesTotales.( campos{ campo } ).ZeroRating' ];
    fun = @( x ) optimizeMOV( Partidos.( campos{ campo } ), x );
    options = optimoptions( 'fmincon', 'Display', 'off', 'Algorithm', 'sqp' );
    [ x, ~ ] = fmincon( fun, x, [], [], [], [], -Inf, Inf, [], options );
    MOV.( campos{ campo } ).homeAdv = x( 1 );
    MOV.( campos{ campo } ).Ratings = table( x( 2 : end )', 'RowNames', ...
        cellstr( GolesTotales.( campos{ campo } ).Equipos ), 'VariableNames', { 'Ratings' } );
end % for campo = 1 : numel( campos )

clearvars -except Pronosticos Estadisticas Partidos GolesTotales MOV