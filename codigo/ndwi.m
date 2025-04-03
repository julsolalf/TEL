function ndwi()
input_folder = 'C:\Users\RafitolMG\Documents\MATLAB\Fotos2';  % Modificar esta ruta con la ubicación de tus archivos ZIP
output_folder = 'C:\Users\RafitolMG\Documents\MATLAB\New Folder';  % Modificar esta ruta con la ubicación donde guardar los resultados
    
% Obtener los archivos ZIP en la carpeta de entrada
    zip_files = dir(fullfile(input_folder, '*.zip'));

    % Iterar sobre cada archivo ZIP
    for i = 1:length(zip_files)
        zip_file = fullfile(input_folder, zip_files(i).name);
        temp_folder = fullfile(input_folder, 'temp');
        
        if ~exist(temp_folder, 'dir')
            mkdir(temp_folder);
        end
        
        unzip(zip_file, temp_folder);
        
        % Cargar las imágenes de las bandas B03 (Verde) y B08 (NIR)
        b03 = dir(fullfile(temp_folder, '*B03*.png'));
        b08 = dir(fullfile(temp_folder, '*B08*.png'));
        
        if isempty(b03) || isempty(b08)
            warning('No se encontraron las bandas necesarias en %s', zip_file);
            continue;
        end
        
        B03 = im2double(imread(fullfile(temp_folder, b03.name))); % Verde
        B08 = im2double(imread(fullfile(temp_folder, b08.name))); % NIR
        
        % Calcular el NDWI
        NDWI = (B03 - B08) ./ (B03 + B08);
        NDWI(isnan(NDWI)) = 0; % Manejo de NaN
        NDWI = uint8((NDWI + 1) * 127.5); % Escalar a [0, 255]
        
        % Aplicar se
        % udocolor similar al código proporcionado
        UMBRAL = 140;
        [F, C] = size(NDWI);
        pseudo_NDWI = zeros(F, C, 3);
        
        for f = 1:F
            for c = 1:C
                nd = NDWI(f, c);
                if nd > 0
                    if nd < UMBRAL
                        pseudo_NDWI(f, c, :) = [0 255 0]; % Azul para valores bajos
                    else
                        pseudo_NDWI(f, c, :) = [0 0 255]; % Verde para valores altos
                    end
                end
            end
        end
        pseudo_NDWI = uint8(pseudo_NDWI);
        
        % Guardar la imagen NDWI con seudocolor personalizado
        [~, name, ~] = fileparts(zip_files(i).name);
        ndwi_file = fullfile(output_folder, [name, '_NDWI.png']);
        imwrite(NDWI, ndwi_file);
        
        
        
        % Limpiar el directorio temporal
        rmdir(temp_folder, 's');
        
        fprintf('NDWI calculado y seudocolor aplicado para: %s\n', name);
    end
end