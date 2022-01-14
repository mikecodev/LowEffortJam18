# LowEffortJam18

## Clientes

### Atributos

- Estado: enum
  - Entrando
  - EsperandoEnCola
  - EsperandoComida
  - Comiendo
  - TerminadoDeComer
  - CabreadoAMuerte
  - Abandonando

Paciencia: float (valor entre 0 y 1)
Satisfacción: int (empieza en 100, se va bajando hasta llegar a 0)

#### Estado: Entrando

Se pedirá al gestor de clientes un hueco, y si el gestor de clientes acepta, se llamará a la función de persona para moverse hacia el punto X y se esperará a la señal de persona de movimiento terminado. Una vez llegada la señal, se pasará al estado esperando en cola.

Si no hubiese hueco en la cola, el cliente se dará la vuelta y se irá del restaurante.

#### EsperandoEnCola

Cuando al gestor de clientes haya asignado una mesa al personaje (llamada a método para confirmar que se tiene mesa), se llamará a la función de persona para moverse hacia el punto X y se esperará a recibir la señal de movimiento terminado. Al recibir dicha señal se pasará al estado EsperandoComida.

#### Estado: EsperandoComida

Al entrar en este estado, se elegirá la pizza deseada y se mostrará en un bocadillo encima de la cabeza (de forma permanente).

Cada X tiempo (variable) el cliente se irá cabreando y saldrá una señal para indicarlo. El parámetro paciencia se usará para saber cuánta satisfacción se resta (no todos los clientes se cabrean igual de rápido).

Resultados:
    - Si el cliente llega a su límite, abandonará el establecimiento añadiendo una penalización (por definir).
    - Si un empleado le lleva su pizza y NO es la deseada, empezará a comer pero añadirá una penalización y pasará al estado comiendo.
    - Si un empleado le lleva su pizza y es la deseada, empezará a comer y pasará al estado comiendo.

#### Estado: Comiendo

Durante X tiempo, el cliente comerá y dependiendo de lo satisfecho que esté (tiempo que se tardó en atenderlo y pizza servida) dejará una propina y pasará al estado terminado de comer.

#### TerminadoDeComer

El cliente lanzará una señal con la propina que desee dejar y esperará a recibir la orden de la mesa de que ya puede marcharse. Esto es por si el cliente no está solo para no abandonar a su amigo. Sería muy descortés.

Al recibir un mensaje de la mesa de que todos han terminado de comer, pasará al estado abandonando.

#### CabreadoAMuerte

Al entrar en este estado, el cliente se dirigirá hacia un empleado y le golpeará, tirando la pizza al suelo si el empleado fuese cargando una pizza. Si el empleado no fuese cargando ninguna pizza, se aplicará un ministun.

#### Estado: Abandonando

El cliente se moverá hacia la salida y lanzará una señal para decir que ha abandonado el establecimiento (la mesa que toque recibirá esa señal y actuará en consecuencia).

## Mesas

- Tendrán un número indeterminado de sillas
- Tendrán entre 1 y Número de sillas clientes
