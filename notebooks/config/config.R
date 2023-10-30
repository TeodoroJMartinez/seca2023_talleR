## Configuración

### Entorno
#### Configuración global
options(
  defaultPackages = c(

    # Paquetes por defecto de la instalación de R
    'datasets', # Create Data Frames that are Easier to Exchange and Reuse
    'utils',    # The R utils package
    'grDevices',# The R Graphics Devices and Support for Colours and Fonts
    'graphics', # Data and Functions from the Book R Graphics, Third Edition
    'stats',    # Interactive Document for Working with Basic Statistical Analysis
    'methods'   # Formal Methods and Classes
  ),
  # Modifica el mensaje del prompt de R
  prompt = paste0(
    R.version$version.string,
    '> '),
  # Impide que los números grandes se muestren con notación científica
  scipen = 999
)
#### Carga / instalación de paquetes globales
if (!require(here)) install.packages('here')
if (!require(pacman)) install.packages('pacman')
if (!require(BiocManager)) install.packages("BiocManager")



#### Carga / instalación de paquetes para el taller
##### install the latest version of the Epi R Handbook package
pacman::p_install_gh("appliedepi/epirhandbook")

### Paquetes necesarios
if (!require(janitor)) install.packages('janitor')

