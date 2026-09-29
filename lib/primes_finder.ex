# Módulo que funciona como interfaz para ejecutar la búsqueda de primos.
# Mide el tiempo de ejecución, guarda los resultados en archivos de texto y ejecuta los experimentos.
defmodule PrimesFinder do
  # Archivos donde se guardan los resultados (se crean en la carpeta del proyecto)
  @archivo_primos "primes.txt"
  @archivo_tiempos "times.txt"

  # Valores por defecto de los experimentos: límites N, número de trabajadores y repeticiones por medición
  @valores_n [10_000, 100_000, 1_000_000, 2_000_000]
  @trabajadores [1, 2, 4, 8, 16]
  @repeticiones 5

  # Función que ejecuta la búsqueda de primos menores o iguales a N con el número de trabajadores dado.
  # Mide el tiempo de ejecución, guarda los primos y el tiempo en archivos, y regresa la lista de primos.
  def range(n, num_trabajadores) do
    # Medimos el tiempo de la búsqueda completa
    {tiempo_ms, primos} = mide(n, num_trabajadores)

    # Guardamos los resultados (fuera de la medición, para no contar la escritura de archivos)
    guarda_primos(primos)
    guarda_tiempo(n, num_trabajadores, tiempo_ms)

    primos
  end

  # Función que ejecuta los experimentos: para cada valor de N prueba con cada número de trabajadores.
  # Cada medición se repite varias veces y se reporta el promedio en milisegundos.
  # La tabla resultante se imprime en consola y se agrega al archivo de tiempos.
  def experimentos(
        valores_n \\ @valores_n,
        trabajadores \\ @trabajadores,
        repeticiones \\ @repeticiones
      ) do
    # Ejecución inicial para llenar la cache de la VM y evitar que la primera medición sea más lenta
    mide(1_000, 1)

    # Para cada N calculamos el tiempo promedio con cada número de trabajadores
    filas =
      Enum.map(valores_n, fn n ->
        {n,
         Enum.map(trabajadores, fn num_trabajadores ->
           promedio(n, num_trabajadores, repeticiones)
         end)}
      end)

    # Construimos la tabla, la mostramos y la guardamos
    tabla = formatea_tabla(filas, trabajadores, repeticiones)
    IO.puts(tabla)
    File.write!(@archivo_tiempos, tabla <> "\n", [:append])

    filas
  end

  # Función auxiliar: mide el tiempo de todo Server.start (primos base, creación de procesos, mensajes, combinación y orden).
  # :timer.tc regresa el tiempo en microsegundos junto con el resultado, lo convertimos a milisegundos
  defp mide(n, num_trabajadores) do
    {tiempo_us, primos} = :timer.tc(fn -> Server.start(num_trabajadores, n) end)
    {tiempo_us / 1000, primos}
  end

  # Función auxiliar: repite la medición el número de veces indicado y regresa el promedio en milisegundos
  defp promedio(n, num_trabajadores, repeticiones) do
    1..repeticiones
    |> Enum.map(fn _ -> elem(mide(n, num_trabajadores), 0) end)
    |> Enum.sum()
    |> Kernel./(repeticiones)
    |> Float.round(3)
  end

  # Función auxiliar: construye la tabla de tiempos con una fila por cada N y una columna por cada número de trabajadores.
  # Incluye los núcleos disponibles y las repeticiones, que son necesarios para interpretar los tiempos
  defp formatea_tabla(filas, trabajadores, repeticiones) do
    # Encabezado con la información de la ejecución
    info =
      "Núcleos disponibles: #{System.schedulers_online()}, " <>
        "repeticiones por medición: #{repeticiones}, tiempos promedio en ms"

    # Fila de títulos: N y el número de trabajadores de cada columna
    titulos = celdas(["N" | trabajadores])

    # Una fila por cada N con sus tiempos
    renglones = Enum.map(filas, fn {n, tiempos} -> celdas([n | tiempos]) end)

    Enum.join([info, titulos | renglones], "\n")
  end

  # Función auxiliar: alinea cada valor a un ancho fijo y los separa con barras
  defp celdas(valores) do
    Enum.map_join(valores, " | ", fn valor -> String.pad_leading(to_string(valor), 10) end)
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
