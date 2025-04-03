clc; clear; close all;

% Directorio base
baseDir = 'Fotos';

% Obtener lista de carpetas
folders = dir(baseDir);
folders = folders([folders.isdir] & ~startsWith({folders.name}, '.'));

for i = 1:length(folders)
    folderPath = fullfile(baseDir, folders(i).name);
    
    % Obtener archivos de imagen
    b02 = dir(fullfile(folderPath, '*B02*.png'));
    b03 = dir(fullfile(folderPath, '*B03*.png'));
    b04 = dir(fullfile(folderPath, '*B04*.png'));
    b08 = dir(fullfile(folderPath, '*B08*.png'));
    
    if isempty(b02) || isempty(b03) || isempty(b04) || isempty(b08)
        continue; % Saltar si faltan imágenes
    end
    
    % Cargar imágenes
    img_B02 = im2double(imread(fullfile(folderPath, b02.name)));
    img_B03 = im2double(imread(fullfile(folderPath, b03.name)));
    img_B04 = im2double(imread(fullfile(folderPath, b04.name)));
    img_B08 = im2double(imread(fullfile(folderPath, b08.name))); % NIR
    
    % Guardar banda NIR
    imwrite(img_B08, fullfile(folderPath, 'Banda_NIR.png'));
    
    % Obtener y guardar histogramas
    figure;
    subplot(2,2,1), imhist(img_B02), title('Histograma B02');
    subplot(2,2,2), imhist(img_B03), title('Histograma B03');
    subplot(2,2,3), imhist(img_B04), title('Histograma B04');
    subplot(2,2,4), imhist(img_B08), title('Histograma B08 (NIR)');
    saveas(gcf, fullfile(folderPath, 'histogramas.png'));
    close;
    
    % Composición en color verdadero (RGB = B04, B03, B02)
    img_RGB = cat(3, img_B04, img_B03, img_B02);
    imwrite(img_RGB, fullfile(folderPath, 'composicion_RGB.png'));
    
    % Composición en falso color (NIR, Red, Green) = (B08, B04, B03)
    img_FC = cat(3, img_B08, img_B04, img_B03);
    imwrite(img_FC, fullfile(folderPath, 'composicion_falso_color.png'));
    
    fprintf('Procesado completado para la carpeta: %s\n', folderPath);
end

disp('Proceso finalizado para todas las carpetas.');