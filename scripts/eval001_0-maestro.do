/*##############################################################################
PROYECTO:
	> Bono Familiar Habitacional 
OBJETIVO:
	> Código maestro.
AUTORES:
	> Richar Quispe (@mef.gob.pe)
		> Dirección General de Presupuesto Público
		> Dirección de Calidad de Gasto Público
		> Coordinación de Evaluaciones Independientes
SOFTWARE:
	> Stata 17
##############################################################################*/

*###############################################################################
* PREPARACION
*###############################################################################
cls
clear all
*===============================================================================
* Paquetes y comandos externos
*===============================================================================
ssc install charlson
ssc install elixhauser
ssc install reghdfe
*===============================================================================
* Parámetros y configuración
*===============================================================================
set seed 100
set varabbrev off
set type double
set excelxlsxlargefile on
set more off
*===============================================================================
* Directorios
*===============================================================================
* Richar Quispe
if c(username) == "rquispe" {
	global PC 				"C:/Users/rquispe/Desktop"
	global Proyecto 		"$PC/EI BFH"
	global General 			"$PC/General"
}
*-------------------------------------------------------------------------------	
* General
*-------------------------------------------------------------------------------
global Insumos 		"$Proyecto/Insumos"
global Intermedio 	"$Proyecto/Intermedio"
global Producto 	"$Proyecto/Producto"

*###############################################################################
* PROCESO
*###############################################################################
* Carga bases de insumo y las guarda enb el formato apropiado (DTA)
do "$Proyecto/eval122_1-insumos.do"

* Realiza la limpieza de la data para generar las bases finales para el análisis
do "$Proyecto/eval122_2-limpieza_1-limpieza-inicial-bfh.do"		// Realiza la limpieza inicial de las bases del BFH.
do "$Proyecto/eval122_2-limpieza_2-formato-panel.do"			// Convierte la base procesada del BFH a formato panel.
do "$Proyecto/eval122_2-limpieza_3-poblacion-objetivo.do"		// Genera base de la población objetivo.
do "$Proyecto/eval122_2-limpieza_4-variables-educacion.do"		// Genera la base final para el análisis de los resultados de educación.
do "$Proyecto/eval122_2-limpieza_5-variables-salud.do"			// Genera las bases finales para el análisis de los resultados de salud.

* Realiza el análisis final del proyecto
do "$Proyecto/eval122_3-analisis.do"

