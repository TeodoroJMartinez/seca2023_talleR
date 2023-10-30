## Configuración del subproceso 'dataIngestion'

### Procesos
#### Carga / instalación de paquetes de los procesos
##### Data Ingestion
if (!require(rio)) install.packages('rio')
if (!require(haven)) install.packages('haven')
if (!require(foreign)) install.packages('foreign')
if (!require(data.table)) install.packages('data.table')
if (!require(readr)) install.packages('readr')
if (!require(openxlsx)) install.packages('openxlsx')
if (!require(readxl)) install.packages('readxl')
if (!require(jsonlite)) install.packages('jsonlite')
if (!require(XML)) install.packages('XML')

##### Data Quality - ingest
if (!require(VIM)) install.packages('VIM')

#### Declaración de tipado de variables
#### Declaración de constantes
#### Declaración de variables
#### Declaración de funciones
source(here::here('R', 'fun', 'cargaPaquetes.R'))
source(here::here('R', 'fun', 'dataQual_ingest.R'))

#### Declaración de métodos
