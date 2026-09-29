# Módulo que funciona como interfaz para ejecutar la búsqueda de primos.
# Mide el tiempo de ejecución y guarda los resultados en archivos de texto.
defmodule PrimesFinder do
  # Archivos donde se guardan los resultados (se crean en la carpeta del proyecto)
  @archivo_primos "primes.txt"
  @archivo_tiempos "times.txt"

  # Función que ejecuta la búsqueda de primos menores o iguales a N con el número de trabajadores dado.
  # Mide el tiempo de ejecución, guarda los primos y el tiempo en archivos, y regresa la lista de primos.
  def range(n, num_trabajadores) do
    # Medimos el tiempo de todo Server.start (primos base, creación de procesos, mensajes, combinación y orden).
    # :timer.tc regresa el tiempo en microsegundos junto con el resultado de la función
    {tiempo_us, primos} = :timer.tc(fn -> Server.start(num_trabajadores, n) end)

    # Convertimos el tiempo a milisegundos
    tiempo_ms = tiempo_us / 1000

    # Guardamos los resultados (fuera de la medición, para no contar la escritura de archivos)
    guarda_primos(primos)
    guarda_tiempo(n, num_trabajadores, tiempo_ms)

    primos
  end

  # Función auxiliar: escribe la lista de primos en su archivo, reemplazando el contenido anterior
  defp guarda_primos(primos) do
    File.write!(@archivo_primos, Enum.join(primos, ", ") <> "\n")
  end

  # Función auxiliar: agrega una línea con N, el número de trabajadores y el tiempo al archivo de tiempos.
  # Se usa :append para conservar el registro de las ejecuciones anteriores
  defp guarda_tiempo(n, num_trabajadores, tiempo_ms) do
    linea = "N: #{n}, Trabajadores: #{num_trabajadores}, Tiempo: #{tiempo_ms} ms\n"
    File.write!(@archivo_tiempos, linea, [:append])
  end
end
