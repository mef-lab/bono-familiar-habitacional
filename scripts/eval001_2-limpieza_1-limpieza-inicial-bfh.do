/*##############################################################################
PROYECTO:
	> Bono Familiar Habitacional 
OBJETIVO:
	> Realiza la limpieza inicial de las bases del BFH.
BASES DE INSUMOS:
	> BBDD procesada del BFH ("$Intermedio/BFH.dta" - "$Intermedio/AVN_INICIAL.dta")
BASES CREADAS:
	> "$Intermedio/AVN_merge.dta"
	> "$Intermedio/AVN_merge1.dta"
AUTORES:
	> Richar Quispe (@mef.gob.pe)
		> Dirección General de Presupuesto Público
		> Dirección de Calidad de Gasto Público
		> Coordinación de Evaluaciones Independientes
SOFTWARE:
	> Stata 17
##############################################################################*/

*===============================================================================
* Corrigiendo las etiquetas de la BBDD de BFH
*===============================================================================
use "$Intermedio/BFH.dta", clear
gen elegible_year=year(FECHA_ELEGIBILIDAD)
destring ANIO_POSTULACIO, replace

* Verificaciòn de DNI y borrando los que tienen diferentes a 8 dìgitos
gen DNI_long=strlen(N_DOC)
tab DNI_long
replace N_DOC="0"+N_DOC if DNI_long==7
drop if inlist(DNI_long,9,10,15)
drop MOTIVO

* Modificando etiquetas
	* SEXO
replace SEXO="1" if SEXO=="MASCULINO"
replace SEXO="0" if SEXO=="FEMENINO"
replace SEXO="" if SEXO=="SIN INFORMACION"
destring SEXO, replace
label define SEXO 1 "Masculino" 0 "Femenino"
label values SEXO SEXO

	* ESTADO CIVIL
replace ESTADO_CIVIL="1" if ESTADO_CIVIL=="SOLTERO"
replace ESTADO_CIVIL="2" if ESTADO_CIVIL=="CASADO"
replace ESTADO_CIVIL="3" if ESTADO_CIVIL=="VIUDO"
replace ESTADO_CIVIL="4" if ESTADO_CIVIL=="DIVORCIADO"
replace ESTADO_CIVIL="" if ESTADO_CIVIL=="SIN INFORMACION"
destring ESTADO_CIVIL, replace
label define ESTADO_CIVIL 1 "Soltero" 2 "Casado" 3 "Viudo" 4 "Divorciado"
label values ESTADO_CIVIL ESTADO_CIVIL

	* GRADO DE INSRTUCCIÓN
replace GRADO_INSTRUCCION="1" if GRADO_INSTRUCCION=="SIN INSTRUCCION"
replace GRADO_INSTRUCCION="2" if GRADO_INSTRUCCION=="PRIMARIA"
replace GRADO_INSTRUCCION="3" if GRADO_INSTRUCCION=="SECUNDARIA"
replace GRADO_INSTRUCCION="4" if GRADO_INSTRUCCION=="TECNICO"
replace GRADO_INSTRUCCION="5" if GRADO_INSTRUCCION=="SUPERIOR"
replace GRADO_INSTRUCCION="" if GRADO_INSTRUCCION=="SIN INFORMACION"
destring GRADO_INSTRUCCION, replace
label define GRADO_INSTRUCCION 1 "Sin instrucción" 2 "Primaria" 3 "Secundaria" 4 "Técnico" 5 "Superior"
label values GRADO_INSTRUCCION GRADO_INSTRUCCION

	* DISCAPACIDAD
replace DISCAPACIDAD="1" if DISCAPACIDAD=="SI"
replace DISCAPACIDAD="0" if DISCAPACIDAD=="NO"
replace DISCAPACIDAD="" if DISCAPACIDAD=="SIN INFORMACION"
destring DISCAPACIDAD, replace
label define DISCAPACIDAD 1 "Si" 0 "No"
label values DISCAPACIDAD DISCAPACIDAD

	* DNI CONYUGE
