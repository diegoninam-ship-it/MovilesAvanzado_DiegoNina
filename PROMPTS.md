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