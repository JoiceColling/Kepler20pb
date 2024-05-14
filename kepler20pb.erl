-module(kepler20pb).
-export([iniciar/1, kepler20pb/2, molecula/0, criarMoleculas/1, verificaSeTemAgua/2, gerarAgua/2]).
-import(lists, [map/2]).

iniciar(Time) ->
    Pid = spawn(kepler20pb, verificaSeTemAgua, [[], []]),
    kepler20pb(Pid, Time).

kepler20pb(Pid, Tempo) ->
    criarMoleculas(Pid),
    timer:sleep(Tempo),
    kepler20pb(Pid, Tempo).

criarMoleculas(Pid) ->
    Random = rand:uniform(50),

    if 
        Random > 25 ->
            MOPid = spawn(kepler20pb, molecula, []),
            MOPid ! { oxigenio, Pid };
        true -> 
            MHPid = spawn(kepler20pb, molecula, []),
            MHPid ! { hidrogenio, Pid }
    end.

molecula() ->
    receive
        {oxigenio, Pid} ->
            TempoO = (rand:uniform(20) + 10) * 1000,
            io:format("CRIOU: Molecula de ~p/~p foi criada. Tempo para energizar: ~p~n", [oxigenio, self(), TempoO]),
            timer:sleep(TempoO),
            io:format("ENERGIZOU: A molecula de ~p/~p adquiriu energia suficiente. Tempo: ~p~n", [oxigenio, self(), TempoO]), 

            Pid ! {oxigenio, self()};
        {hidrogenio, Pid} ->
            TempoH = (rand:uniform(20) + 10) * 1000,
            io:format("CRIOU: Molecula de ~p/~p foi criada. Tempo para energizar: ~p~n", [hidrogenio, self(), TempoH]),
            timer:sleep(TempoH),
            io:format("ENERGIZOU: A molecula de ~p/~p adquiriu energia suficiente. Tempo: ~p~n", [hidrogenio, self(), TempoH]),

            Pid ! {hidrogenio, self()}
    end.

verificaSeTemAgua(ListaOxigenio, ListaHidrogenio) ->
    receive
        {oxigenio, OPid} ->
            NovaListaOxigenio = ListaOxigenio ++ [{oxigenio, OPid}],

            if (length(NovaListaOxigenio) > 0) and (length(ListaHidrogenio) > 1) ->
                TuplaOxigenioHidrogenio = gerarAgua(NovaListaOxigenio, ListaHidrogenio),

                verificaSeTemAgua(element(1, TuplaOxigenioHidrogenio), element(2, TuplaOxigenioHidrogenio));     
                true -> true
            end,

            verificaSeTemAgua(NovaListaOxigenio, ListaHidrogenio);
        {hidrogenio, HPid} ->
            NovaListaHidrogenio = ListaHidrogenio ++ [{hidrogenio, HPid}],

            if (length(ListaOxigenio) > 0) and (length(ListaHidrogenio) > 1) ->
                TuplaOxigenioHidrogenio = gerarAgua(ListaOxigenio, NovaListaHidrogenio),

                verificaSeTemAgua(element(1, TuplaOxigenioHidrogenio), element(2, TuplaOxigenioHidrogenio));
                true -> true
            end,

            verificaSeTemAgua(ListaOxigenio, NovaListaHidrogenio)
    end.

gerarAgua(ListaOxigenio, ListaHidrogenio) ->
    [Oxigenio | ListaOxigenioFim] = ListaOxigenio,
    [Hidrogenio1, Hidrogenio2 | ListaHidrogenioFim] = ListaHidrogenio,

    io:format("~nAs moleculas (~p/~p) (~p/~p) (~p/~p) geraram uma molecula de agua!~n~n", [element(1, Hidrogenio1), element(2, Hidrogenio1), element(1, Hidrogenio2), element(2, Hidrogenio2), element(1, Oxigenio), element(2, Oxigenio)]),

    {ListaOxigenioFim, ListaHidrogenioFim}.