replace CNY_DNI="" if CNY_DNI=="SIN INFORMACION"
* Verificaciòn de DNI del cónyuge
gen DNI_conyuge=strlen(CNY_DNI)
tab DNI_conyuge, missing
* Corrigiendo los DNI del conyuge
replace CNY_DNI="0000"+CNY_DNI if DNI_conyuge==4
replace CNY_DNI="00"+CNY_DNI if DNI_conyuge==6
replace CNY_DNI="0"+CNY_DNI if DNI_conyuge==7
drop if inlist(DNI_conyuge,9,10)
* Borrar todo lo que dice SIN INFORMACIÓN DEL CONYUGE
replace CNY_AP_PATERNO="" if CNY_AP_PATERNO=="SIN INFORMACION"
replace CNY_AP_MATERNO="" if CNY_AP_MATERNO=="SIN INFORMACION"
replace CNY_NOMBRE="" if CNY_NOMBRE=="SIN INFORMACION"
gen conyuge1=CNY_NOMBRE
replace conyuge1= "1" if !missing(conyuge1)
destring conyuge1, replace
replace CNY_FECHA_NACIMIENTO="" if CNY_FECHA_NACIMIENTO=="SIN INFORMACION"
replace CNY_SEXO="" if CNY_SEXO=="SIN INFORMACION"
replace CNY_GRADO_INSTRUCCIÓN="" if CNY_GRADO_INSTRUCCIÓN=="SIN INFORMACION"
replace CNY_DISCAPACIDAD="" if CNY_DISCAPACIDAD=="SIN INFORMACION"

	* MIEMBRO DEL HOGAR 3
replace MIEMBRO3_N_DOC="" if MIEMBRO3_N_DOC=="SIN INFORMACION"
replace MIEMBRO3_AP_PATERNO="" if MIEMBRO3_AP_PATERNO=="SIN INFORMACION"
replace MIEMBRO3_AP_MATERNO="" if MIEMBRO3_AP_MATERNO=="SIN INFORMACION"
replace MIEMBRO3_NOMBRE="" if MIEMBRO3_NOMBRE=="SIN INFORMACION"
gen miembro1hogar=MIEMBRO3_NOMBRE
replace miembro1hogar= "1" if !missing(miembro1hogar)
destring miembro1hogar, replace

replace MIEMBRO3_FECHA_NACIMIENTO="" if MIEMBRO3_FECHA_NACIMIENTO=="SIN INFORMACION"
replace MIEMBRO3_SEXO="" if MIEMBRO3_SEXO=="SIN INFORMACION"
replace MIEMBRO3_GRADO_INSTRUCCIÓN="" if MIEMBRO3_GRADO_INSTRUCCIÓN=="SIN INFORMACION"
replace MIEMBRO3_DISCAPACIDAD="" if MIEMBRO3_DISCAPACIDAD=="SIN INFORMACION"

	* MIEMBRO DEL HOGAR 4
replace MIEMBRO4_N_DOC="" if MIEMBRO4_N_DOC=="SIN INFORMACION"
replace MIEMBRO4_AP_PATERNO="" if MIEMBRO4_AP_PATERNO=="SIN INFORMACION"
replace MIEMBRO4_AP_MATERNO="" if MIEMBRO4_AP_MATERNO=="SIN INFORMACION"
replace MIEMBRO4_NOMBRE="" if MIEMBRO4_NOMBRE=="SIN INFORMACION"

gen miembro2hogar=MIEMBRO4_NOMBRE
replace miembro2hogar= "1" if !missing(miembro2hogar)
destring miembro2hogar, replace

replace MIEMBRO4_FECHA_NACIMIENTO="" if MIEMBRO4_FECHA_NACIMIENTO=="SIN INFORMACION"
replace MIEMBRO4_SEXO="" if MIEMBRO4_SEXO=="SIN INFORMACION"
replace MIEMBRO4_GRADO_INSTRUCCION="" if MIEMBRO4_GRADO_INSTRUCCION=="SIN INFORMACION"
replace MIEMBRO4_DISCAPACIDAD="" if MIEMBRO4_DISCAPACIDAD=="SIN INFORMACION"

	* MIEMBRO DEL HOGAR 5
