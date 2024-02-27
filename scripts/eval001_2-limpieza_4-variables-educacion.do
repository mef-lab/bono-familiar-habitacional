/*##############################################################################
PROYECTO:
	> Bono Familiar Habitacional 
OBJETIVO:
	> Genera la base final para el análisis de los resultados de educación.
BASES DE INSUMOS:
	> BBDD procesada del BFH ("$Intermedio/AVN_merge1v3.dta")
	> BBDD procesada del SIAGIE ("$Intermedio/maestro_siagie_bono.dta")
	> SIAGIE ("$Intermedio/siagie_####.dta" - "$Intermedio/siagie_####_nue.dta")
	> Registro de docentes de EBR ("$Insumos/docente2014_2022.dta")
	> Base de deserción interanual ("$Intermedio/tmp_desercion_dni_year.dta")
BASES CREADAS:
	> "$Producto/siagie_bono_final.dta"
AUTORES:
	> Richar Quispe (@mef.gob.pe)
		> Dirección General de Presupuesto Público
		> Dirección de Calidad de Gasto Público
		> Coordinación de Evaluaciones Independientes
SOFTWARE:
	> Stata 17
##############################################################################*/
*===============================================================================
* Generando variable de resultados
*===============================================================================

*-------------------------------------------------------------------------------
* Generando notas estandarizadas y normalizadas
*-------------------------------------------------------------------------------
* Transformación de las notas
forval t = 2014(1)2019{
	use "$Intermedio/siagie_`t'.dta", clear
	merge 1:1 dni using "$Intermedio/maestro_siagie_bono.dta"
	keep if _merge==3
	destring edad, force replace
	destring cod_mod, force replace
	save "$Intermedio/siagie_`t'_merge.dta", replace
}

forval t = 2014(1)2016{
	use "$Intermedio/siagie_`t'_merge.dta", clear
	gen id_sección=.
	save "$Intermedio/siagie_`t'_merge.dta", replace
}

forval t = 2017(1)2019{
	use "$Intermedio/siagie_`t'_merge.dta", clear
    rename situación_matrícula situacion_matricula
    rename gestión gestion	
	save "$Intermedio/siagie_`t'_merge.dta", replace
}

forvalues t=2014/2019 {
	use "$Intermedio/siagie_`t'_merge.dta", clear
	
	*---------------------------------------------------------------------------
	* Comunicacion
	*---------------------------------------------------------------------------
	replace comunicacion="AD" if comunicacion=="A D"
	replace comunicacion="AD" if comunicacion=="DA"
	replace comunicacion="A" if comunicacion=="AA"
	replace comunicacion="C" if comunicacion=="CC"
	replace comunicacion="A" if comunicacion=="a"
	
	gen comunicacion_nota=.
	replace comunicacion_nota=4 if comunicacion=="AD"
	replace comunicacion_nota=3 if comunicacion== "A"
	replace comunicacion_nota=2.5 if comunicacion=="B"
	replace comunicacion_nota=1 if comunicacion=="C"
	
	gen nota=.
	replace nota=1 if comunicacion=="AD"
	replace nota=1 if comunicacion=="A"
	replace nota=1 if comunicacion=="B"
	replace nota=1 if comunicacion=="C"
	destring comunicacion, force replace
	replace nota=0 if comunicacion>0 & !missing(comunicacion)
	// ==1 si comunicacion es alfabetico, ==0 si comunicacion es numerico, ==. si no comunicacion
	
	recode comunicacion (0/10=1 "C") (11/14=2 "B") (15/18=3 "A") (19/20=4 "AD"), gen(comunicacion_recode)
	replace comunicacion_recode=2.5 if comunicacion_recode==2
	replace comunicacion_nota=comunicacion_recode if comunicacion_nota==.
	drop comunicacion_recode
	
	*---------------------------------------------------------------------------
	* Matemática
	*---------------------------------------------------------------------------
	replace matematica="AD" if matematica=="A D"
	replace matematica="AD" if matematica=="AAD"
	replace matematica="AD" if matematica=="D"
	
	gen matematica_nota=.
	replace matematica_nota=4 if matematica=="AD"
	replace matematica_nota=3 if matematica=="A"
	replace matematica_nota=2.5 if matematica=="B"
	replace matematica_nota=1 if matematica=="C"
	destring matematica, force replace
	
	recode matematica (0/10=1 "C") (11/14=2 "B") (15/18=3 "A") (19/20=4 "AD"), gen(matematica_recode)
	replace matematica_recode=2.5 if matematica_recode==2
	replace matematica_nota=matematica_recode if matematica_nota==.
	drop matematica_recode
	
	*---------------------------------------------------------------------------
	* Promedio
	*---------------------------------------------------------------------------
	gen promedio=(comunicacion_nota+matematica_nota)/2
	
	keep id_anio departamento provincia distrito gestion id_grado id_sección dni DNI_titular edad sexo turno situacion_matricula cod_mod comunicacion comunicacion_nota matematica matematica_nota promedio nota
	save "$Intermedio/siagie_`t'_merge.dta", replace 
}

