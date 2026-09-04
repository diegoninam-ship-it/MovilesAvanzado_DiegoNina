# Prompts — Lab 03
## Docente: Juan Leon — Tecsup
## Herramienta: Claude

## Ejercicio 6 — Gestión de notas
### Prompt (CTRFE):

**CONTEXTO:** Estudiante de iOS en semana 3 del curso Programación en Móviles
Avanzado, trabajando con Swift. Se conocen hasta ahora: Arrays, Diccionarios,
Sets, bucles for, readLine(), Optionals con if let, y switch básico.

**TAREA:** Generar un sistema de gestión de notas que:
1. Pida N alumnos con nombre y 3 notas cada uno, guardados en un
   diccionario [String: [Double]]
2. Calcule el promedio de cada alumno y lo clasifique con switch
   (Excelente/Bueno/Aprobado/Desaprobado)
3. Calcule estadísticas generales: promedio de la clase, nota más alta,
   nota más baja, y porcentaje de aprobados
4. Ordene y muestre el ranking de alumnos por promedio, de mayor a menor

**RESTRICCIONES:** Solo usar conceptos de las semanas 1-3 (sin struct,
sin class, sin protocolos). Comentar cada línea del código explicando
qué hace.

**FORMATO:** Código Swift completo con un comentario específico en
CADA línea (no comentarios genéricos).

**EJEMPLO:** Basarse en el estilo del ejercicio resuelto de contactos
(diccionario [String: String]) provisto en el material del lab, pero
aplicado a un diccionario de arrays [String: [Double]].


## Ejercicio 7 — Inventario con menú
### Prompt (CTRFE):

**CONTEXTO:** Estudiante de iOS en semana 3 del curso Programación en Móviles
Avanzado, trabajando con Swift. Ya se completó el Ejercicio 6 (diccionarios
y clasificación con switch). Se conocen: Arrays, Diccionarios, bucles for,
while, readLine(), Optionals con if let, switch.

**TAREA:** Generar un sistema de inventario con menú interactivo que:
1. Pida N productos con nombre, precio y stock, guardados en 3 arrays
   paralelos (nombres, precios, stocks)
2. Muestre un menú while con 5 opciones: Ver inventario, Buscar producto,
   Stock bajo, Valor total, Salir
3. El menú se repite hasta que el usuario elija la opción 5
4. Cada opción imprime un reporte formateado

**RESTRICCIONES:** Solo usar conceptos de las semanas 1-3 (sin struct,
sin class). Comentar cada línea del código explicando qué hace.

**FORMATO:** Código Swift completo con un comentario específico en
CADA línea (no comentarios genéricos).

**EJEMPLO:** Basarse en el patrón de arrays paralelos usado en el
Carrito de Compras 2.0 (Ejercicio 5), pero con lógica de menú (while +
switch) en vez de flujo lineal.