replace MIEMBRO5_N_DOC="" if MIEMBRO5_N_DOC=="SIN INFORMACION"
replace MIEMBRO5_AP_PATERNO="" if MIEMBRO5_AP_PATERNO=="SIN INFORMACION"
replace MIEMBRO5_AP_MATERNO="" if MIEMBRO5_AP_MATERNO=="SIN INFORMACION"
replace MIEMBRO5_NOMBRE="" if MIEMBRO5_NOMBRE=="SIN INFORMACION"

gen miembro3hogar=MIEMBRO5_NOMBRE
replace miembro3hogar= "1" if !missing(miembro3hogar)
destring miembro3hogar, replace

replace MIEMBRO5_FECHA_NACIMIENTO="" if MIEMBRO5_FECHA_NACIMIENTO=="SIN INFORMACION"
replace MIEMBRO5_SEXO="" if MIEMBRO5_SEXO=="SIN INFORMACION"
replace MIEMBRO5_GRADO_INSTRUCCION="" if MIEMBRO5_GRADO_INSTRUCCION=="SIN INFORMACION"
replace MIEMBRO5_DISCAPACIDAD="" if MIEMBRO5_DISCAPACIDAD=="SIN INFORMACION"

	* NIVEL SOCIOECONÓMICO
replace NSE="0" if NSE=="FUERA DE RANGO"
replace NSE="1" if NSE=="C"
replace NSE="2" if NSE=="D"
replace NSE="3" if NSE=="E"
replace NSE="" if NSE=="SIN INFORMACION"
destring NSE, replace
label define NSE 0 "Fuera de rango" 1 "C" 2 "D" 3 "E"
label values NSE NSE

drop FORMULARIO
drop CONVOCATORIA
drop MONEDA_INGRESO
drop BE
drop DNI_long
drop DNI_conyuge
drop miembro1hogar
drop miembro2hogar
drop miembro3hogar
drop conyuge1

save "$Intermedio/BFH_corregido.dta", replace

*===============================================================================
* Trabajando la BBDD de Beneficiados desembolsados AVN
*===============================================================================

use "$Intermedio/AVN_INICIAL.dta", clear

*Corrección de un dato del estado actual
replace ESTADOACTUALDEGF="DEVUELTO" if ESTADOACTUALDEGF=="|"

*Verificaciòn de DNI y borrando los que tienen diferentes a 8 dìgitos
gen DNI_long=strlen(DNI)
tab DNI_long
*Corrigiendo DNI, completando con ceros
replace DNI="000"+DNI if DNI_long==5
replace DNI="00"++DNI if DNI_long==6
replace DNI="0"++DNI if DNI_long==7

gen MERGE_DNI_CORREGIDO = _n
merge 1:1 MERGE_DNI_CORREGIDO using "$Insumos/MERGE_DNI_CORREGIDO.dta", keepus(DNI_CORREGIDO) gen(_MERGE_DNI_CORREGIDO)
replace DNI = DNI_CORREGIDO if _MERGE_DNI_CORREGIDO == 3
drop MERGE_DNI_CORREGIDO _MERGE_DNI_CORREGIDO DNI_CORREGIDO

gen DNI_long1=strlen(DNI)
tab DNI_long1
drop if inlist(DNI_long1,1,4,9)
drop APELLIDOPATERNO
drop APELLIDOMATERNO
drop NOMBRES
drop DEPARTAMENTO
drop PROVINCIA
drop DIRECCION
drop DNI_long
drop DNI_long1

destring MESDESEMBOLSO, replace
destring AÑODESEMBOLSO, replace
replace tasadeinteres="" if tasadeinteres=="-"
destring tasadeinteres, replace
replace plazocreditomeses="" if plazocreditomeses=="-"
destring plazocreditomeses, replace
rename DNI N_DOC
duplicates r N_DOC
duplicates drop N_DOC, force

save "$Intermedio/AVN.dta", replace

*===============================================================================
* Combinando las bases
*===============================================================================