*===============================================================================
* Generar variable tratamiento
*===============================================================================
use "$Intermedio/AVN_merge1v3.dta", clear
sort DNI_titular mo_order
drop if AÑODESEMBOLSO==2019
drop if AÑODESEMBOLSO==2020
drop if AÑODESEMBOLSO==2021
drop if AÑODESEMBOLSO==2022
drop if AÑODESEMBOLSO==2023
rename tratamiento_nuevo tratamiento_bono
keep dni DNI_titular f_nacimiento FECHADESEMBOLSO MESDESEMBOLSO AÑODESEMBOLSO INGRESO_FAMILIAR NSE tratamiento_bono ESTADO ESTADOACTUALDEGF ANIO_POSTULACION
gen id_anio_nuevo=AÑODESEMBOLSO+1 if ESTADO=="BENEFICIARIO DESEMBOLSADO"
sort DNI_titular
bysort DNI_titular: gen seq=_n
keep if seq==1
save "$Intermedio/tratamiento_merge.dta", replace

*===============================================================================
* Combinar bases
*===============================================================================
use "$Intermedio/siagie_2014_merge.dta", clear
forvalues t = 2015(1)2019{
	append using "$Intermedio/siagie_`t'_merge.dta", force
}

forvalues t = 2014(1)2019{
	erase "$Intermedio/siagie_`t'_merge.dta"
}
replace edad=edad_31_marzo if edad_31_marzo>0 & !missing(edad_31_marzo)
order DNI_titular dni id_anio id_grado
sort dni id_anio id_grado

drop if id_grado==1
drop if id_grado==2
drop if id_grado==3
drop if id_grado==.
drop if edad<4
drop if edad>20

* Normalizando las notas
egen stdcom_nuevo=std(comunicacion) if nota==0
egen stdcom_nuevo1=std(comunicacion_nota) if nota==1
replace stdcom_nuevo1=stdcom_nuevo if stdcom_nuevo1==.
drop stdcom_nuevo
egen stdmate_nuevo=std(matematica) if nota==0
egen stdmate_nuevo1=std(matematica_nota) if nota==1
replace stdmate_nuevo1=stdmate_nuevo if stdmate_nuevo1==.
drop stdmate_nuevo

* Combinar con variable de tratamiento
merge m:1 DNI_titular using "$Intermedio/tratamiento_merge.dta", keepus(id_anio_nuevo tratamiento_bono INGRESO_FAMILIAR NSE ESTADO ESTADOACTUALDEGF ANIO_POSTULACION AÑODESEMBOLSO)
keep if _merge==3
replace id_anio_nuevo=. if id_anio_nuevo>2019
tab id_anio_nuevo
gen resta=id_anio_nuevo - id_anio
gen tratamiento=1 if resta<1
replace tratamiento=0 if tratamiento==.
drop resta
erase "$Intermedio/tratamiento_merge.dta"
order DNI_titular dni id_anio id_grado
sort dni id_anio id_grado
replace tratamiento=0 if ESTADOACTUALDEGF=="DEVUELTO"

*-------------------------------------------------------------------------------
* Generar variables de control
*-------------------------------------------------------------------------------
replace sexo=trim(itrim(sexo))
replace sexo="1" if sexo=="HOMBRE"
replace sexo="0" if sexo=="MUJER"
destring sexo, replace
label define sexo 1 "Hombre" 0 "Mujer"
label values sexo sexo

egen sexo1=min(sexo), by(dni)
bro if sexo1!=sexo
merge m:1 dni using "$Insumos/DNI_MERGE_DROP.dta", keep(1) nogen

