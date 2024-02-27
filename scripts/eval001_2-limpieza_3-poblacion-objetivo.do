/*##############################################################################
PROYECTO:
	> Bono Familiar Habitacional 
OBJETIVO:
	> Genera base de la población objetivo.
BASES DE INSUMOS:
	> BBDD procesada del BFH ("$Intermedio/AVN_merge1v3.dta")
	> SIAGIE ("$Intermedio/siagie_####.dta" - "$Intermedio/siagie_####_nue.dta")
BASES CREADAS:
	> "$Intermedio/maestro_siagie_bono.dta"
AUTORES:
	> Richar Quispe (@mef.gob.pe)
		> Dirección General de Presupuesto Público
		> Dirección de Calidad de Gasto Público
		> Coordinación de Evaluaciones Independientes
SOFTWARE:
	> Stata 17
##############################################################################*/

*===============================================================================
* Generando población objetivo
*===============================================================================

* Trabajando con las bases del SIAGIE 2014 - 2019
* Quitando los DNI no validados y borrando los DNI diferentes de 8 dìgitos
forval t = 2014(1)2016{
	use "$Insumos/siagie_`t'.dta",clear
	keep if validacion_dni=="DNI VALIDADO"
	gen DNI_long=strlen(dni)
	drop if DNI_long==0
	drop if DNI_long==7
	destring dni, replace
	save "$Intermedio/siagie_`t'.dta", replace
}
forval t = 2017(1)2019{
	use "$Insumos/siagie_`t'.dta",clear
	keep if validación_reniec=="DNI VALIDADO"
	rename dni_estudiante dni
	replace dni=trim(itrim(dni))
	gen DNI_long=strlen(dni)
	keep if DNI_long==8
	drop if dni=="JH111152"
	drop if dni=="36923-02"
	destring dni, replace
	save "$Intermedio/siagie_`t'.dta", replace
}

* Eliminando duplicados en el DNI del SIAGIE
forval t = 2014(1)2019{
	use "$Intermedio/siagie_`t'.dta", clear
	bysort dni: gen seq3=_n
	keep if seq3==1
	drop seq3
	save "$Intermedio/siagie_`t'.dta", replace
}

* Codificando los valores del grado para tener un valor único
forval t = 2014(1)2016{
	use "$Intermedio/siagie_`t'.dta", clear
	gen id_grado=.
	replace id_grado=4 if nivel_educativo=="Primaria"&dsc_grado=="PRIMERO"
	replace id_grado=5 if nivel_educativo=="Primaria"&dsc_grado=="SEGUNDO"
	replace id_grado=6 if nivel_educativo=="Primaria"&dsc_grado=="TERCERO"
	replace id_grado=7 if nivel_educativo=="Primaria"&dsc_grado=="CUARTO"
	replace id_grado=8 if nivel_educativo=="Primaria"&dsc_grado=="QUINTO"
	replace id_grado=9 if nivel_educativo=="Primaria"&dsc_grado=="SEXTO"
	replace id_grado=10 if nivel_educativo=="Secundaria"&dsc_grado=="PRIMERO"
	replace id_grado=11 if nivel_educativo=="Secundaria"&dsc_grado=="SEGUNDO"
	replace id_grado=12 if nivel_educativo=="Secundaria"&dsc_grado=="TERCERO"
	replace id_grado=13 if nivel_educativo=="Secundaria"&dsc_grado=="CUARTO"
	replace id_grado=14 if nivel_educativo=="Secundaria"&dsc_grado=="QUINTO"
	save "$Intermedio/siagie_`t'.dta", replace
}

*===============================================================================
***Unificando las bases para hacer la población objetiva
*===============================================================================

use "$Intermedio/AVN_merge1v3.dta", clear
keep DNI_titular dni f_nacimiento
save "$Intermedio/tmp_mho_bono.dta", replace