use "$Intermedio/BFH_corregido.dta", clear
keep if MODALIDAD=="ADQUISICIÓN DE VIVIENDA NUEVA"
merge m:1 N_DOC using "$Intermedio/AVN.dta", force

drop if ESTADO=="ANULADO"
drop if ESTADO=="BENEFICIARIO"
drop if ESTADO=="BENEFICIARIO EN REVISIÓN"
drop if ESTADO=="BENEFICIARIO POR DESEMBOLSAR"
drop if ESTADO=="DEVUELTO"
drop if ESTADO=="ELEGIBLE"
drop if ESTADO=="INSCRITO"
drop if ESTADO=="NO ELEGIBLE"
drop if ESTADO=="RENUNCIANTE"
drop if ESTADO=="RETIRADO"
drop if ESTADO=="TRÁMITE EN DEVOLUCIÓN"

*Tratados y controles
gen tratamiento=""
replace tratamiento="1" if ESTADO=="BENEFICIARIO DESEMBOLSADO"
replace tratamiento="0" if ESTADO=="CADUCADO"
destring tratamiento, replace

*Borrando vacios
drop if ESTADO==""

format FECHA_NACIMIENTO %tdDD/NN/CCYY
format FECHA_ELEGIBILIDAD %tdDD/NN/CCYY

*Generado edades
*EDAD titular
generate edad_titular=(FECHA_ELEGIBILIDAD-FECHA_NACIMIENTO)/365
order edad_titular, after (FECHA_NACIMIENTO)

*Edad conyuge
gen fecha_conyuge=date(CNY_FECHA_NACIMIENTO,"DMY")
format fecha_conyuge %tdDD/NN/CCYY
generate edad_conyuge=(FECHA_ELEGIBILIDAD-fecha_conyuge)/365
order fecha_conyuge, after (CNY_FECHA_NACIMIENTO)
order edad_conyuge, after (fecha_conyuge)

*Edad Miembro 1
gen fecha_miembro3=date(MIEMBRO3_FECHA_NACIMIENTO,"DMY")
format fecha_miembro3 %tdDD/NN/CCYY
generate edad_miembro3=(FECHA_ELEGIBILIDAD-fecha_miembro3)/365
order fecha_miembro3, after (MIEMBRO3_FECHA_NACIMIENTO)
order edad_miembro3, after (fecha_miembro3)

*Edad Miembro 2
gen fecha_miembro4=date(MIEMBRO4_FECHA_NACIMIENTO,"DMY")
format fecha_miembro4 %tdDD/NN/CCYY
generate edad_miembro4=(FECHA_ELEGIBILIDAD-fecha_miembro4)/365
order fecha_miembro4, after (MIEMBRO4_FECHA_NACIMIENTO)
order edad_miembro4, after (fecha_miembro4)

*Edad Miembro 3
gen fecha_miembro5=date(MIEMBRO5_FECHA_NACIMIENTO,"DMY")
format fecha_miembro5 %tdDD/NN/CCYY
generate edad_miembro5=(FECHA_ELEGIBILIDAD-fecha_miembro5)/365
order fecha_miembro5, after (MIEMBRO5_FECHA_NACIMIENTO)
order edad_miembro5, after (fecha_miembro5)

drop MODALIDAD
drop USUARIO_ELEGIBLE
drop CNY_FECHA_NACIMIENTO
drop MIEMBRO3_FECHA_NACIMIENTO
drop MIEMBRO4_FECHA_NACIMIENTO
drop MIEMBRO5_FECHA_NACIMIENTO

save "$Intermedio/AVN_merge.dta", replace

*Titular
rename N_DOC DNI_titular
rename AP_PATERNO paterno_titular
rename AP_MATERNO materno_titular
rename NOMBRE nombre_titular
rename FECHA_NACIMIENTO nacimiento_titular
rename SEXO sexo_titular
rename ESTADO_CIVIL estadocivil_titular
rename GRADO_INSTRUCCION instruccion_titular
rename OCUPACION ocupacion_titular
rename DISCAPACIDAD discapacidad_titular
*Conyuge
rename CNY_DNI DNI_conyuge
rename CNY_AP_PATERNO paterno_conyuge
rename CNY_AP_MATERNO materno_conyuge
rename CNY_NOMBRE nombre_conyuge
rename fecha_conyuge nacimiento_conyuge
rename CNY_SEXO sexo_conyuge
rename CNY_GRADO_INSTRUCCIÓN instruccion_conyuge
rename CNY_DISCAPACIDAD discapacidad_conyuge

