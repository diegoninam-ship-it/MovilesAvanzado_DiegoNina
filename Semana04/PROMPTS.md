# Prompts utilizados — Laboratorio 04

## Herramienta de IA utilizada
Claude

## Caso 2B — Biblioteca

### Prompt 1:
CONTEXTO: Soy estudiante de Swift, cuarta semana, trabajo en un Playground de Xcode.
TAREA: Necesito una biblioteca con enum EstadoLibro, struct Libro y class Biblioteca
con prestar, devolver e inventario.
RESTRICCIONES: Solo struct, class, herencia, protocolos, enums, arrays, bucles y
funciones. Sin optionals ni guard let, sin firstIndex(where:), sin didSet, sin
propiedades calculadas, sin genéricos. Búsqueda con for i in 0..<libros.count.
FORMATO: Solo el código Swift, con las firmas exactas indicadas.
EJEMPLO: [salida esperada de la Parte A]

### Respuesta de la IA:
Generó el enum, el struct y la clase con las firmas correctas, pero implementó
prestar(titulo:) y devolver(titulo:) usando firstIndex(where:) y if let en vez
del bucle por índice pedido explícitamente en las restricciones.

### ¿Funcionó a la primera?
No — usó firstIndex(where:) e if let a pesar de la restricción. Prompt de corrección:
"Reescribe prestar(titulo:) y devolver(titulo:) sin firstIndex(where:) ni if let.
Usa exactamente for i in 0..<libros.count como indiqué en las restricciones."

### ¿Usó algo que no hemos visto en clase?
Sí — firstIndex(where:) (closures) e if let (optionals), ambos temas de semanas
posteriores según el propio PDF del laboratorio. Se pidió reescritura y la IA
corrigió al bucle por índice.

## Mi versión (Parte A) vs. la versión de la IA (Parte B)

### ¿Qué hizo distinto la IA respecto a mi solución?
En el primer intento, resolvió la búsqueda con una closure (firstIndex(where:))
en vez de un bucle for con índice. Tras la corrección, la lógica quedó
estructuralmente idéntica a mi Parte A.

### ¿Hay alguna línea de la IA que no entiendo del todo? ¿Cuál?
[Completar según tu experiencia real]

### ¿Qué me pareció mejor de MI versión?
El bucle por índice deja explícito por qué se recorre así: porque Libro es un
struct y hay que modificar el elemento dentro del array, no una copia.

### ¿Qué me pareció mejor de la versión de la IA?
[Completar según tu experiencia real]