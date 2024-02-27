/*##############################################################################
PROYECTO:
	> Bono Familiar Habitacional 
OBJETIVO:
	> Genera las bases finales para el análisis de los resultados de salud.
BASES DE INSUMOS:
	> Base de datos del HIS ("$Intermedio/trama_HIS_####_bfh.dta")
	> BBDD procesada del BFH ("$Intermedio/AVN_merge1v3.dta")
BASES CREADAS:
	> "$Intermedio/IRA_final.dta"
	> "$Intermedio/EDA_final.dta"
AUTORES:
	> Richar Quispe (@mef.gob.pe)
		> Dirección General de Presupuesto Público
		> Dirección de Calidad de Gasto Público
		> Coordinación de Evaluaciones Independientes
SOFTWARE:
	> Stata 17
##############################################################################*/
*===============================================================================
* Generando el indice de Charlson y Elixhauser
*===============================================================================
forvalues i=2017/2019 {
	use "$Intermedio/trama_HIS_`i'_bfh.dta", clear
	gen codigo_1=substr(cod_item,1,1)
	gen codigo=substr(cod_item,2,2)
	destring codigo, force replace 
	drop if codigo_1=="J"				// IRA
	drop if codigo<10 & codigo_1=="A"	// EDA

	preserve
		charlson cod_item, index(10) idvar(dni) assign0 wtchrl
		gen anio=`i'
		save "$Intermedio/charlson`i'.dta", replace
	restore
	preserve
		elixhauser cod_item, index(10) idvar(dni) smelix cmorb
		gen anio=`i'
		save "$Intermedio/elixhauser`i'.dta", replace
	restore
}

use "$Intermedio/charlson2017.dta", clear
append using "$Intermedio/charlson2018.dta", force
append using "$Intermedio/charlson2019.dta", force
keep anio dni charlindex grpci
save "$Intermedio/charlson_index.dta", replace
erase "$Intermedio/charlson2017.dta"
erase "$Intermedio/charlson2018.dta"
erase "$Intermedio/charlson2019.dta"

use "$Intermedio/elixhauser2017.dta", clear
append using "$Intermedio/elixhauser2018.dta", force
append using "$Intermedio/elixhauser2019.dta", force
keep anio dni elixsum
save "$Intermedio/elixhauser_index.dta", replace
erase "$Intermedio/elixhauser2017.dta"
erase "$Intermedio/elixhauser2018.dta"
erase "$Intermedio/elixhauser2019.dta"

*===============================================================================
* Prepara datos de salud
*===============================================================================
* Corrigiendo los años
use "$Insumos/trama_HIS_2017_bfh.dta", clear
tostring f_atencion, replace
gen anio=substr(f_atencion,1,4)
order anio
destring anio, replace
save "$Intermedio/trama_HIS_2017_bfh.dta", replace

use "$Insumos/trama_HIS_2018_bfh.dta", clear
gen anio=year(f_atencion)
order anio
save "$Intermedio/trama_HIS_2018_bfh.dta", replace

use "$Insumos/trama_HIS_2019_bfh.dta", clear
gen anio=year(f_atencion)
order anio
save "$Intermedio/trama_HIS_2019_bfh.dta", replace

* Separando las IRA y EDA

forvalues i=2017/2019 {
	use "$Intermedio/trama_HIS_`i'_bfh.dta", clear
	gen codigo_1=substr(cod_item,1,1)
	gen codigo=substr(cod_item,2,2)
	destring codigo, force replace
	keep if (codigo_1=="J") | (codigo<10 & codigo_1=="A")
	* Teniendo valores únicos por id_cita, esta base es de diagnosticos
	duplicates drop id_cita codigo_1, force
	save "$Intermedio/HIS_`i'.dta", replace
}

*===============================================================================
* Generar base por tipo de enfermedad (IRA, EDA).
* Deben tener valores únicos por DNI, y mostrar el # de diagnósticos en el año 
*===============================================================================
* 1) IRA
forvalues i=2017/2019 {
	use "$Intermedio/HIS_`i'.dta", clear
	destring edadreg, replace
	keep if codigo_1=="J"
	bysort dni: gen dup_IRA=_N
	duplicates drop dni, force
	drop _merge
	save "$Intermedio/IRA_`i'.dta", replace
}
use "$Intermedio/IRA_2017.dta", clear
append using "$Intermedio/IRA_2018.dta", force
append using "$Intermedio/IRA_2019.dta", force
order anio dni dup_IRA
sort dni anio
save "$Intermedio/IRA_completo.dta", replace
forvalues i=2017/2019 {
	erase "$Intermedio/IRA_`i'.dta"
}

