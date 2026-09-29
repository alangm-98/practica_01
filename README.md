# Práctica 1 – Computación Distribuida 2027-1

Búsqueda de números primos con la criba de Eratóstenes, distribuyendo el trabajo entre procesos.

## Integrantes

- Cisneros Álvarez Danjiro
- Flores Juarez Luis Enrique
- García Morales Carlos Alan
- Jimenez Rivera Emiliano Kaleb
- Montijo Díaz Omar

## Ejecución

```bash
mix compile
iex -S mix
```

Dentro de `iex`:

```elixir
# Primos menores o iguales a 40 con 4 trabajadores
PrimesFinder.range(40, 4)

# Experimentos con 1, 2, 4, 8 y 16 trabajadores
PrimesFinder.experimentos()
```

Los resultados se guardan en `primes.txt` y `times.txt`.

## Archivos

| Archivo                | Contenido                                     | Sección               |
| ---------------------- | --------------------------------------------- | --------------------- |
| `lib/algebra.ex`       | Criba de Eratóstenes                          | 2.1                   |
| `lib/worker.ex`        | Proceso trabajador                            | Procesos trabajadores |
| `lib/server.ex`        | Proceso coordinador                           | 2.2                   |
| `lib/primes_finder.ex` | Ejecución, medición de tiempos y experimentos | 2.3, 2.6              |
