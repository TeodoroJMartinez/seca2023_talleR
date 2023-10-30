# Población residente por fecha, sexo, grupo de edad y nacionalidad
# Datos procedentes del INE
# https://www.ine.es/jaxiT3/Tabla.htm?t=56936

poblacionResidente_xFechaSexoGrupoEdadNacionalidad <- rio::import(
  here::here(
    'data', 'raw', 'poblacionResidente_xFecha-Sexo-GrupoEdad-Nacionalidad.csv'
  )
)
