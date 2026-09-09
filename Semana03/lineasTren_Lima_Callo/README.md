# Consulta Metro de Lima y Callao (Swift)

Sistema de consulta académico, desarrollado en Swift para ejecutarse en terminal, sobre la Red Básica del Metro de Lima y Callao (Líneas 1 a 6). El proyecto es de magnitud reducida y no pretende representar toda la infraestructura real del Metro de Lima — es una abstracción del dominio suficiente para resolver los dos requerimientos funcionales planteados.

## Requerimientos funcionales

### RF-01 — Consultar estaciones de una línea

El usuario ingresa el identificador de una línea (por ejemplo, `Línea 1`). El sistema devuelve las estaciones registradas para esa línea.

Comportamiento esperado:

- Si la línea existe y tiene estaciones registradas → se listan en orden de recorrido.
- Si la línea existe pero aún no tiene estaciones definidas (líneas proyectadas, sin trazado oficial aprobado) → se indica explícitamente que está registrada pero sin estaciones definidas.
- Si el identificador no corresponde a ninguna línea del dominio → se indica que la línea no está registrada.

Implementado en `estacionesDeLinea(_:)` y presentado al usuario mediante `mensajeParaConsultaLinea(_:)`.

### RF-02 — Consultar correspondencia entre dos líneas

El usuario ingresa dos identificadores de línea. El sistema busca si existe un punto de correspondencia (transbordo) documentado entre ambas.

Comportamiento esperado:

- Si existe una correspondencia registrada → se devuelve la estación de cada línea que forma el punto de transbordo, junto con su estado (operativa o proyectada).
- Si no existe correspondencia registrada entre las dos líneas → se indica explícitamente que no se encontró.
- Si ambos identificadores corresponden a la misma línea → se indica que no es una consulta válida (no tiene sentido buscar correspondencia de una línea consigo misma).
- Si alguno de los identificadores no está registrado → se indica cuál no existe.

Implementado en `correspondenciaEntre(_:_:)` y presentado al usuario mediante `mensajeParaCorrespondencia(_:_:)`.

**Nota de diseño importante:** la correspondencia no se calcula por coincidencia de nombres de estación entre líneas (eso sería confundir intersección geográfica del recorrido con punto real de transbordo). Se mantiene un conjunto explícito y documentado de correspondencias conocidas, independiente de los arrays de estaciones de cada línea.

## Alcance de los datos

| Línea | Estado | Estaciones |
|---|---|---|
| Línea 1 | Operativa | 26, confirmadas por múltiples fuentes |
| Línea 2 | En construcción | 27 planificadas; solo 5 operativas hoy (Evitamiento, Óvalo Santa Anita, Colectora Industrial, Hermilio Valdizán, Mercado Santa Anita) |
| Línea 3 | Proyectada | Sin estaciones oficiales definidas |
| Línea 4 | Proyectada | Sin estaciones oficiales definidas |
| Línea 5 | Proyectada | Sin estaciones oficiales definidas |
| Línea 6 | Proyectada | Sin estaciones oficiales definidas |

La correspondencia registrada entre Línea 1 (estación Gamarra) y Línea 2 (estación 28 de Julio) corresponde a una estación de interconexión anunciada oficialmente pero **aún no construida** — se modela con estado `.proyectada`, no como transbordo operativo actual.

Marco legal de referencia: Red Básica del Metro de Lima y Callao, aprobada mediante Decreto Supremo N° 059-2010-MTC, ampliada posteriormente a seis líneas.

## Ejecución

El programa incluye un menú interactivo por terminal con tres opciones: consultar estaciones de una línea, consultar correspondencia entre dos líneas, y salir. Requiere una terminal con entrada estándar interactiva (no funciona dentro del editor de Swift Playgrounds en iPad, que no soporta `readLine()`).
