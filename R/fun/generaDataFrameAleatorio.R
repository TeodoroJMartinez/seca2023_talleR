## Creamos una base de datos ficticia con número de filas y columnas al azar
## Parámetros:
### nRows - Numero de filas. Por defecto, 30
### nCols - Número de variables. Por defecto, 10
### dispersionFilas - Distancia máxima que nos alejaremos del n para las filas. Por defecto 0
### dispersionColumnas - Distancia máxima que nos alejaremos de n para las columnas. Por defecto 0
### probFilasFaltantes - Probabilidad de que falten observaciones (filas)
### probColsFaltantes - Probabilidad de que falten variables (columnas)
### distribucionAleatoria - Tipo de distribución utilizada para la generación de los números aleatorios (uniforme o normal)
### valoresFaltantes - Indica si se deben incluir o no valores faltantes
### probDatosFaltantes - Probabilidad de que existan datos faltantes

generaDataframeAleatorio <- function(
    nRows = 30,
    nCols = 10,
    dispersionFilas = 5,
    dispersionColumnas = 5,
    probFilasFaltantes = 0.1,
    probColsFaltantes = 0.1,
    distribucionAleatoria = c(
      'uniforme'#,
      # 'normal',
      # 'poisson',
      # 'exponencial',
      # 'geometrica',
      # 'hipergeometrica'
      ),
    valoresFaltantes = T,
    probDatosFaltantes = 0.1
    ){
  ### 1.- Determinamos al azar el número de filas y columnas del data.frame
  dispersionAleatoriaFilas <- sample(
    -dispersionFilas:dispersionFilas,
    size = 1,
    replace = T
  )
  nFilas <- sample(
    x = c(
      nRows + dispersionAleatoriaFilas,
      nRows
      ),
    size = 1,
    replace = T,
    prob = c(
      probFilasFaltantes,     # Probabilidad de que sobren o falten observaciones
      1 - probFilasFaltantes) # Probabilidad de que los registros estén completos
  )

  dispersionAleatoriaColumnas <- sample(
    -dispersionColumnas:dispersionColumnas,
    size = 1,
    replace = T
  )

  nColumnas <- sample(
    x = c(
      nCols + dispersionAleatoriaColumnas,
      nCols
      ),
    size = 1,
    replace = T,
    prob = c(
      probColsFaltantes,    # Probabilidad de que sobren o falten variables
      1 - probColsFaltantes # Probabilidad de que las variables estén completas
      )
  )

  funcionProbabilidad <- dplyr::case_when(
    distribucionAleatoria == 'uniforme' ~ 'runif(n = nFilas, min = 0, max = 1)',
    distribucionAleatoria == 'normal' ~'rnorm(n = nFilas, mean = 0, sd = 1)',
    distribucionAleatoria == 'poisson' ~ 'rpois(n = nFilas, lambda = 1)',
    distribucionAleatoria == 'exponencial' ~ 'rexp(n = nFilas, rate = 1)',
    distribucionAleatoria == 'geometrica' ~ 'rgeom(n = nFilas, prob = 0.5)',
    distribucionAleatoria == 'hipergeometrica' ~ 'rhyper(nn = nFilas, m = 20, n = 10, k = 15)'
  )

### 2.- Creamos un *data.frame* vacío con un vector `id`de índices de `nFilas`
id <- seq(nFilas)
data <- data.frame(id)

### 3.- Mediante un bucle, repetimos `nColumnas` veces la tarea de crear un vector aleatorio `var` de `nFilas`, y posteriormente anexarlo al *data.frame* `data`
for (i in (1:nColumnas)) {
  eval(
    parse(
      text =
        paste0('var', i, '<- ', funcionProbabilidad)
    )
  )
  tmpexpr <- paste0('data <- cbind(data, var', i,')')
  eval(
    parse(
      text = tmpexpr
    )
  )
  tmpexpr <- paste0("rm(list = c('tmpexpr', 'var", i,"', 'i'))")
  eval(
    parse(
      text = tmpexpr
    )
  )
}


### 4- Eliminamos la columna índice
data <- dplyr::select(data, -id)

### 5.- Incluimos valores faltantes (si el argumento valoresFaltantes = T)
if (valoresFaltantes == T) {
  naMatrix <- matrix(
    data = sample(
      x = c(T,F),
      size = ncol(data) * nrow(data),
      replace = T,
      prob = c(
        probDatosFaltantes,
        (1 - probDatosFaltantes)
        )
      ),
    nrow = nrow(data),
    ncol = ncol(data)
  )
  data[naMatrix] <- NA
}

### 6- Limpieza final
rm(list = c(
  'dispersionAleatoriaFilas',
  'dispersionAleatoriaColumnas',
  'id',
  'nColumnas',
  'nFilas'
))

data
}
data <- generaDataframeAleatorio()