replace situacion_matricula=trim(itrim(situacion_matricula))
replace situacion_matricula="1" if situacion_matricula=="INGRESANTE"
replace situacion_matricula="2" if situacion_matricula=="PROMOVIDO"
replace situacion_matricula="3" if situacion_matricula=="REENTRANTE"
replace situacion_matricula="4" if situacion_matricula=="REINGRESANTE"
replace situacion_matricula="5" if situacion_matricula=="REPITE"
destring situacion_matricula, replace
label define situacion_matricula 1 "INGRESANTE" 2 "PROMOVIDO" 3 "REENTRANTE" 4 "REINGRESANTE" 5 "REPITE"
label values situacion_matricula situacion_matricula

gen gestión=.
replace gestión=1 if gestion=="Privada"
replace gestión=2 if gestión==.
label define gestión 1 "Privado" 2 "Público"
label values gestión gestión

gen macrodep=.
replace macrodep=1 if departamento=="AMAZONAS" | departamento=="PIURA" | departamento=="LAMBAYEQUE"  | departamento=="LA LIBERTAD" | departamento=="CAJAMARCA" | departamento=="SAN MARTIN" | departamento=="TUMBES" 
replace macrodep=2 if departamento=="ANCASH" | departamento=="UCAYALI" | departamento== "JUNIN" | departamento=="HUANUCO" | departamento=="PASCO" | departamento=="HUANCAVELICA"
replace macrodep=3 if departamento=="ICA" | departamento=="AREQUIPA" | departamento=="MOQUEGUA"  | departamento=="TACNA" 
replace macrodep=4 if departamento=="CUSCO" | departamento=="PUNO" | departamento=="AYACUCHO"  | departamento=="MADRE DE DIOS" | departamento=="APURIMAC"
replace macrodep=5 if departamento=="LORETO" 
replace macrodep=6 if departamento=="CALLAO" | departamento=="LIMA" 

label value macrodep macrodep
label var macrodep "Macro regiones"
# delimit ; 
label define macrodep 
1 "Macroregión Nor Oeste" 2 "Macroregión Centro" 
3 "Macroregión Sur Oeste" 4 "Macroregión Sur Este" 
5 "Macroregión Nor Este" 6 "Macroregión Lima" ;
# delimit cr

tab tratamiento_bono tratamiento
order edad, after(edad_31_marzo)
drop edad_31_marzo

save "$Intermedio/siagie_bono_final.dta", replace

*-------------------------------------------------------------------------------
* Completando los id_sección
*-------------------------------------------------------------------------------
use "$Intermedio/siagie_bono_final.dta", clear
drop _merge
merge 1:1 id_anio dni using "$Insumos/siagie_2014_nue.dta", keepus (id_sección2014)
keep if (_merge==1|_merge==3) 
save "$Intermedio/siagie_bono_final.dta", replace

drop _merge
merge 1:1 id_anio dni using "$Insumos/siagie_2015_nue.dta", keepus (id_sección2015)
keep if (_merge==1|_merge==3)
drop _merge
save "$Intermedio/siagie_bono_final.dta", replace

merge 1:1 id_anio dni using "$Insumos/siagie_2016_nue.dta", keepus (id_sección2016)
keep if (_merge==1|_merge==3)
drop _merge
save "$Intermedio/siagie_bono_final.dta", replace

use "$Intermedio/siagie_bono_final.dta", clear
replace id_sección=id_sección2014 if id_sección2014>0 & !missing(id_sección2014)
replace id_sección=id_sección2015 if id_sección2015>0 & !missing(id_sección2015)
replace id_sección=id_sección2016 if id_sección2016>0 & !missing(id_sección2016)

drop id_sección2014
drop id_sección2015
drop id_sección2016
drop if id_sección==.
save "$Intermedio/siagie_bono_final.dta", replace


*===============================================================================
* Uniendo la Deserción interanual
*===============================================================================
* Se ha contruido una base aparte, se hizo seguimiento cada año a cada estudiante y cuando este no aparece en el año siguiente se considera como deserción interanual, bajo ciertos supuesto
* Metodología propuesta en ESCALE - MINEDU
use "$Intermedio/siagie_bono_final.dta", clear
merge 1:1 dni id_anio using "$Intermedio/tmp_desercion_dni_year.dta"
replace desercion=0 if _merge==1
drop if _merge==2
drop _merge
save "$Intermedio/siagie_bono_final.dta", replace