* 2) EDA
forvalues i=2017/2019 {
	use "$Intermedio/HIS_`i'.dta", clear
	destring edadreg, replace
	keep if codigo_1=="A"
	bysort dni: gen dup_EDA=_N
	duplicates drop dni, force
	drop _merge
	save "$Intermedio/EDA_`i'.dta", replace
}
use "$Intermedio/EDA_2017.dta", clear
append using "$Intermedio/EDA_2018.dta", force
append using "$Intermedio/EDA_2019.dta", force
order anio dni dup_EDA
sort dni anio
save "$Intermedio/EDA_completo.dta", replace
forvalues i=2017/2019 {
	erase "$Intermedio/EDA_`i'.dta"
}

*===============================================================================
* Haciendo Match BBDD HIS con BBDD del BFH
*===============================================================================

* Generando variable de tratamiento
use "$Intermedio/AVN_merge1v3.dta", clear
sort DNI_titular mo_order
rename tratamiento_nuevo tratamiento_bono
keep dni DNI_titular f_nacimiento FECHADESEMBOLSO MESDESEMBOLSO AÑODESEMBOLSO INGRESO_FAMILIAR NSE tratamiento_bono ESTADO ESTADOACTUALDEGF ANIO_POSTULACION DEPARTAMENTO PROVINCIA DISTRITO sexo estado_civil instruccion
gen id_anio_nuevo=AÑODESEMBOLSO+1 if ESTADO=="BENEFICIARIO DESEMBOLSADO"
sort DNI_titular
bysort DNI_titular: gen seq=_n
keep if seq==1
save "$Intermedio/tratamiento_merge.dta", replace

* Agregar cantidad de atenciones
forvalues i=2017/2019 {
	use "$Intermedio/trama_HIS_`i'_bfh.dta", clear
	* IRA
	gen codigo_1=substr(cod_item,1,1)
	drop if codigo_1=="J"
	* EDA
	gen codigo=substr(cod_item,2,2)
	destring codigo, force replace
	drop if codigo<10 & codigo_1=="A"
	duplicates drop id_cita dni, force
	bysort dni: gen seq10=_N 
	duplicates drop dni, force
	keep anio dni seq10
	save "$Intermedio/atenciones`i'.dta", replace
}
use "$Intermedio/atenciones2017.dta", clear
append using "$Intermedio/atenciones2018.dta", force
append using "$Intermedio/atenciones2019.dta", force
save "$Intermedio/atenciones.dta", replace
erase "$Intermedio/atenciones2017.dta"
erase "$Intermedio/atenciones2018.dta"
erase "$Intermedio/atenciones2019.dta"