use "$Intermedio/AVN_merge1v3.dta", clear
drop if mo_order>=3
keep DNI_titular dni
rename dni dni_padres
save "$Intermedio/tmp_titulares_bono.dta", replace

*Data SIAGIE 2013-2022
forvalues i=2013/2016 {
	use "$Intermedio/siagie_`i'.dta", clear
	destring dni, replace force
	drop if dni==.
	bysort dni: gen seq=_n
	drop if seq>1 
	gen f_nacimiento=date(fecha_nacimiento,"DMY")
	keep dni f_nacimiento
	save "$Intermedio/tmp_siagie_`i'.dta", replace
}

forvalues i=2017/2019 {
	use "$Intermedio/siagie_`i'.dta", clear
	destring dni, replace force
	drop if dni==.
	bysort dni: gen seq=_n
	drop if seq>1 
	gen f_nacimiento=date(fecha_nacimiento,"YMD")
	destring nro_doc_apoderado, gen(dni_padres) force
	keep dni f_nacimiento dni_padres
	save tmp_siagie_`i', replace
}

use "$Insumos/siagie_2020_4TO_secundaria.dta", clear
destring dnideldocentetutor, replace force
append using "$Insumos/siagie_2020_5TO_secundaria.dta"
destring dni_estudiante, gen(dni) force
drop if dni==.
bysort dni: gen seq=_n
drop if seq>1 
gen f_nacimiento=date(fecha_nacimiento,"YMD")
rename nro_doc_apoderado dni_padres
keep dni f_nacimiento dni_padres
save "$Intermedio/tmp_siagie_2020.dta", replace

forvalues i=2021/2022 {
	use "$Intermedio/siagie_`i'.dta", clear
	destring dni_estudiante, gen(dni) force
	drop if dni==.
	bysort dni: gen seq=_n
	drop if seq>1 
	gen f_nacimiento=date(fecha_nacimiento,"YMD")
	destring nro_doc_apoderado, gen(dni_padres) force
	keep dni f_nacimiento dni_padres
	save "$Intermedio/tmp_siagie_`i'.dta", replace
}

* Validación de datos con el DNI tanto el SIAGIE como el BFH
forvalues i=2013/2022 {
	use "$Intermedio/tmp_siagie_`i'.dta", clear
	merge 1:1 dni f_nacimiento using "$Intermedio/tmp_mho_bono.dta"
	keep if _merge==3
	drop _merge
	save "$Intermedio/tmp_siagie_mho_`i'.dta", replace
}

* Generando sub maestros del SIAGIE inscritos por padres registrados en el BFH
forvalues i=2017/2022 {
	use "$Intermedio/tmp_siagie_`i'.dta", clear
	drop if dni_padres==.
	merge m:1 dni_padres using "$Intermedio/tmp_titulares_bono.dta"
	keep if _merge==3
	drop _merge
	save "$Intermedio/tmp_siagie_padres_`i'.dta", replace
}

use "$Intermedio/tmp_siagie_mho_2013.dta", clear
forvalues i=2014/2022 {
	append using "$Intermedio/tmp_siagie_mho_`i'.dta"
}
forvalues i=2017/2022 {
	append using "$Intermedio/tmp_siagie_padres_`i'.dta"
}

bysort dni f_nacimiento: gen seq=_n
keep if seq==1
bysort dni: gen seq1=_n
bysort dni: gen seq2=_N
drop if dni==63156574
keep if seq1==1
drop seq* dni_padres f_nacimiento

save "$Intermedio/maestro_siagie_bono.dta", replace

*===============================================================================
* Eliminando bases de datos temporales
*===============================================================================
forvalues i=2017/2022 {
	erase "$Intermedio/tmp_siagie_`i'.dta"
	erase "$Intermedio/tmp_siagie_mho_`i'.dta"
}
forvalues i=2017/2022 {
	erase "$Intermedio/tmp_siagie_padres_`i'.dta"
}
erase "$Intermedio/tmp_mho_bono.dta"
erase "$Intermedio/tmp_titulares_bono.dta"

