/*##############################################################################
PROYECTO:
	> Bono Familiar Habitacional 
OBJETIVO:
	> Convierte la base procesada del BFH a formato panel.
BASES DE INSUMOS:
	> BBDD procesada del BFH ("$Intermedio/AVN_merge.dta" - "$Intermedio/AVN_merge1.dta")
BASES CREADAS:
	> "$Intermedio/AVN_merge1v3.dta"
AUTORES:
	> Richar Quispe (@mef.gob.pe)
		> Dirección General de Presupuesto Público
		> Dirección de Calidad de Gasto Público
		> Coordinación de Evaluaciones Independientes
SOFTWARE:
	> Stata 17
##############################################################################*/

*===============================================================================
* Trabajando la BBDD del BFH en formato Panel de Datos
*===============================================================================
use "$Intermedio/AVN_merge1.dta", clear

duplicates drop
bysort ANIO_POSTULACION DNI_titular: gen seq=_N
tab seq tratamiento
bysort ANIO_POSTULACION DNI_titular: gen seq1=_n
keep if seq1==1

save "$Intermedio/AVN_merge1v0.dta", replace

drop paterno_titular materno_titular nombre_titular nacimiento_titular edad_titular sexo_titular estadocivil_titular instruccion_titular ocupacion_titular discapacidad_titular DNI_conyuge paterno_conyuge materno_conyuge nombre_conyuge nacimiento_conyuge edad_conyuge sexo_conyuge instruccion_conyuge discapacidad_conyuge DNI_miembro1 paterno_miembro1 materno_miembro1 nombre_miembro1 nacimiento_miembro1 edad_miembro1 sexo_miembro1 instruccion_miembro1 discapacidad_miembro1 DNI_miembro2 paterno_miembro2 materno_miembro2 nombre_miembro2 nacimiento_miembro2 edad_miembro2 sexo_miembro2 instruccion_miembro2 discapacidad_miembro2 DNI_miembro3 paterno_miembro3 materno_miembro3 nombre_miembro3 nacimiento_miembro3 edad_miembro3 sexo_miembro3 instruccion_miembro3 discapacidad_miembro3 _merge

save "$Intermedio/temp_AVN_0.dta", replace

use "$Intermedio/AVN_merge1v0.dta", clear

keep ANIO_POSTULACION DNI_titular paterno_titular materno_titular nombre_titular nacimiento_titular edad_titular sexo_titular estadocivil_titular instruccion_titular ocupacion_titular discapacidad_titular

gen DNI_MO=DNI_titular

rename paterno_titular apaterno
rename materno_titular amaterno
rename nombre_titular nombres
rename nacimiento_titular f_nacimiento
rename edad_titular edad
rename sexo_titular sexo
rename estadocivil_titular estado_civil
rename instruccion_titular instruccion
rename ocupacion_titular ocupacion
rename discapacidad_titular discapacidad
keep if DNI_MO!=""
save "$Intermedio/temp_AVN_1.dta", replace

use "$Intermedio/AVN_merge1v0.dta", clear

keep ANIO_POSTULACION DNI_titular DNI_conyuge paterno_conyuge materno_conyuge nombre_conyuge nacimiento_conyuge edad_conyuge sexo_conyuge instruccion_conyuge discapacidad_conyuge 

rename DNI_conyuge DNI_MO
rename paterno_conyuge apaterno
rename materno_conyuge amaterno
rename nombre_conyuge nombres
rename nacimiento_conyuge f_nacimiento
rename edad_conyuge edad
rename sexo_conyuge sexo
rename instruccion_conyuge instruccion
rename discapacidad_conyuge discapacidad
keep if DNI_MO!=""
save "$Intermedio/temp_AVN_2.dta", replace

forvalues i=1/3 {
	use "$Intermedio/AVN_merge1v0.dta", clear

	keep ANIO_POSTULACION DNI_titular DNI_miembro`i' paterno_miembro`i' materno_miembro`i' nombre_miembro`i' nacimiento_miembro`i' edad_miembro`i' sexo_miembro`i' instruccion_miembro`i' discapacidad_miembro`i' 

	rename DNI_miembro`i' DNI_MO
	rename paterno_miembro`i' apaterno
	rename materno_miembro`i' amaterno
	rename nombre_miembro`i' nombres
	rename nacimiento_miembro`i' f_nacimiento
	rename edad_miembro`i' edad
	rename sexo_miembro`i' sexo
	rename instruccion_miembro`i' instruccion
	rename discapacidad_miembro`i' discapacidad
	keep if DNI_MO!=""
	save "$Intermedio/temp_AVN_m`i'.dta", replace
}

use "$Intermedio/temp_AVN_1.dta", clear
gen mo_order=1
append using "$Intermedio/temp_AVN_2.dta"
replace mo_order=2 if mo_order==.
append using "$Intermedio/temp_AVN_m1.dta"
replace mo_order=3 if mo_order==.
append using "$Intermedio/temp_AVN_m2.dta"
replace mo_order=4 if mo_order==.
append using "$Intermedio/temp_AVN_m3.dta"
replace mo_order=5 if mo_order==.

order ANIO_POSTULACION DNI_titular DNI_MO mo_order
sort ANIO_POSTULACION DNI_titular mo_order DNI_MO

merge m:1 ANIO_POSTULACION DNI_titular using "$Intermedio/temp_AVN_0.dta"
rename DNI_MO dni
save "$Intermedio/AVN_merge1v2.dta", replace

forvalues i=0/2 {
erase "$Intermedio/temp_AVN_`i'.dta"
}
forvalues i=1/3 {
erase "$Intermedio/temp_AVN_m`i'.dta"
}

* Borrando DNI en la base del bono diferentes a 8 dìgitos

gen DNI_long3=strlen(dni)
keep if DNI_long3==8
bysort ANIO_POSTULACION dni: gen seq2=_n
keep if seq2==1
bysort dni: gen seqq=_n

* Este algoritmo es debido a que muchas personas han postulado muchas veces y en una de ellas fue elegible, nos quedamos con el último año

keep if seqq==1|(seqq>1&tratamiento==1)
bysort dni: gen seqq1=_N
keep if seqq1==1|(seqq1>1&tratamiento==1)
bysort dni: gen seqq2=_N
duplicates drop dni, force
destring dni, replace
destring DNI_titular, replace
gen edad_general=round(edad)
order edad_general, after(edad)
drop if edad_general<0
drop edad
rename edad_general edad

* Generando nuevo tratamiento, se está haciendo corrección
gen tratamiento_nuevo=.
replace tratamiento_nuevo=1 if ESTADOACTUALDEGF=="BENEFICIARIO DESEMBOLSADO"
replace tratamiento_nuevo=0 if tratamiento_nuevo==.
tab tratamiento_nuevo 
save "$Intermedio/AVN_merge1v3.dta", replace



