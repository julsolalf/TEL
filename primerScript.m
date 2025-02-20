r1 = imread('B04-1.png');
g1 = imread('B03-1.png');
b1 = imread('B02-1.png');
n1 = imread('B08-1.png');

r2 = imread('B04-2.png');
g2 = imread('B03-2.png');
b2 = imread('B02-2.png');
n2 = imread('B08-2.png');

imagenTotal = r1+g1+b1+n1;




  % Cargar la imagen
img_reducida = diezma(imagenTotal);      % Reducir la imagen
imshow(img_reducida);           % Mostrar la imagen reducida

img_ampliada = amplia(imagenTotal);
imshow(img_ampliada);

function img_reducida = diezma(img)
    % Esta funci�n realiza la reducci�n de la imagen eliminando 1 de cada 2 filas y columnas.
    
    % Selecciona las filas impares (1 de cada 2 filas)
    filas_reducidas = img(1:2:end, :);
    
    % Selecciona las columnas impares (1 de cada 2 columnas)
    img_reducida = filas_reducidas(:, 1:2:end);
end

function img_ampliada = amplia(img)
    % Obtiene las dimensiones de la imagen original
    [filas, columnas, canales] = size(img);
    
    % Doble tama�o de la imagen
    filas_nuevas = filas * 2;
    columnas_nuevas = columnas * 2;
    
    % Inicializa la imagen ampliada
    img_ampliada = zeros(filas_nuevas, columnas_nuevas, canales, 'like', img);
    
    % Recorre cada p�xel en la imagen ampliada
    for i = 1:filas_nuevas
        for j = 1:columnas_nuevas
            % Encuentra la posici�n original correspondiente en la imagen de entrada
            x = i / 2;
            y = j / 2;
            
            % Encuentra las coordenadas enteras m�s cercanas
            x1 = floor(x);
            y1 = floor(y);
            x2 = min(x1 + 1, filas);
            y2 = min(y1 + 1, columnas);
            
            % Aseg�rate de que x1, y1, x2, y2 son �ndices v�lidos (enteros y dentro del rango)
            x1 = max(x1, 1);
            y1 = max(y1, 1);
            x2 = max(x2, 1);
            y2 = max(y2, 1);
            
            % Calcula los coeficientes de interpolaci�n bilineal
            dx = x - x1;
            dy = y - y1;
            
            % Interpolaci�n bilineal
            for k = 1:canales
                % Interpolaci�n bilineal para cada canal
                img_ampliada(i, j, k) = (1 - dx) * (1 - dy) * double(img(x1, y1, k)) + ...
                                        dx * (1 - dy) * double(img(x2, y1, k)) + ...
                                        (1 - dx) * dy * double(img(x1, y2, k)) + ...
                                        dx * dy * double(img(x2, y2, k));
            end
        end
    end
    
    % Convertir la imagen resultante a la clase original
    img_ampliada = cast(img_ampliada, 'like', img);
end