*Miembro 1
rename MIEMBRO3_N_DOC DNI_miembro1
rename MIEMBRO3_AP_PATERNO paterno_miembro1
rename MIEMBRO3_AP_MATERNO materno_miembro1
rename MIEMBRO3_NOMBRE nombre_miembro1
rename fecha_miembro3 nacimiento_miembro1
rename edad_miembro3 edad_miembro1
rename MIEMBRO3_SEXO sexo_miembro1
rename MIEMBRO3_GRADO_INSTRUCCIÓN instruccion_miembro1
rename MIEMBRO3_DISCAPACIDAD discapacidad_miembro1

*Miembro 2
rename MIEMBRO4_N_DOC DNI_miembro2
rename MIEMBRO4_AP_PATERNO paterno_miembro2
rename MIEMBRO4_AP_MATERNO materno_miembro2
rename MIEMBRO4_NOMBRE nombre_miembro2
rename fecha_miembro4 nacimiento_miembro2
rename edad_miembro4 edad_miembro2
rename MIEMBRO4_SEXO sexo_miembro2
rename MIEMBRO4_GRADO_INSTRUCCION instruccion_miembro2
rename MIEMBRO4_DISCAPACIDAD discapacidad_miembro2

*Miembro 3
rename MIEMBRO5_N_DOC DNI_miembro3
rename MIEMBRO5_AP_PATERNO paterno_miembro3
rename MIEMBRO5_AP_MATERNO materno_miembro3
rename MIEMBRO5_NOMBRE nombre_miembro3
rename fecha_miembro5 nacimiento_miembro3
rename edad_miembro5 edad_miembro3
rename MIEMBRO5_SEXO sexo_miembro3
rename MIEMBRO5_GRADO_INSTRUCCION instruccion_miembro3
rename MIEMBRO5_DISCAPACIDAD dicapacidad_miembro3
rename dicapacidad_miembro3 discapacidad_miembro3

*Corrigiendo las demas base para que esté en formato numérico
*Conyuge
**SEXO
replace sexo_conyuge="1" if sexo_conyuge=="MASCULINO"
replace sexo_conyuge="0" if sexo_conyuge=="FEMENINO"
destring sexo_conyuge, replace
label define sexo_conyuge 1 "Masculino" 0 "Femenino"
label values sexo_conyuge sexo_conyuge
**GRADO DE INSRTUCCIÓN
replace instruccion_conyuge="1" if instruccion_conyuge=="SIN INSTRUCCION"
replace instruccion_conyuge="2" if instruccion_conyuge=="PRIMARIA"
replace instruccion_conyuge="3" if instruccion_conyuge=="SECUNDARIA"
replace instruccion_conyuge="4" if instruccion_conyuge=="TECNICO"
replace instruccion_conyuge="5" if instruccion_conyuge=="SUPERIOR"
destring instruccion_conyuge, replace
label define instruccion_conyuge 1 "Sin instrucción" 2 "Primaria" 3 "Secundaria" 4 "Técnico" 5 "Superior"
label values instruccion_conyuge instruccion_conyuge
**DISCAPACIDAD
replace discapacidad_conyuge="1" if discapacidad_conyuge=="SI"
replace discapacidad_conyuge="0" if discapacidad_conyuge=="NO"
destring discapacidad_conyuge, replace
label define discapacidad_conyuge 1 "Si" 0 "No"
label values discapacidad_conyuge discapacidad_conyuge
*****Miembro 1
**SEXO
replace sexo_miembro1="1" if sexo_miembro1=="MASCULINO"
replace sexo_miembro1="0" if sexo_miembro1=="FEMENINO"
destring sexo_miembro1, replace
label define sexo_miembro1 1 "Masculino" 0 "Femenino"
label values sexo_miembro1 sexo_miembro1
**GRADO DE INSRTUCCIÓN
replace instruccion_miembro1="1" if instruccion_miembro1=="SIN INSTRUCCION"
replace instruccion_miembro1="2" if instruccion_miembro1=="PRIMARIA"
replace instruccion_miembro1="3" if instruccion_miembro1=="SECUNDARIA"
replace instruccion_miembro1="4" if instruccion_miembro1=="TECNICO"
replace instruccion_miembro1="5" if instruccion_miembro1=="SUPERIOR"
destring instruccion_miembro1, replace
label define instruccion_miembro1 1 "Sin instrucción" 2 "Primaria" 3 "Secundaria" 4 "Técnico" 5 "Superior"
label values instruccion_miembro1 instruccion_miembro1
**DISCAPACIDAD
replace discapacidad_miembro1="1" if discapacidad_miembro1=="SI"
replace discapacidad_miembro1="0" if discapacidad_miembro1=="NO"
destring discapacidad_miembro1, replace
label define discapacidad_miembro1 1 "Si" 0 "No"
label values discapacidad_miembro1 discapacidad_miembro1

