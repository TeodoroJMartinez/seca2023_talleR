### Configuración del Proceso
#### Carga / instalación de paquetes de los procesos
##### Correlation Analysis
if (!require(ggplot2))     install.packages('ggplot2')
if (!require(MASS))        install.packages('MASS')
if (!require(correlation)) install.packages('correlation')
if (!require(Hmisc))       install.packages('Hmisc')
if (!require(graph))       BiocManager::install('graph') ## Dependiencia de ggm
if (!require(ggm))         install.packages('ggm')
if (!require(polycor))     install.packages('polycor')

#### Declaración de tipado de variables
#### Declaración de constantes
#### Declaración de variables
#### Declaración de funciones
#### Declaración de métodos