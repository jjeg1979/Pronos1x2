function Resultados = leerResultados( nombreLibro )
% leerResultados( nombreLibro, nombreHojas )
%

    %% Read the sheetnames
    
    [ ~, nombreHojas, ~ ] = xlsfinfo( nombreLibro );

    %% Import the data
    for contador = 1 : numel( nombreHojas )
        [~, ~, raw] = xlsread(nombreLibro, nombreHojas{ contador });
        raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
        cellVectors = raw(:,[1,2]);
        raw = raw(:,[3,4]);

        %% Create output variable
        data = reshape([raw{:}],size(raw));

        %% Create table
        Res = table;

        %% Allocate imported array to column variable names
        Res.Locales = categorical( cellVectors(:,1) );
        Res.Visitantes = categorical( cellVectors(:,2) );
        Res.GolesLocal = data(:,1);
        Res.GolesVisitante = data(:,2);
        
        %% Assign to result
        Resultados.( nombreHojas{ contador } ) = Res;
    end % for contador = 1 : numel( nombreHojas )
end