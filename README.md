# 1 Crear la imagen:

docker build -t pruebas .
 
# 2 Crear el contenedor en base a la imagen

docker run -d --name pruebazzz -p 8089:80 pruebas
