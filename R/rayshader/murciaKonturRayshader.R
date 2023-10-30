# Paso 0: Cargamos / instalamos los paquetes requeridos
if (!require(here))       install.packages('here')
if (!require(sf))         install.packages('sf')
if (!require(tidyverse))  install.packages('tidyverse')
if (!require(stars))      install.packages('stars')
if (!require(rgl))        install.packages('rgl')
if (!require(MetBrewer))  install.packages('MetBrewer')
if (!require(colorspace)) install.packages('colorspace')
if (!require(grDevices))  install.packages('grDevices')
if (!require(magick))     install.packages('magick')
if (!require(glue))       install.packages('glue')
if (!require(rayshader))  devtools::install_github("tylermorganwall/rayshader")


# Paso 1 - Cargamos los datos de Kontur
## La fuente original está en https://data.humdata.org/dataset/kontur-population-dataset
## Se puede filtrar por países para aligerar el proceso

data <- sf::st_read(
  here::here(
    'data', 'lab', 'kontur_population_ES_20220630.gpkg'
    )
  )

# Paso 2 - Cargamos los límites administrativos que nos interesen

### Cargamos los límites administrativos de las comunidades autónomas de España
ccaa <- sf::st_read(
  here::here(
    'data', 'lab', 'kontur_boundaries_ES_20230628.gpkg'
  )
)

### Revisamos el dataset creado para para localizar la variable con los nombres de las CCAA
### En este caso, es la variable $name
dplyr::glimpse(ccaa)

murcia <- ccaa |>
  dplyr::filter(
    name == 'Región de Murcia'
  )

# Paso 3 (opcional) - Comprobamos que el fichero creado contiene la información necesaria para crear un mapa básico
murcia |>
  ggplot2::ggplot() +
  ggplot2::geom_sf()

# Paso 4 - Filtramos los datos de población cuyas coordenadas están dentro del sf deseado
## Utilizaremos la función sf::st_intersection()
## Este paso llevará un tiempo, es normal que tarde algunos minutos

## OJOCUIDAO 1 - los datos de CRS (coordinate reference system) pueden ser diferentes entre fuentes distintas y datos geolocalizados diferentes
### Esto generará un error. Ejemplo (sin arreglar el problema):
st_murcia <- sf::st_intersection(data, murcia)

### Podemos comprobar que los CRS son diferentes con la función sf::st_crs()
sf::st_crs(data)
sf::st_crs(murcia)

### Para arreglarlo, será necesario igualar los CRS con la función sf::st_transform()
murcia <- murcia |>
  sf::st_transform(
    crs = sf::st_crs(data)
  )
sf::st_crs(murcia)

### Ahora, se puede reejecutar la función de filtro de datos
st_murcia <- sf::st_intersection(data, murcia)

# Paso 5 - Conversión de los datos en formatos matriz
## El paquete rayshader necesita los datos en formato de matriz
## Para transformar nuestros datos debemos seguir una serie de pasos
####### Definir el aspect ratio utilizando un bounding box
### Paso 5.1 Definir el aspect ratio utilizando un bounding box (sf::st_bbox())
### El Bounding box nos indica cuatro posiciones que limitan nuestros datos
### Con estas cuatro posiciones podemos construir las coordinadas de una caja que enmarca los datos

bb <- sf::st_bbox(st_murcia)

### Paso 5.2. Convertir las posiciones del bounding box en puntos del CRS

#### La metodología para hacerlo tiene dos pasos
#### En primer lugar lo convertimos en un punto de un sistema de coordenadas cualquiera
bottomLeft <- sf::st_point(c(bb[['xmin']], bb[['ymin']])) |>
  #### En segundo lugar, ubicamos dicho punto en el sistema CRS de nuestros datos
  sf::st_sfc(crs = sf::st_crs(data))

#### Repetiremos esta metodología para obtener al menos tres puntos del bounding box (no necesitamos los cuatro para medir el largo y el alto de la caja)
bottomRight <- sf::st_point(c(bb[['xmax']], bb[['ymin']])) |>
  sf::st_sfc(crs = sf::st_crs(data))

upperLeft <- sf::st_point(c(bb[['xmin']], bb[['ymax']])) |>
  sf::st_sfc(crs = sf::st_crs(data))

upperRight <- sf::st_point(c(bb[['xmax']], bb[['ymax']])) |>
  sf::st_sfc(crs = sf::st_crs(data))

### Paso 5.3. (opcional) Representación gráfica de los cuatro puntos en el mapa
murcia |>
  ggplot2::ggplot() +
  ggplot2::geom_sf() +
  ggplot2::geom_sf(data = bottomLeft, color = 'red') +
  ggplot2::geom_sf(data = bottomRight, color = 'red') +
  ggplot2::geom_sf(data = upperLeft, color = 'red') +
  ggplot2::geom_sf(data = upperRight, color = 'red')

### Paso 5.4 Calculamos la distancia entre los puntos para determinar el largo y el alto
### La unidad de medida viene determinada por el CRS
width <-  sf::st_distance(bottomLeft, bottomRight)
height <- sf::st_distance(bottomLeft, upperLeft)

