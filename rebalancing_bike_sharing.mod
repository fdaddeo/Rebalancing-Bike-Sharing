### INSIEMI

set BICI;
set PARCHEGGI;
set DEPOSITO ordered;
set NODI := (DEPOSITO union BICI union PARCHEGGI);
set ARCHI := (NODI cross NODI);


### PARAMETRI

param K >= 0 integer; #Capacità furgone
param R{NODI} >= 0 default 0; #Capacità parcheggio i-esimo (se bici pari a 0)
param T{ARCHI} >= 0 default 10000000; #Tempo di percorrenza associato ad ogni arco
param S := card(BICI); #Numero di biciclette presenti nel grafo
param plus{NODI} default 0; #Numero di biciclette in eccesso nel nodo i-esimo
param minus{NODI} default 0; #Numero di biciclette richieste nel nodo i-esimo


### VARIABILI

var x{ARCHI} binary; #Posta a 1 se l'arco viene percorso, 0 altrimenti
var y{NODI} >= 0, <= S - 1 , integer; #Variabile che impedisce di tornare in un nodo bicicletta già visitato
var z{ARCHI} >= 0, integer; #Quantità di biciclette presente sul furgone mentre percorre un arco


#Impone la presenza di un solo nodo uscente dal deposito
subject to uscitaDeposito : 
sum{j in NODI : (first(DEPOSITO), j) in ARCHI} x[first(DEPOSITO), j] = 1;

#Impone la presenza di un solo nodo entrante nel deposito
subject to entrataDeposito : 
sum{j in NODI : (j, first(DEPOSITO)) in ARCHI} x[j, first(DEPOSITO)] = 1;

#Impone che l'ultimo nodo visitato prima di tornare al deposito sia un parcheggio
subject to parcheggioDeposito : 
sum{k in PARCHEGGI : (k, first(DEPOSITO)) in ARCHI} x[k, first(DEPOSITO)] = 1;

#Impone che per ogni nodo bici ci possa essere un solo nodo uscente
subject to uscitaBici{i in BICI} : 
sum{j in NODI : i != j} x[i, j] = 1;

#Impone che per ogni nodo bici ci possa essere un solo nodo entrante
subject to entrataBici{i in BICI} : 
sum{j in NODI : j != i} x[j, i] = 1;

#Impone che il numero di archi entranti in un nodo sia pari al numero di archi uscenti
# in modo da evitare problemi di "teletrasporto"
subject to visitaNodo{i in NODI} :
sum{j in NODI : i != j} x[i, j] = sum{j in NODI : i != j} x[j, i];

#Vieta la possibilità di tornare in un nodo bicicletta già visitato
subject to eliminazioneSottoCircuitiBici{i in BICI, j in BICI : i != j} :
y[j] - y[i] >= 1 - S * (1 - x[i, j]);

#Impone che lungo ogni arco sia sempre rispettata la capacità del furgone
subject to capacitaFurgone{(i, j) in ARCHI} :
z[i, j] <= K * x[i, j];

#Aggiorna il numero di biciclette presente sul furgone dopo la visita di ogni nodo
subject to flussoArchi{i in NODI} : 
sum{j in NODI} z[i, j] - sum{j in NODI} z[j, i] = plus[i] - minus[i];


### OBIETTIVO
minimize distanza_totale : sum{(i, j) in ARCHI}
T[i, j] * x[i, j];