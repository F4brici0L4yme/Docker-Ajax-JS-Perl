# 1 Crear la imagen:

docker build -t layme .
 
# 2 Crear el contenedor en base a la imagen

docker run -d --name pweb1 -p 8089:80 layme