*===============================================================================
* Uniendo docentes de comunicación y matemática
*===============================================================================
* Docentes de matemática
use "$Insumos/docente2014_2022.dta", clear
destring numero_documento, force replace
destring id_seccion, force replace
keep if asignatura=="MATEMÁTICA"
rename codigo_modular cod_mod
rename id_seccion id_sección
duplicates drop id_anio cod_mod id_grado id_sección, force
save "$Intermedio/docente2014_2022_mate.dta", replace

* Docentes de comunicación
use "$Insumos/docente2014_2022.dta", clear
destring numero_documento, force replace
destring id_seccion, force replace
keep if asignatura=="COMUNICACIÓN"
rename codigo_modular cod_mod
rename id_seccion id_sección
duplicates drop id_anio cod_mod id_grado id_sección, force
save "$Intermedio/docente2014_2022_comu.dta", replace

use "$Intermedio/siagie_bono_final.dta", clear
drop _merge
merge m:1 id_anio cod_mod id_grado id_sección using "$Intermedio/docente2014_2022_mate.dta", keepus(numero_documento) keep(1 3) nogen
rename numero_documento dni_matematica
merge m:1 id_anio cod_mod id_grado id_sección using "$Intermedio/docente2014_2022_comu.dta", keepus(numero_documento) keep(1 3) nogen
rename numero_documento dni_comunicacion
erase "$Intermedio/docente2014_2022_mate.dta"
erase "$Intermedio/docente2014_2022_comu.dta"
sort DNI_titular dni id_anio id_grado
save "$Intermedio/siagie_bono_final.dta", replace

* Mejorando la data de docentes

forvalues t =2017(1)2019{
	use "$Intermedio/siagie_bono_final.dta", clear
	merge 1:1 id_anio dni using "$Intermedio/siagie_`t'.dta", keepus(dnideldocentetutor)
	destring dnideldocentetutor, force replace
	rename dnideldocentetutor docente`t'
	drop if _merge==2
	drop _merge
	save "$Intermedio/siagie_bono_final.dta", replace
}

replace docente2017=. if id_grado>9
replace docente2018=. if id_grado>9
replace docente2019=. if id_grado>9

replace dni_matematica=docente2017 if dni_matematica==.
replace dni_comunicacion=docente2017 if dni_comunicacion==.
replace dni_matematica=docente2018 if dni_matematica==.
replace dni_comunicacion=docente2018 if dni_comunicacion==.
replace dni_matematica=docente2019 if dni_matematica==.
replace dni_comunicacion=docente2019 if dni_comunicacion==.

replace dni_matematica=docente2017 if docente2017>0 & !missing(docente2017)
replace dni_comunicacion=docente2017 if docente2017>0 & !missing(docente2017)
replace dni_matematica=docente2018 if docente2018>0 & !missing(docente2018)
replace dni_comunicacion=docente2018 if docente2018>0 & !missing(docente2018)
replace dni_matematica=docente2019 if docente2019>0 & !missing(docente2019)
replace dni_comunicacion=docente2019 if docente2019>0 & !missing(docente2019)

replace dni_comunicacion=dni_matematica if dni_comunicacion==. & id_grado<10
replace dni_matematica=dni_comunicacion if dni_matematica==. & id_grado<10

replace dni_comunicacion=dni_matematica if dni_comunicacion>0 & id_grado<10
replace dni_matematica=dni_comunicacion if dni_matematica>0 & id_grado<10

drop docente*
drop resta3
drop resta4
drop gestion

** Se está creando una variable ficticia para completar los espacios vacíos, para el caso de primaria se repiten el docente al ser el mismo y para secundaria si se está diferenciando para comunicación y matemática.

gen ficticio=9999999999
replace dni_matematica=ficticio if dni_matematica==.
replace dni_comunicacion=ficticio if dni_comunicacion==.

*===============================================================================
* Base Final
*===============================================================================
save "$Producto/siagie_bono_final.dta", replace

keep dni id_anio desercion tratamiento id_grado gestión edad sexo1 DNI_titular cod_mod dni_comunicacion dni_matematica nota stdcom_nuevo1 stdmate_nuevo1
foreach v of varlist dni DNI_titular dni_comunicacion dni_matematica cod_mod {
	egen _`v' = group(`v')
	drop `v'
	rename _`v' `v'
}
compress
order dni id_anio
sort dni id_anio

export delimited "$Producto/FINAL_EDUC.csv", replace nolabel
