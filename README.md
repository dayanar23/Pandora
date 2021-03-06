# Pandora

Pandora es un lenguaje imperativo de tipado fuerte y propósio general cuyo diseño está inspirado principalmente en el lenguaje Pascal. Pandora es un lenguaje simplificado diseñado para los cursos de la cadena de Lenguajes de Programación de la USB, cuenta con recursión, iteración determinada e indeterminada, uniones, estructuras y bloques anidados.

## Consideraciones lexicográficas.

### Puntuación.

* `;` : Separador de instrucciones.
* `,` : Separador de argumentos o parámetros.
* `.` : Accede a los campos.
* `:` : Declaración del tipo de una variable.
* `(` : Diversos usos.
* `)` : Diversos usos.
* `[` : Delimitador de arreglos.
* `]` : Delimitador de arreglos.


### Palabras reservadas.

#### Instrucciones.

* `if` : Inicio de la sentencia condicional.
* `then` : Instrucción then de la sentencia condicional.
* `else` : Instrucción else de la sentencia condicional.
* `while` : Inicio de la iteración indeterminada.
* `do` : Inicio de un bloque.
* `for` : Inicio de la iteración determinada.
* `from`: Declaracion de cota inferior en la iteración determinada.
* `to` : Declaración de cota superior en la iteración determinada.
* `with`: Declaración del paso de la iteración determinada.
* `union` : Declaración de uniones.
* `like` : Declaración de uniones.
* `struct` : Declaración de estructuras.
* `has` : Declaración de estructuras.
* `return` : Retorna el valor de una función.
* `new` : Creación de un apuntador.
* `begin` : Inicio del programa principal.
* `end` : Fin del programa principal y de las estructuras.
* `func` : Decalaración de funciones.
* `proc` : Declaración de procedimientos. 
* `free` : Liberación de un apuntador.
* `repeat`: Inicio de la iteración indeterminada.
* `until`: Fin de la iteración indeterminada.
* `read` : Lee del teclado y asigna a una variable.
* `write` : Escribe en la salida estándar.

#### Valores.

* `true` : Valor booleano.
* `false`: Valor booleano.
* `null` : Valor nulo.

#### Tipos.

* `int` : tipo de los números enteros.
* `bool` : tipo booleano.
* `float` : tipo de los números punto flotante.
* `char` : tipo de los caracteres.
* `array` : tipo de los arreglos.
* `void` : Tipo de datos vacío, retornado por los procedimientos.
* `struct` : Tipo de las estructuras.
* `union`: Tipo de las uniones.

#### Otros.

* `var` : Define el pasaje de parámetros por referencia.

### Identificadores.

Cualquier cadena de caracteres que comience por una letra minúscula (`a-z`) o un guión bajo (`_`) y es seguido por digítos (`0-9`), letras mayúsculas o minúsculas (`a-z,A-Z`) o un guión bajo (`_`), es considerado un identificador.

Ejemplos:

    foo2
    _bar
    bAz_

### Comentarios.

* `--` : inicio de un comentario de línea.
* `-*` : inicio de un comentario multilínea.
* `*-` : fin de un comentario multilínea.

Se permite anidamiento de comentarios.

Ejemplos:

` -- Esto es un comentario de línea`

    -* 
        esto es
        un comentario
        multilínea 
        -* esto es 
            un comentario
            anidado
        *-
    *-


### Operadores.

#### Binarios.

* `=` : Asignación.
* `==` : Igualdad.
* `/=` : Desigualdad.
* `*` : Multiplicación algebraica.
* `+` : Suma algebraica.
* `-` : Resta algebraica.
* `/` : División algebraica.
* `^` : Potencia.
* `>` : Mayor que.
* `>=` : Mayor o igual que.
* `<` : Menor que.
* `<=` : Menor o igual que.
* `and`: Conjunción lógica.
* `or`: Disyunción lógica.
* `div`: Parte entera de la división.
* `mod`: Módulo.

#### Unarios.

* `not` : Negación lógica.
* `-` : Menos unario.
* `->` : Dirección de memoria.

Ejemplos:

    foo : int;
    foo = 3^2;
    foo = -3;

 
## Gramática. (Por definir)

## Estructura del programa. (Por definir)

Un programa en Pandora tiene dos partes funtamentales:

* El programa principal: es el llamado cuando se inicia la ejecución del programa. Esta función esta delimitada por las palabras `begin`y `end`.
* Área de definiciones: en esta sección se definen todas las variables, estructuras y funciones que serán usadas por el programa principal.

## Alcance.

El alcance es la región del código donde la declaración de un elemento está activa, en Pandora el alcance es estático permitiendo anidamiento de bloques y variables solapadas.

## Tipos de datos.

### Tipos primitivos

Son los tipos de datos incluidos en la implementación del lenguaje.

* `int` cualquier secuencia de números.
* `float` cualquier secuencia de números con un punto seguido de otra secuencia de números o su representación en anotación cientifica.
* `bool` `true` o `false`.
* `char` cualquier carácter entre comillas simple o algún carácter especial como por ejemplo `'\n'`.

### Tipos compuestos

* `array` definen una asociación entre un tipo `int`y cualquiera de los tipos primitivos del lenguaje.

Los usuarios tienen la posibilidad de definir nuevos tipos de datos según les sea necesario.

* `struct`  define las estructuras cuyos elementos pueden ser usados simultáneamente con el operador de acceso '.'

* `union` define las estructuras llamadas uniones, cuyos elemntos no pueden ser utilizados de manera simultánea sino que únicamente se recuerda el elemento que ha sido asignado más recientemente.

Ejemplos: 

        struct persona has
            nombre : array of char[10];
            apellido : array of char[10];
        end

        union fecha like
            enInt : int;
            enFloat : float;
            enString : array of char[10];
        end
    
## Variables.

Cualquier identificador declarado con cualquier tipo válido, bien sea primitivo o definido por el ususario, es considerado una variable. Las variables pueden ser locales o globales.

* Variables locales: Son las variables declaradas en el cuerpo de una función y aquellas pasadas como parámetros.

* Variables globales: Son las variables declaradas fuera de los alcances locales.

Pandora permite variables solapadas, es decir, si un identificador ya es asignado dentro del cuerpo de una función, el mismo identificador puede ser asignado dentro de un bloque anidado y es esta última la que tiene validez dentro del bloque más interno ocultando la primera asignación hasta que el bloque termine para luego restaurarla.

La noción de variables solapadas no aplica para los nombres de funciones ni tipos definidos por el usuario.


## Arreglos

Los arreglos en Pandora son multidimensionales de base 0, es decir, siempre comienzan en 0 hasta el número indicado en su declaración, el arreglo puede contener cualquiera de los tipos básicos definidos en Pandora.

Ejemplo:

        foo : array of int[21][42]; 

Sintaxis:
        
        array of <type>[<expr Int>] <variable>; 

Donde su longitud sería 22 desde 0 hasta 21.

Al pasarlos como parámetros de una función seran realizados por refencia 
(Un apuntador al primer elemento) cambiando los valores del arreglo pasado como parámetros **(Por Definir)**.

## Strings

