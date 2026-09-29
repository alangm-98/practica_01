# Módulo con la lógica pura de la Criba de Eratóstenes (no usa procesos)
defmodule Algebra do
  # Caso base: si el límite inferior supera al superior, regresa lista vacía
  def intervalo(min, max) when min > max, do: []

  # Caso recursivo: agregamos el mínimo a la cabeza y volvemos a llamar recursivamente con min + 1
  def intervalo(min, max) do
    [min | intervalo(min + 1, max)]
  end

  # Algoritmo recursivo de la Criba de Eratóstenes. Recibe una lista de enteros y filtra sus múltiplos.
  # Caso base: si pasamos una lista vacía regresa una lista vacía
  def criba([]), do: []

  # Caso recursivo: tomamos el primer elemento de la lista y filtramos la cola
  def criba([head | tail]) do
    # 1 no es número primo, entonces se descarta
    if head < 2 do
      # Llamamos recursivamente con la cola
      criba(tail)
    else
      # Si el número es primo llamamos a la función auxiliar para descartar sus múltiplos de la lista
      cola_filtrada = elimina_multiplos(tail, head)

      # Construye de forma recursiva la lista con la cabeza
      [head | criba(cola_filtrada)]
    end
  end

  # Función auxiliar: recorre la lista y quita los múltiplos del primo pasado como parámetro.
  # El primo en sí no se elimina, porque en un segmento [a, b] el primo puede estar dentro de él.
  # Caso base: si la lista es vacía regresa la lista vacía
  def elimina_multiplos([], _primo), do: []

  # Caso recursivo: revisamos la cabeza y filtramos la cola
  def elimina_multiplos([head | tail], primo) do
    # Si el residuo de dividir la cabeza entre el primo es 0 (y no es el primo mismo) es múltiplo y lo eliminamos
    if rem(head, primo) == 0 and head != primo do
      # Llamamos recursivamente pasando la cola y el primo como parámetros
      elimina_multiplos(tail, primo)
    else
      # Si no es múltiplo lo mantenemos en la lista filtrada
      [head | elimina_multiplos(tail, primo)]
    end
  end

  # Función que calcula los primos base, es decir, los primos menores o iguales a la raíz de n.
  # Son los únicos primos necesarios para cribar cualquier segmento dentro de [1, n].
  def primos_base(n) do
    # Aplicamos la criba clásica sobre el intervalo [2, raíz de n]
    intervalo(2, raiz_entera(n))
    |> criba()
  end

  # Función que calcula los primos dentro del segmento [a, b] usando los primos base (criba segmentada).
  # Todo compuesto x en [a, b] tiene un factor primo p con p * p <= x <= b, por eso basta con esos primos.
  def primos_intervalo(a, b, primos_base) do
    # Generamos los números del segmento, empezando en 2 porque 1 no es primo
    segmento = intervalo(max(a, 2), b)

    primos_base
    # Nos quedamos solo con los primos cuyo cuadrado no supera a b
    |> Enum.filter(fn p -> p * p <= b end)
    # Eliminamos del segmento los múltiplos de cada primo base
    |> Enum.reduce(segmento, fn p, acumulador -> elimina_multiplos(acumulador, p) end)
  end

  # Función auxiliar: calcula la parte entera de la raíz cuadrada de n.
  # Se ajusta el resultado de :math.sqrt porque trabaja con flotantes y puede tener error de redondeo.
  defp raiz_entera(n) when n < 1, do: 0

  defp raiz_entera(n) do
    raiz = trunc(:math.sqrt(n))

    cond do
      # Si la raíz se pasó, la bajamos en uno
      raiz * raiz > n -> raiz - 1
      # Si le faltó uno, la subimos en uno
      (raiz + 1) * (raiz + 1) <= n -> raiz + 1
      # Si no, es correcta
      true -> raiz
    end
  end
end