### Paso 5.5. Calculamos el ratio entre la altura y la anchura del mapa
### Definimos condiciones para las posibilidades de que altura o anchura sean el lado más largo
if (width > height) {
  w_ratio <- 1
  h_ratio <- height / width
}else{
  h_ratio <- 1
  w_ratio <- width / height
}
w_ratio <- 1

### Paso 5.6. Convertimos a formato raster, como paso previo a la conversión a matriz
#### Definimos el tamaño deseado para la imagen
#### Es recomendable fijar un tamaño pequeño mientras probamos, y cambiar el parámetro al tamaño final deseado sólo al final. Descomentar factorMejoraResolucionFinal
tamanyoTest = 1000
factorMejoraResolucionFinal = 5

size = tamanyoTest #*factorMejoraResolucionFinal

#### Creamos el objeto raster, utilizando la función stars::st_rasterize()
murcia_rast <- stars::st_rasterize(
  st_murcia,
  nx = floor(size * w_ratio),
  ny = floor(size * h_ratio)
  )

### Paso 5.7 Creamos la matriz, para el componente $population del objeto raster

mat <- matrix(
  murcia_rast$population,
  nrow = floor(size * w_ratio),
  ncol = floor(size * h_ratio)
  )

# Paso 6 (opcional) - Crear una paleta de color especial

colorPalette <- MetBrewer::met.brewer('OKeeffe2')
colorspace::swatchplot(colorPalette)

colorTexture <- grDevices::colorRampPalette(
  colorPalette,
  bias = 2)(256) # El parámetro 'bias' controla lo sesgada que está la paleta hacia un extremo o otro de la gama de colores. Parámetros por debajo de 1 la sesgan a la izquierda, y por encima de 1 la sesgan a la derecha
colorspace::swatchplot(colorTexture)

# Paso 6 - Creación del objeto 3D
## OJOCUIDAO - Durante el proceso de creación del gráfico, debe cerrarse la ventana cada vez que hacemos una prueba, o los gráficos se dibujarán uno encima del otro.
## Podemos utilizar una función para que esto se ejecute mediante código (comentar si no es necesaria)
rgl::close3d()
mat |>
  rayshader::height_shade(texture = colorTexture) |>
  rayshader::plot_3d(
    # los valores para el parámetro 'hillshade' los proporcional la función height_shade()
    heightmap = mat,
    zscale = 100/factorMejoraResolucionFinal, # Adjust the zscale down to exaggerate elevation features
    solid = FALSE,
    shadowdepth = 0, # Elimina la distancia entre la sombra y la base de los gráficos de densidad

  )

# Paso 7 - Parametrización de la cámara interactiva 3D por defecto
rayshader::render_camera(
  theta = -20, # Define la rotación en el eje. El valor 0 impide la rotación
  phi = 45,  # Define el ángulo azimutal. Máximo 90º
  zoom = .8  # Define el nivel de zoom
)

# Paso 8 - Renderización de la imagen en alta calidad
outfile <- 'output/final_plot_MU.png'
{
  startTime <- Sys.time()
  if (!file.exists(outfile)) {
    png::writePNG(matrix(1), target = outfile)
  }
  rayshader::render_highquality(
    filename = 'output/final_plot_MU.png',
    interactive = FALSE,
    lightdirection = 280,
    lightaltitude = c(20, 80),
    lightcolor = c(colorPalette[1], 'white'),
    lightintensity = c(600, 100),
    samples = 450,
    width = 6000,
    height = 6000
  )
  endTime <- Sys.time()
  diff <- endTime - startTime
  cat(crayon::cyan(diff), '\n')
}

## Paso 9 - Manipulación final del archivo .png con el paquete magick

img <- magick::image_read('output/final_plot_MU.png')

textColor <- colorspace::darken(colorPalette[7], .25)
colorspace::swatchplot(textColor)

annot <- glue::glue(
  'Este mapa muestra la densidad de población de la Región de Murcia. ',
  'La población estimada se empaqueta en hexágonos de 400m.'
) |>
  stringr::str_wrap(68)

img |>
  magick::image_crop(
    gravity = 'center',
    geometry = '6000x4500'
  ) |>
  magick::image_annotate(
    'Densidad de población de la Región de Murcia',
    gravity = 'northwest',
    location = '+200+100',
    color = textColor,
    size = 200,
    weight = 700
    ) |>
  magick::image_annotate(
    annot,
    gravity = 'northwest',
    location = '+200+400',
    color = textColor,
    size = 125
  ) |>
  magick::image_annotate(
    glue::glue('Mapa elaborado por Teodoro J. Martínez (@TeodoroJMartne1) | ',
         'Datos: Kontur Population (Versión 2022-06-30)'),
    gravity = 'south',
    location = '+0+100',
    color = ggplot2::alpha(textColor, .5),
    size = 70
  ) |>
  magick::image_write(
    'output/titled_final_plot_MU.png'
  )


