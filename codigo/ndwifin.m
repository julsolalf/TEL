function ndwifin()
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
        x=B03;
        y=B08;
        b = x > 0 & y > 0;
          g = double(x) / 255;
          n = double(y) / 255;
          z = (g - n) ./ (g + n);
          z = (z + 1) * 254 / 2 + 1;
          z = z .* b;
          z = uint8(z);
        NDWI=z;
        
        % Aplicar se
        % udocolor similar al código proporcionado
        UMBRAL = 141;
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
        
        % Aplicar segmentación con Density Slicing
        N = 7; % Número máximo de categorías
        MIN = 0;
        MAX = 255;
        UMBRAL = linspace(MIN, MAX, N + 1);
        
        RGB = [ 64,  64,  64  ;  % GRIS OSCURO (Tierra seca)
                 255, 166,   0  ;  % NARANJA (Vegetación escasa)
                 255, 255,   0  ;  % AMARILLO (Vegetación moderada)
                   0, 255,   0  ;  % VERDE (Vegetación densa)
                   0, 255, 255  ;  % CELESTE (Agua poco profunda)
                   0,   0, 255  ;  % AZUL (Agua media profundidad)
                 255,   0, 255  ;  % VIOLETA (Agua profunda)
                   0,   0, 128 ]; % AZUL OSCURO (Agua muy profunda)
        
        [F, C] = size(NDWI);
        segmented_NDWI = zeros(F, C, 3);
        
        for f = 1:F
            for c = 1:C
                nd = double(NDWI(f, c));
                if nd > 0
                    segmented_NDWI(f, c, :) = RGB(1, :);
                    for n = 1:N
                        if nd > UMBRAL(n) && nd <= UMBRAL(n + 1)
                            segmented_NDWI(f, c, :) = RGB(n + 1, :);
                        end
                    end
                end
            end
        end
        segmented_NDWI = uint8(segmented_NDWI);
        
        % Guardar la imagen NDWI segmentada
        [~, name, ~] = fileparts(zip_files(i).name);
        ndwi_file = fullfile(output_folder, [name, '_NDWI.png']);
        imwrite(NDWI, ndwi_file);
        
        segment_file = fullfile(output_folder, [name, '_NDWI_segmented.png']);
        imwrite(segmented_NDWI, segment_file);

        pseudo_file = fullfile(output_folder, [name, '_NDWI_pseudo.png']);
        imwrite(pseudo_NDWI, pseudo_file);
        
        % Limpiar el directorio temporal
        rmdir(temp_folder, 's');
        
        fprintf('NDWI calculado y segmentación aplicada para: %s\n', name);
    end
end
