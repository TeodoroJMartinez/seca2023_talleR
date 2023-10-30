# Esto es un comentario
# Se puede convertir una línea en un comentario poniendo un hastag '#'

# Cargamos los datos con la función data()
data(diamonds, package = 'ggplot2')

# Podemos ver información sobre el dataset 'diamonds' con la función help()
help(diamonds)

# Creamos un gráfico para mostrar la relación entre las características de los diamantes y su precio
g <- diamonds |>
  ggplot2::ggplot(
    ggplot2::aes(
      x = carat,            # Eje x - peso del diamante
      y = price,            # Eje y - precio del diamante
      color = cut,          # Color del punto - Por calidad del corte
      shape = color         # Forma del punto - Por color del diamante
    )
  ) +
  ggplot2::geom_point() +   # Elegimos la estética de puntos
  ggplot2::theme_bw() +     # Elegimos una estética sencilla

  # Añadimos etiquetas al gráfico
  ggplot2::ggtitle(
    'Prices of over 50,000 round cut diamonds'
  ) +
  ggplot2::labs(
    subtitle = 'Base de datos diamonds del paquete `ggplot2`'
  )
g