El uso de Strings en Pandora es muy limitado, sólo se permiten usarlos para la facilidad de imprimirlos con la palabra reservada `write` del leguaje. Para tener un String, estos tendran que estar entre comillas dobles (\") en una sola linea, permite el uso de los carácteres especiales '\\n' '\\t' para poder representar los saltos de lineas y tabulaciones.

Ejemplo:

        write "Hola Mundo\n";

## Funciones **(Por Definir)**

Para la declaración de funciones se necesita usar la palabra reservada para la misma `func` seguido del nombre de la función y entre paréntesis los parametros necesarios, así como el tipo de retorno seguido del bloque de ejecución que debe terminar en un end.

Ejemplo: 

        func foo(a : int, b : int) : int 
            c : int;
            write a;
            write b;
            c = a+b;
            return c;
        end


Sintaxis: **(Falta)**

Para la invocación de funciones se necesita usar la variable asignada a la función con el número correcto de argumentos, dichos argumentos no pueden ser pasados como referencias. **(No se si se va a permitir funciones con argumentos multiples)**.
Una función siempre debe retornar un valor, y este valor debe ser del tipo declarado en la definición de la función.

Ejemplo:

    a, b, c : int;
    a = 3;
    b = 32;
    c = foo(a,b);

Sintaxis: **(Falta)**

### Funciones de segunda clase **(Por definir)**.

## Procedimientos **(Por Definir)**

Para la declaración de un procedimiento se necesita usar la palabra reservada para el mismo `proc` seguido del nombre del procedimiento y entre paréntesis los parametros necesarios, así como el tipo de retorno seguido del bloque de ejecución que debe terminar en un end.
Cuado un parámetro es por referencia, se indica en la declaración haciendo uso de `var` seguido de la declaración del parámetro.

Ejemplo: 

    proc foo(var a : int, b : int) : int 
        write b;
            a = a+b;
            return a;
        end
    
    Sintaxis: **(Falta)**

Para la invocación de procedimientos se necesita usar la variable asignada al mismo con el número correcto de argumentos, dichos argumentos pueden ser de valor o de referencia. 
un procedimiento siempre debe tener como última instrucción `return`.

Ejemplo:

    a, b : int;
    a = 3;
    b = 32;
    b = foo(a,b);

Sintaxis: **(Falta)**


## Asignación

Para los tipos básicos del lenguaje se realiza una copia por valor, en el cual se copia el valor o resultado del lado derecho a la variable del lado izquierdo. Dicha variable debe haber sido declarada previamente y ambos lados de la asignación deben tener el mismo tipo.

Ejemplo:

        foo = 42;

## Estructuras de Control

### Condicional

Viene dado por el conocido `if then` o `if then else`.

Ejemplos:

        if (nothing) then
            a = something;
        end

        if (baz == 42) then 
            bar = something;
        else
            foo = something
        end

Sintaxis:  **(Falta)**

**(Falta ver si se pondra elif entre las definiciones)**

### Case **(Por definir)**

### Iteración acotada (for).

La iteración acotada viene dado por el uso de for seguido de una variable y el rango en el cual se quiera usar.

Ejemplo:
 
        for (i from 0 to 12 with i+1) do
            bar = bar + i;
        end

Sintaxis: `for (<identificador> from <cota inferior> to <cota superior> step <aumento de identificador>) do <instrucciones> end`

Nota: En el bloque del for no se puede usar la variable que se esta utilizando para la iteración

### Iteración indeterminada.

Existen 2 tipos de iteraciones indeterminadas en Pandora, el `while` y el `repeat`,
la primera evalúa una expresión booleana y de cumplirse ejecuta el bloque, 
el `repeat` primero evalúa el bloque y después evalúa la expresión booleana.

Ejemplo while:

        while (foo < 42) do
            foo = foo + 1;
        end

Ejemplo repeat:
        
        repeat
            foo = foo + 1;
        until foo < 42;

Sintaxis: **(Falta)**

## Expresiones

Las expresiones consisten de constantes numéricas(int, float), constantes booleanas, variables y operadores, estos últimos contienen una precedencia el cual indican el orden en el cual deben ser realizadas las operaciones, dicho orden puede ser modificado con el uso de parentesis. Al usar varibles en una operación estas deben ser inicializadas con las reglas de alcance ya explicadas.

### Expresiones aritméticas

Las expresiones aritméticas consisten de constantes numéricas, llamadas a funciones, variables y operadores aritméticos. Los operadores aritméticos definidos en Pandora son: los binarios dados por la suma (+), la resta (-), la multiplicación (*), la división entera (/) y el módulo (%). El único operador unario viene dado por la negación (-). Los operadores binarios seran usados con anotación infija, mientras que el unario con anotación prefija.

*   Precedencia de operadores (listados de menor a mayor):
    
    *   `+, - `binario
    *   `*, /, %, div, mod`
    *   `^`
    *   `-` unario

Para los operadores aritméticos sus operandos deben ser del mismo tipo, y el resultado sera del tipo de los operando, es decir, si sus operandos son `int` el resultado sera `int`, igual manera si los operandos son `float`.

### Expresiones booleanas

Las expresiones booleanas consisten de constantes booleanas, llamadas a funciones, variables y operadores booleanos. Los operadores booleanos definidos en Pandora son: los binarios dado por el *y* lógico (and) y el *o* lógico (or). El único operador unario viene dado por la negación lógica (not), al igual que los operadores atirméticos los binarios tienen anotación infija y el unario anotación prefija.

*   Precedencia de operadores (listados de menor a mayor):

    *   `or`
    *   `and`
    *   `not`

Los operandos de los operadores deben ser del tipo `bool` dando como resultado un tipo `bool`.

### Expresiones Relacionales 

Las expresiones relacionales consisten de constantes numéricas, booleanas o carácteres, llamadas a funciones, variables y operadores relaciones. Los operadores relacionales definidos en pandora son: menor que (<), mayor que (>), igual (==), mayor o igual que (>=), menor o igual que (<=) y desigual(/=). Cabe destacar que todos funcionan con los operandos de tipos *int*, *float* y *char*, estos últimos se compararan por su valor en la tabla ASCII, pero tanto el igual (==) como el desigual (/=) también pueden trabajar con operandos del tipo *bool* y *array*, para la comparación de arreglos se usa su valro de refencia. 

*   Precedencia de operadores (listados de menor a mayor):

    *   `<, >, <=, >=`
    *   `==, /=`

El resultado de las expresiones relacionales siempre son de tipo `bool`.

Tabla de operadores con precedencia de menor a mayor y su asociatividad

|      Operador     |         Descripcion         | Asociatividad |
|:-----------------:|:---------------------------:|:-------------:|
|    <, >, <=, >=   | Expresiones Relacionales    |      none     |
|       ==, /=      | Expresiones Relacionales    |      none     |
|         or        | Disyunción lógica           |      left     |
|        and        | Conjunción lógica           |      left     |
|        not        | Negación lógica             |     right     |
|        +, -       | Suma y resta aritmética     |      left     |
|   *, /, div, mod  | Expresiones multiplicativas |      left     |
|         ^         | Potencia aritmética         |      left     |
|         -         | Negación aritmética         |     right     |

## Conversión de tipos. (Por definir)

Las conversiones de tipos se hacen de manera explícita haciendo uso de las funciones:

* `intToString(i:int)` : convierte el entero i en su representación como string.
* `floatToString(f:float)` : convierte el número flotante f en su representación como string.
* `intToFloat(i:int)` : convierte el entero i en su representación en punto flotante.

## Chequeos a tiempo de ejecución.

Se espera que sea el menor número de verificaciones posibles.

Las existentes hasta el momento se enumeran a continuación:

*   Comprobación del índice de un arreglo.
*   Acceso correcto al campo de un union.
*   División entre 0.
*   Overflow.

## Ejemplos de programas

### Hola Mundo
    
    begin
        write "hola mundo";
    end
    
### Merge Sort

   proc merge_sort(var a: array of int[n], p: int,r : int) : void
        q : int;
        if (p < r) then
            q = (p+r) div 2;
            merge_sort(a, p, q);
            merge_sort(a, q+1, r);
            merge(a, p, q, r);
        end
    end

    proc merge(var a : array of int[n], p:int, q:int, r : int) : void
        i: int;
        j: int;
        k : int;
        b : array of int[n];
        i = p;
        j = q+1;
        k = p;
        while ((i <= q) and (j <= r)) do
            if( a[i] < a[j]) then
                b[k] = a[i];
                i = i+1;
            end
            else
                b[k] = a[j];
                j = j+1;
            end
            k = k+1;
        end
        for (k from  p to r with k+1) do
            a[k] = b[k];
            write a[k];
        end
    end

    begin
        n : int;
        n = 6;
        a : array of int[n];
        a = [1,3,9,6,5,2];
        merge_sort(a,1,n);
    end


### Factorial recursivo

    func factorial(n : int) : int
        int : i;
        if( n == 0 ) then 
            return 1;
        end
        i = factorial(n-1);
        return n * i;
    end

    begin
        n: int;
        read n;
        write factorial(n);
    end

### Factorial recursivo de cola

    func factorial(n : int, a : int) : int
        if( n == 0 ) then 
            return a;
        end
        return factorial(n-1, n * a);
    end

    begin
        int n;
        read n;
        write factorial(n,1); 
    end

### Factorial iterativo

    func factorial(n : int) : int
        f : int; 
        f = 1;
        for(i from 1 to n with i+1) do 
            f = f * i;
        end
        return f;
        end
    end

    begin
        n : int;
        read n;
        write factorial(n);
    end

### Fibonacci

    func fibonacci(n : int) : int
        i: int;
        j: int;
        if (n == 0) then
            return 0;
        end
        if (n == 1) then 
            return 1;
        end
        i = fibonacci(n-1);
        j = fibonacci(n-2);
        return i +j; 
    end

    begin
        n : int;
        read n;
        write fibonacci(n);
    end

### Algoritmo de euclides

    func mcd(a: int, b : int) : int
        if (b == 0) then
            return a;
        end
        return mcd(b,a mod b);
    end

    begin
        n : int;
        m : int;
        read n;
        write mcd(n,m);
    end
