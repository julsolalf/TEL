% Definir las rutas de entrada y salida
input_folder = 'C:\Users\RafitolMG\Documents\MATLAB\Fotos2';  % Modificar esta ruta con la ubicación de tus archivos ZIP
output_folder = 'C:\Users\RafitolMG\Documents\MATLAB\New Folder';  % Modificar esta ruta con la ubicación donde guardar los resultados

% Obtener los archivos ZIP (se asume que los archivos .zip están en una carpeta específica)
zip_files = dir(fullfile(input_folder, '*.zip'));

% Iterar sobre cada archivo ZIP
for i = 1:length(zip_files)
    zip_file = fullfile(input_folder, zip_files(i).name);
    % Extraer el archivo ZIP en un directorio temporal
    temp_folder = fullfile(input_folder, 'temp');
    if ~exist(temp_folder, 'dir')
        mkdir(temp_folder);
    end
    unzip(zip_file, temp_folder);
    
    % Nombres de las imágenes dentro del archivo ZIP
    b02 = dir(fullfile(temp_folder, '*B02*.png'));
    b03 = dir(fullfile(temp_folder, '*B03*.png'));
    b04 = dir(fullfile(temp_folder, '*B04*.png'));
    b08 = dir(fullfile(temp_folder, '*B08*.png'));
    
    % Cargar las imágenes de las bandas B02, B03, B04, B08
    B02 = im2double(imread(fullfile(temp_folder, b02.name)));
    B03 = im2double(imread(fullfile(temp_folder, b03.name)));
    B04 = im2double(imread(fullfile(temp_folder, b04.name)));
    B08 = im2double(imread(fullfile(temp_folder, b08.name))); 
    
    % Crear un nombre base para los resultados
    [~, name, ~] = fileparts(zip_files(i).name);
    
    % Crear histogramas para cada banda
    figure;
    subplot(2,2,1); imhist(B02); title('Histograma Banda B02');
    subplot(2,2,2); imhist(B03); title('Histograma Banda B03');
    subplot(2,2,3); imhist(B04); title('Histograma Banda B04');
    subplot(2,2,4); imhist(B08); title('Histograma Banda B08');
    
    % Guardar el histograma
    histogram_file = fullfile(output_folder, [name, '_histogram.png']);
    saveas(gcf, histogram_file);
    close;
    
    % Crear composición en color verdadero (RGB) usando B02, B03, B04
    RGB = cat(3, B02, B03, B04);  % Composición RGB
    true_color_file = fullfile(output_folder, [name, '_true_color.png']);
    imwrite(RGB, true_color_file);
    
    % Crear composición en falso color usando B08 (NIR), B04 (Rojo), B03 (Verde)
    false_color = cat(3, B08, B04, B03);  % Composición en falso color
    false_color_file = fullfile(output_folder, [name, '_false_color.png']);
    imwrite(false_color, false_color_file);
    
    % Limpiar el directorio temporal
    rmdir(temp_folder, 's');
    
    % Mostrar un mensaje de progreso
    fprintf('Imagen procesada: %s\n', name);
    
end