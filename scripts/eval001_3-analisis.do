/*##############################################################################
PROYECTO:
	> Bono Familiar Habitacional 
OBJETIVO:
	> Realiza el análisis final del proyecto.
BASES DE INSUMOS:
	> BBDD procesada para el análisis de resultados en educación ("$Producto/siagie_bono_final.dta")
	> BBDD procesada para el análisis de resultados en educación ("$Producto/IRA_final.dta" - "$Producto/EDA_final.dta")
AUTORES:
	> Richar Quispe (@mef.gob.pe)
		> Dirección General de Presupuesto Público
		> Dirección de Calidad de Gasto Público
		> Coordinación de Evaluaciones Independientes
SOFTWARE:
	> Stata 17
##############################################################################*/

*===============================================================================
* GENERALES
*===============================================================================
import delimited "$Producto/FINAL_EDUC.csv", clear varnames(1)
* Distribución del tratamiento [Tabla 2]
tab tratamiento
* Distribución del tratamiento por grado educativo [Tabla 9]
tab id_grado tratamiento

*===============================================================================
* RESULTADOS EN EDUCACIÓN
*===============================================================================
*-------------------------------------------------------------------------------
* Estimaciones
*-------------------------------------------------------------------------------
import delimited "$Producto/FINAL_EDUC.csv", clear varnames(1)
xtset dni id_anio

* Diferencias en medias en las notas por grados educativos [Tabla 3]
forvalues g = 4(1)14 {
	reg stdcom_nuevo1 i.tratamiento if id_grado == `g'
	reg stdmate_nuevo1 i.tratamiento if id_grado == `g'
}
reg stdcom_nuevo1 i.tratamiento
reg stdmate_nuevo1 i.tratamiento

* Diferencias en medias en los niveles de deserción [Gráfico 4]
preserve
	collapse (mean) desercion, by(tratamiento id_grado)
	reshape wide desercion, i(id_grado) j(tratamiento)
	line desercion0 desercion1 id_grado, legend(order(1 "Controles" 2 "Tratados"))
restore

* Impactos en las notas normalizadas [Tabla 4]
	* Comunicación
		* Promedio
reghdfe stdcom_nuevo1 i.tratamiento i.id_anio i.id_grado i.gestión i.edad i.sexo1 i.tratamiento##i.nota, absorb(DNI_titular cod_mod dni_comunicacion) vce(cluster DNI_titular)
margins, dydx(tratamiento)
		* Heterogeneidad por nivel y año
gen secundaria=(id_grado>9)
reghdfe stdcom_nuevo1 i.tratamiento##i.secundaria i.tratamiento##i.id_anio i.id_grado i.gestión i.edad i.sexo1 i.tratamiento##i.nota, absorb(DNI_titular cod_mod dni_comunicacion) vce(cluster DNI_titular)
margins, dydx(tratamiento)
margins, dydx(tratamiento) over(secundaria id_anio)
cap drop secundaria

	* Matemática
		* Promedio
reghdfe stdmate_nuevo1 i.tratamiento i.id_anio i.id_grado i.gestión i.edad i.sexo1 i.tratamiento##i.nota, absorb(DNI_titular cod_mod dni_matematica) vce(cluster DNI_titular)
margins, dydx(tratamiento)
		* Heterogeneidad por nivel y año
gen secundaria=(id_grado>9)
reghdfe stdmate_nuevo1 i.tratamiento##i.secundaria i.id_grado i.tratamiento##i.id_anio i.gestión i.edad i.sexo1 i.tratamiento##i.nota, absorb(DNI_titular cod_mod dni_matematica) vce(cluster DNI_titular)
margins, dydx(tratamiento)
margins, dydx(tratamiento) over(secundaria id_anio)
cap drop secundaria

* Impactos en la deserción [Tabla 5]
	* Modelo base
reghdfe desercion i.tratamiento i.id_anio i.id_grado i.gestión i.edad i.sexo1 if id_anio<2019, absorb(DNI_titular cod_mod dni_comunicacion dni_matematica) vce(cluster DNI_titular)
margins, dydx(tratamiento)
	* Heterogeneidad en el grado educativo
reghdfe desercion i.tratamiento##i.id_grado i.id_anio i.gestión i.edad i.sexo1 if id_anio<2019, absorb(DNI_titular cod_mod dni_comunicacion dni_matematica) vce(cluster DNI_titular)
margins, dydx(tratamiento)
margins, dydx(tratamiento) over(id_grado)

*===============================================================================
* RESULTADOS EN SALUD
*===============================================================================

*-------------------------------------------------------------------------------
* Descriptivas
*-------------------------------------------------------------------------------
* Número de atenciones en IRA a la población del BFH [Tabla 14]
import delimited "$Producto/FINAL_SALUD_IRA.csv", clear varnames(1)
gen _dup_IRA = min(dup_IRA,6) if dup_IRA != .
tab _dup_IRA anio

* Número de atenciones en EDA a la población del BFH [Tabla 15]
import delimited "$Producto/FINAL_SALUD_EDA.csv", clear varnames(1)
gen _dup_EDA = min(dup_EDA,6) if dup_EDA != .
tab _dup_EDA anio

*-------------------------------------------------------------------------------
* Estimaciones
*-------------------------------------------------------------------------------
* Diferencias en medias en las atenciones por IRA [Gráfico 5]
import delimited "$Producto/FINAL_SALUD_IRA.csv", clear varnames(1)
preserve
	collapse (mean) ira, by(d edad)
	reshape wide ira, i(edad) j(d)
	line ira0 ira1 edad, legend(order(1 "Controles" 2 "Tratados"))
restore

* Diferencias en medias en las atenciones por IRA [Gráfico 6]
import delimited "$Producto/FINAL_SALUD_EDA.csv", clear varnames(1)
preserve
	collapse (mean) eda, by(d edad)
	reshape wide eda, i(edad) j(d)
	line eda0 eda1 edad, legend(order(1 "Controles" 2 "Tratados"))
restore

* IMPACTOS EN LAS IRA [Tabla 7]
import delimited "$Producto/FINAL_SALUD_IRA.csv", clear varnames(1)
xtset dni anio
	* Modelo base - IRA
reghdfe ira i.d i.edad i.anio i.charlindex, absorb(DNI_titular) vce(cluster DNI_titular)
margins, dydx(d)
	* Heterogeneidad por edades
reghdfe ira i.d##i.edad i.anio i.elixsum, absorb(DNI_titular) vce(cluster DNI_titular)
margins, dydx(d)
margins, dydx(d) over(edad)

* IMPACTOS EN LAS EDA [Tabla 7]
import delimited "$Producto/FINAL_SALUD_EDA.csv", clear varnames(1)
xtset dni anio
	* Modelo base - EDA
reghdfe eda i.d i.edad i.anio i.charlindex, absorb(DNI_titular) vce(cluster DNI_titular)
margins, dydx(d)
	* Heterogeneidad por edades
reghdfe eda i.d##i.edad i.anio i.charlindex, absorb(DNI_titular) vce(cluster DNI_titular)
margins, dydx(d)
margins, dydx(d) over(edad)

