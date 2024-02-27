/*##############################################################################
PROYECTO:
	> Bono Familiar Habitacional 
OBJETIVO:
	> Guarda las bases de insumo en el formato adecuado.
BASES DE INSUMOS:
	> Registro administrativo del BFH ("$Insumos/####.xlsx")
	> Registro administrativo de beneficiarios del BFH ("$Insumos/Desembolsos AVN historico.xlsx")
BASES CREADAS:
	> "$Intermedio/BFH.dta"
	> "$Intermedio/AVN_INICIAL.dta"
AUTORES:
	> Richar Quispe (@mef.gob.pe)
		> Dirección General de Presupuesto Público
		> Dirección de Calidad de Gasto Público
		> Coordinación de Evaluaciones Independientes
SOFTWARE:
	> Stata 17
##############################################################################*/
*-------------------------------------------------------------------------------
* Registro administrativo del BFH
*-------------------------------------------------------------------------------
forval t = 2003(1)2023{
	import excel using "$Insumos/`t'.xlsx", sheet("Select tblfrm_formulario") firstrow clear
	save "$Intermedio/`t'.dta", replace
}
use "$Intermedio/2003.dta", clear
forval t = 2004(1)2023{
	append using "$Intermedio/`t'.dta", force
	erase "$Intermedio/`t'.dta"
}
erase "$Intermedio/2003.dta"
save "$Intermedio/BFH.dta", replace

*-------------------------------------------------------------------------------
* Registro administrativo de beneficiarios del BFH
*-------------------------------------------------------------------------------
import excel using "$Insumos/Desembolsos AVN historico.xlsx", sheet("Completo") firstrow clear
save "$Intermedio/AVN_INICIAL.dta", replace



