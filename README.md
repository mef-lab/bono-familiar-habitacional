<h1 align="center">  Evaluación de Impacto del Bono Familiar Habitacional</h1>

Este repositorio contiene información para la replica de la evaluación de impacto del Bono Familiar Habitacional desarrollada en el Ministerio de Economía y Finanzas por Richar Quispe Cuba. Explora otros repositorios [aquí](https://github.com/mef-lab).


## Resumen
Se presenta los resultados de la evaluación de impacto del Bono Familiar Habitacional en la educación y salud. Se utilizan bases de datos de registros administrativos del Fondo mi Vivienda con el fin de conocer a los hogares que reciben el BFH y ahora viven en una vivienda nueva; para la educación se usan registros del SIAGIE, con el fin de evaluar los efectos en las notas normalizadas de comunicación y matemática, así como deserción escolar interanual. El horizonte temporal es del 2014 al 2019, no se está considerando años posteriores debido a la pandemia. La metodología empleada es un modelo cuasiexperimental de diferencias en diferencias con efectos fijos escalonados debido a que el tratamiento se encuentra en cada año, es decir, si un año un hogar no recibió el bono, posiblemente lo haya recibido en los años siguientes. La misma lógica se usa para los efectos en la salud, donde se ha utilizado la base de datos del HIS para las variables de EDAS e IRAS en un horizonte temporal del 2017-2019. Los resultados muestran que el Bono Familiar habitacional no tiene efectos en promedio para los dos grupos de enfermedades ni notas normalizadas en educación, pero si se encuentra efectos heterogéneos significativos tanto en educación y salud.

## Requerimientos de software
- Stata (version 16)
  - `estout` (3.23)
  - `iefieldkit` (2.0)
  - `ietoolkit` (6.3)
  - `unique` (1.2.4)
  - `coefplot` (1.8.3)

## Instrucciones para replicar

1. Click en el botón verde `Clonar o descargar` mostrará la lista de archivos en este folder para descargar una copia local de este repositorio.
1. En el folder `bono-familiar-habitacional/scripts`, verá un script maestro `eval001_0-maestro` en Stata.
1. Corra el archivo de Stata `eval001_0-maestro`. Este do-file creates all the non-map tables and graphs included in the working paper.
1. Los outputs se guardarán en el folder `bono-famliar-habitacional/outputs`.

## Bases de insumo

Estas bases no están incluidas en este repositorio, debido a que contienen información confidencial y a que su tamaño supera los límites establecidos para el mismo.

|Descripción|Data|Institución proveedora|Nombre de archivos|Fecha de corte|
|:---:|:---:|:---:|:---:|:---:|
|Registro administrativo del BFH|Postulantes al programa.|MVCS (Fondo MIVIVIENDA)|2014.xlsx <br> 2015.xlsx <br> 2016.xlsx <br> 2017.xlsx <br> 2018.xlsx <br> 2019.xlsx|11/11/2023|
|Registro administrativo de beneficiarios del BFH|Beneficiarios del programa.|MVCS (Fondo MIVIVIENDA)|Desembolsos AVN historico.xlsx|14/05/2023|
|SIAGIE|Estudiantes de EBR.|MINEDU|siagie_2014.dta <br> siagie_2015.dta <br> siagie_2016.dta <br> siagie_2017.dta <br> siagie_2018.dta <br> siagie_2019.dta|15/12/2023|
|SIAGIE|Data actualizada y revisada del SIAGIE; se utiliza solo el dato sobre secciones.|MINEDU|siagie_2014_nue.dta <br> siagie_2015_nue.dta <br> siagie_2016_nue.dta|08/09/2023|
|Registro de docentes de EBR|Docentes de EBR.|MINEDU|docente2014_2022.dta|01/11/2023|
|Base de datos del HIS|Atenciones registradas en el HIS.|MINSA|trama_HIS_2017_bfh <br> trama_HIS_2018_bfh.dta <br> trama_HIS_2019_bfh.dta|15/07/2023|


## Cómo contribuir
Si al revisar este código consideras que:

Has añadido alguna nueva funcionalidad con la que agregas valor para que más personas la reutilicen, has hecho más versátil la herramienta para que sea compatible con nuevas actualizaciones, has solucionado algún fallo existente, o simplemente has mejorado la interfaz de usuario o documentación del mismo.
Entonces te animamos a que devuelvas al repositorio los avances realizados.

Sigue los siguientes pasos para hacer una contribución a la herramienta digital:

- Haz un fork del repositorio. 
- Desarrolla la nueva funcionalidad o los haz los cambios que creas que agregan valor a la herramienta
- Haz un "pull request" documentando detalladamente los cambios propuestos en el repositorio.

## Código de conducta 
Nosotros como contribuyentes y administradores nos comprometemos a hacer de la participación en nuestro proyecto y nuestra comunidad una experiencia libre de acoso para todos, independientemente de la edad, dimensión corporal, discapacidad, etnia, identidad y expresión de género, nivel de experiencia, nacionalidad, apariencia física, raza, religión, identidad u orientación sexual.

Antes de interactuar con Código para el Desarrollo y utilizar nuestros canales de comunicación te pedimos que revises nuestro [Código de Conducta](https://github.com/mef-lab/bono-familiar-habitacional/blob/main/CODE-OF-CONDUCT.md) para mantener este espacio lo más seguro que se pueda para sus participantes. 

## Disclaimer
Este repositorio contiene archivos para la replicación de las regresiones finales de la evaluación. Los archivos compartidos aquí no incluyen información personal, cumpliendo con la normativa vigente de protección de datos personales.

Si desea replicar el análisis utilizando la totalidad de los scripts, deberá solicitar las bases de datos con la información detallada sobre la trama y la fecha de corte. Estos detalles se encuentran especificados en [bases de insumos](https://github.com/mef-lab/bono-familiar-habitacional?tab=readme-ov-file#bases-de-insumo). Para obtener dicha información, deberá contactar a las instituciones correspondientes.

Agradecemos su interés en este proyecto y esperamos que estos recursos sean de utilidad.

## Contacto
En caso de tener alguna consulta escribir a mef_lab@mef.gob.pe.

## Licencia
Todo el contenido de este repositorio es publicado bajo la licencia del MIT por lo que los recursos aquí almacenados son de libre uso. Ver [Licencia](https://github.com/mef-lab/bono-familiar-habitacional/blob/main/LICENSE) para todos los detalles.

## 
<div class = "row">
  <div class = "column" style = "width:10%">
    <img src="https://github.com/mef-lab/bono-familiar-habitacional/blob/main/img/logo_mef.png" align = "left">

    
  </div>
  <div class = "column" style = "width:10%">
    <img src="https://github.com/mef-lab/bono-familiar-habitacional/blob/main/img/logo_mef_lab.png" align = "right">
  </div>
</div>