*****Miembro 2
**SEXO
replace sexo_miembro2="1" if sexo_miembro2=="MASCULINO"
replace sexo_miembro2="0" if sexo_miembro2=="FEMENINO"
destring sexo_miembro2, replace
label define sexo_miembro2 1 "Masculino" 0 "Femenino"
label values sexo_miembro2 sexo_miembro2
**GRADO DE INSRTUCCIÓN
replace instruccion_miembro2="1" if instruccion_miembro2=="SIN INSTRUCCION"
replace instruccion_miembro2="2" if instruccion_miembro2=="PRIMARIA"
replace instruccion_miembro2="3" if instruccion_miembro2=="SECUNDARIA"
replace instruccion_miembro2="4" if instruccion_miembro2=="TECNICO"
replace instruccion_miembro2="5" if instruccion_miembro2=="SUPERIOR"
destring instruccion_miembro2, replace
label define instruccion_miembro2 1 "Sin instrucción" 2 "Primaria" 3 "Secundaria" 4 "Técnico" 5 "Superior"
label values instruccion_miembro2 instruccion_miembro2
**DISCAPACIDAD
replace discapacidad_miembro2="1" if discapacidad_miembro2=="SI"
replace discapacidad_miembro2="0" if discapacidad_miembro2=="NO"
destring discapacidad_miembro2, replace
label define discapacidad_miembro2 1 "Si" 0 "No"
label values discapacidad_miembro2 discapacidad_miembro2

*****Miembro 3
**SEXO
replace sexo_miembro3="1" if sexo_miembro3=="MASCULINO"
replace sexo_miembro3="0" if sexo_miembro3=="FEMENINO"
destring sexo_miembro3, replace
label define sexo_miembro3 1 "Masculino" 0 "Femenino"
label values sexo_miembro3 sexo_miembro3
**GRADO DE INSRTUCCIÓN
replace instruccion_miembro3="1" if instruccion_miembro3=="SIN INSTRUCCION"
replace instruccion_miembro3="2" if instruccion_miembro3=="PRIMARIA"
replace instruccion_miembro3="3" if instruccion_miembro3=="SECUNDARIA"
replace instruccion_miembro3="4" if instruccion_miembro3=="TECNICO"
replace instruccion_miembro3="5" if instruccion_miembro3=="SUPERIOR"
destring instruccion_miembro3, replace
label define instruccion_miembro3 1 "Sin instrucción" 2 "Primaria" 3 "Secundaria" 4 "Técnico" 5 "Superior"
label values instruccion_miembro3 instruccion_miembro3
**DISCAPACIDAD
replace discapacidad_miembro3="1" if discapacidad_miembro3=="SI"
replace discapacidad_miembro3="0" if discapacidad_miembro3=="NO"
destring discapacidad_miembro3, replace
label define discapacidad_miembro3 1 "Si" 0 "No"
label values discapacidad_miembro3 discapacidad_miembro3

save "$Intermedio/AVN_merge1.dta", replace