* Análizando las IRA/EDA y generando variable de tratamiento
foreach Y in "IRA" "EDA" {
	use `Y'_completo, clear
	merge 1:1 anio dni using maestro_siagie_bono
	replace dup_`Y'=0 if dup_`Y'==.
	sort dni anio
	drop _merge
	merge 1:1 anio dni using base_merge, keepus (edad)
	sort dni anio
	drop if _merge==2
	order anio dni edad
	drop _merge 
	merge m:1 dni using "C:\Users\rquispe\Desktop\EI BFH\BBDD_COMPLETAS\AVN_merge1v3", keepus (f_nacimiento)
	drop if _merge==2
	
	* Completar edades
	order anio dni edad f_nacimiento
	gen edad_con= year(f_nacimiento)
	gen edad_faltante= anio-edad_con
	order edad_faltante, after(edad)
	tostring dni, gen(dni_string)
	gen enlace=substr(dni_string,1,3)
	destring enlace, replace
	gen edad_mes=edadreg/12 if enlace>=796 & id_tipedad_reg=="M"
	order edad_mes, after(f_nacimiento)
	gen edad_red=floor(edad_mes)
	order edad_red, after(edad_mes)
	replace edad=edad_red if edad==.

	* Corregir edades
	replace edad=edad_faltante if edad==.
	drop edad_faltante edad_red edad_con f_nacimiento
	replace edad=. if edad<0
	gen anio1=anio if !missing(edad)
	order anio1
	egen suma=total(edad), by(dni)
	order suma, after(edad)
	drop if suma==0
	drop suma
	egen edad_max=max(edad), by(dni)
	order edad_max, after(edad)
	egen anio_max=max(anio1), by(dni)
	order anio_max, after(anio1)
	gen suma= anio -anio_max
	order sum, after(edad_max)
	gen edad_completo=edad_max+suma
	order edad_completo, after(edad)
	replace edad_completo=. if edad_completo<0
	drop anio1 anio_max edad edad_max suma edad_mes 
	sort dni anio
	save `Y'_completo1, replace
	
	* Generar variable de tratamiento
	use `Y'_completo1, clear
	drop _merge
	merge m:1 DNI_titular using "$Intermedio/tratamiento_merge.dta", keepus(id_anio_nuevo tratamiento_bono INGRESO_FAMILIAR NSE ESTADO ESTADOACTUALDEGF ANIO_POSTULACION AÑODESEMBOLSO DEPARTAMENTO PROVINCIA DISTRITO sexo estado_civil instruccion)
	sort dni anio
	keep if _merge==3
	replace id_anio_nuevo=. if id_anio_nuevo>2019
	tab id_anio_nuevo
	gen resta=id_anio_nuevo - anio
	gen tratamiento=1 if resta<1
	replace tratamiento=0 if tratamiento==.
	drop resta
	replace tratamiento=0 if ESTADOACTUALDEGF=="DEVUELTO"
	
	gen `Y'=.
	order `Y', after(dup_`Y')
	replace `Y'=1 if dup_`Y'>0
	replace `Y'=0 if `Y'==.
	keep anio id_anio_nuevo dni edad_completo dup_`Y' `Y' DNI_titular sexo estado_civil instruccion DEPARTAMENTO PROVINCIA DISTRITO ESTADO INGRESO_FAMILIAR NSE AÑODESEMBOLSO tratamiento_bono tratamiento

	* Agregar índice de Elixhauser
	merge 1:1 anio dni using "$Intermedio/elixhauser_index.DTA"
	sort dni anio
	drop if _merge==2
	drop _merge
	replace elixsum=99 if elixsum==. 

	* Agregar índice de Charlson
	merge 1:1 anio dni using "$Intermedio/charlson_index.DTA"
	sort dni anio
	drop if _merge==2
	drop _merge
	replace charlindex=99 if charlindex==. 
	replace grpci=99 if grpci==. 
	
	* Hacer merge con las atenciones
	merge 1:1 anio dni using "$Intermedio/atenciones.dta"
	drop if _merge==2
	drop _merge
	rename seq10 atenciones
	replace atenciones=0 if atenciones==. 
	
	* Corriegiendo edades
	recode edad_completo (0/5=1 "menores de 5 año") (6/11=2 "6 y 11 años") (12/18=3 "12 a 18 años") (19/100=4 "19 a más años"), gen(edad)

	******Correciones finales del Tratamiento 
	gen year_treat=anio-1
	drop if AÑODESEMBOLSO<2016
	drop if AÑODESEMBOLSO>2018 & AÑODESEMBOLSO!=.

	gen d=1 if AÑODESEMBOLSO==2016
	replace d=1 if AÑODESEMBOLSO==2017 & year_treat>=2017
	replace d=1 if AÑODESEMBOLSO==2018 & year_treat>=2018
	replace d=0 if d==.
	
	save "$Producto/`Y'_final.dta", replace
		 
	keep dni anio `Y' d edad anio charlindex elixsum DNI_titular dup_`Y'
	egen _dni = group(dni)
	egen _DNI_titular = group(DNI_titular)
	drop dni DNI_titular
	rename _* *
	compress
	order dni anio `Y' edad DNI_titular elixsum charlindex dup_`Y'
	rename `Y', l
	sort dni anio
	export delimited "$Producto/FINAL_SALUD_`Y'.csv", replace nolabel
}
erase "$Intermedio/tratamiento_merge.dta"

