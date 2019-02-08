//Taller de Stata para el análisis de datos
//Stata es un software para análisis y manejo de datos 
//
//Importar bases de datos 

                     //Variables//
///Para crear una variable 
//Utilizamos gen cuando tienes una variable simple para crear, probablmente con información de otras variables 
gen nom_var=. 
//Utilizamos egen cuando generamos variables que llevan funciones en la instrucción 
ege max_var= max(var) 					 
//Etiquetas 
//Utilizamos etiquetas para definir variables en la memoria de nuestras bases de datos 
import delimited /Users/AmaliaPulido/Downloads/conjunto_de_datos_ENSU_2018_4t_csv/conjunto_de_datos_cb_ensu_04_2018/conjunto_de_datos/conjunto_de_datos_cb_ENSU_04_2018.csv, bindquote(strict) numericcols(_all) clear
//La opción de bindquotes(loose|strict|nobind), en ocasiones hay que especificar bindquotes(strict) por las comillas y el lenguaje de las bases de datos 
//La opción numericcols(_all) indica que quiero tratar toda a bas como numérica
//Valores pérdidos, stata toma como . los valores perdidos. 
//Para renombrar variables utilizamos el comando rename 
rename ïupm unidad_prim_mues
// Para poner una etiqueta a la base de datos 
label data "Encuesta Nacional de Seguridad Pública Urbana"
// Etiquetas en variables 
label variable bp1_1 "vivir en su ciudad es" 
//Generar etiqueta 
label define valores 1 "seguro" 2"inseguro" 9 "no sabe" 
//asignar etiqueta a variable 
label values bp1_1 valores 
//me interesa la variable sobre desempeño gubernamental 
 rename bp2_3_2 desempeño 
label variable desempeño "el gobiernoha sido efectivo para resolver problemas" 
label define desemval 1 "muy efectivo" 2 "algo efectivo" 3 "poco efectivo" 4 "nada efectivo" 9 "no sabe" 
label values desempeño desemval 
//Importar datos desde excel 
import excel "/Users/AmaliaPulido/Downloads/homicidios.xlsx", sheet("Hoja1") firstrow
 //Cambiar formato de datos 
 //Cuando quiero cambinar long to wide, necesito generar un identificador, puedo crear un loop para agregar hom a todas las variables 
 foreach x of var * { 
 rename `x' hom_`x' 
 }
 drop hom_Total 
 //Reshape: necesitamos saber la estructura de nuestros datos 
 reshape long hom_, i(año) j(edo)
 reshape long hom_, i(año) j(edo, string)
 //La diferencia es que en el segundo comando le estamos diciendo a stata que tenemos una variable con con caracteres 
 //Generar un id para cada Estado 
 egen id = group( edo)
 //Guardo la base 
 //Importo datos sobre población 
 import excel "/Users/AmaliaPulido/Downloads/poblacion.xlsx", sheet("Poblacion_01") firstrow clear
rename B pob_1990
rename C pob_1995
rename D pob_2000
rename E pob_2005
rename F pob_2010
reshape long pob_, i(Id) j(año)
drop if Id=="Estados Unidos Mexicanos"
 egen id = group( Id)
//Guardo base 
//Abro mi base de homicidios y la limpio ya que no tengo datos de población para cada año 
keep if año==1990 | año==1995 | año==2000 | año==2005 | año==2010
//Combino bases 
merge m:m año id using "/Volumes/APG/Taller R/poblacion.dta"
//Genero una variable sobre la tasa de homicidios por cada 100000 habitantes
gen tasa_hom=(hom_ / pob) *100000
// Gráfico los datos 
twoway (line tasa_hom id), by(año)



