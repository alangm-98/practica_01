# Módulo que define al proceso trabajador (Worker)
defmodule Worker do
  # Función que espera una tarea, la resuelve y le envía el resultado al coordinador.
  # Cada trabajador atiende una sola tarea y después termina.
  def loop do
    receive do
      # Escuchamos la tupla para calcular primos en un intervalo, junto con los primos base
      {:calcular_primos, sender_pid, id, a, b, primos_base} ->
        # Calcula los primos en el intervalo dado usando la criba segmentada
        primos = Algebra.primos_intervalo(a, b, primos_base)

        # Enviamos el resultado al proceso coordinador (sender_pid) junto con nuestro id
        send(sender_pid, {:resultado, id, primos})
    end
  end

  # Función auxiliar para instanciar (spawn) un nuevo proceso trabajador de forma concurrente.
  def start do
    # Usamos spawn/1 para crear un nuevo proceso en la BEAM ejecutando nuestro loop
    spawn(fn -> loop() end)
  end
end
