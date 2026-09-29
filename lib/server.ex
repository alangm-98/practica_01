# Módulo que define al proceso coordinador (Server) de la criba distribuida.
defmodule Server do
  # Función para coordinar la criba distribuida.
  # Recibe el número de trabajadores deseado y el límite superior N (ambos mayores o iguales a 1).
  def start(num_trabajadores, n) when num_trabajadores >= 1 and n >= 1 do
    # Calcula el tamaño base del intervalo asignado a cada worker y cuántos números sobran
    tam_bloque = div(n, num_trabajadores)
    resto = rem(n, num_trabajadores)

    # Calculamos una sola vez los primos base (menores o iguales a la raíz de N) para enviarlos a los workers
    primos_base = Algebra.primos_base(n)

    # Guardamos el PID del servidor para que los workers sepan a quién responder
    servidor = self()

    # Crea los trabajadores y les reparte sus sub-intervalos
    Enum.each(0..(num_trabajadores - 1), fn i ->
      # Calculamos el límite inferior 'a'.
      # Los números que sobran se reparten de uno en uno entre los primeros 'resto' trabajadores
      a = i * tam_bloque + min(i, resto) + 1

      # Calculamos el límite superior 'b'. Los primeros 'resto' bloques llevan un número extra
      b = if i < resto, do: a + tam_bloque, else: a + tam_bloque - 1

      # Spawneamos un trabajador independiente
      worker = Worker.start()

      # Le enviamos la tarea con su id, el rango, los primos base y el PID del servidor
      send(worker, {:calcular_primos, servidor, i + 1, a, b, primos_base})
    end)

    # Recolectamos las respuestas enviadas por los trabajadores
    resultados_brutos = recibe_resultados(num_trabajadores, [])

    # Combina los bloques recibidos y ordena la lista final
    resultados_brutos
    |> List.flatten()
    |> Enum.sort()
  end

  # Función recursiva para recibir mensajes de los trabajadores en el buzón del server
  # Caso base: se recibieron las respuestas de todos los trabajadores
  defp recibe_resultados(0, acumulador), do: acumulador

  # Caso recursivo: esperamos un mensaje {:resultado, id, lista_primos}
  defp recibe_resultados(esperando, acumulador) do
    receive do
      {:resultado, _id, lista_primos} ->
        # Decrementamos la cuenta de respuestas pendientes y guardamos el bloque
        recibe_resultados(esperando - 1, [lista_primos | acumulador])
    after
      # Si ningún trabajador responde en 60 segundos, dejamos de esperar
      60_000 ->
        raise "tiempo de espera agotado"
    end
  end
end
