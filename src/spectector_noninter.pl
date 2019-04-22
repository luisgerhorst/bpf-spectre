% Copyright 2018 The Spectector authors
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%     http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
% ===========================================================================

:- module(_, [], [assertions, fsyntax, datafacts, dcg]).

%:- doc(title, "Speculative non-interference check").

:- use_module(library(aggregates)).
:- use_module(library(lists)).
:- use_module(library(write)).
:- use_module(library(streams)).

:- use_module(muasm_semantics).
:- use_module(muasm_program).
:- use_module(muasm_print).
:- use_module(spectector_flags).
:- use_module(spectector_stats).
:- use_module(concolic(symbolic)).
:- use_module(concolic(concolic), [pathgoal/2, sym_filter/2, conc_stats/3, set_nextpath_timeout/1]).
:- use_module(engine(runtime_control), [statistics/2]).

:- export(noninter_check/2).
% `Low` is a list of register names or memory indices that are "low".
% `C0` is the initial configuration.
noninter_check(Low, C0) :- % TODO: Keep track of number of paths -> safe*
	set_nextpath_timeout(~get_limit(nextpath_timeout)),
	get_maxtime(MaxTime),
	%
	log('[exploring paths]'),
	( % (failure-driven loop)
	  statistics(walltime, [TP0, _]),
	  set_last_time(TP0),
	  concrun(C0, (C, Trace)), % TODO: Get number of steps done
	  statistics(walltime, [TP, _]),
	  last_time(LTP), TimeP is TP - LTP, set_last_time(TP), % Trace time
			( member(timeout, Trace) ->
					log('[maximum number of steps reached]'),
	        message(warning, 'maximum number of steps reached -- ignoring remaining path')
	    ; true
	    ),
	    log('[path found]'),
	    pretty_print([triple(C0,Trace,C)]),
	    log('[checking speculative non-interference]'),
	    C0 = xc(_,C0n,_),
	    statistics(walltime, [TC0, _]),
	    set_last_time(TC0),
	    noninter_cex(Low, C0n, Trace, MaxTime, Safe), % TODO: Get the SMT length for the stats
	    statistics(walltime, [TC, _]),
	    last_time(LTC), TimeC is TC - LTC, set_last_time(TC), % SMT time
	    collect_stats(Safe, Trace, TimeP, TimeC),
	    (
	     ( Safe = unknown_noninter ->
		  log('[unknown noninter]')
	      ; Safe = global_timeout ->
		  log('[global timeout reached]')
	      ; log('[path is safe]') % TODO: change log?
	  ; Safe = no(_) -> log('[path is unsafe]') ; log('[path is safe]') % TODO: change log?
	      ),
	      % For bounded analysis
	      ( check_maxtime_limit(MaxTime) ->
		  log('[full timeout reached, program is assumed as safe]'),
		  !, % stop here
		  collect_path_limit_stats
	      ; explored_paths_left(N) -> % Fails if not initialized
		  ( N > 1 -> new_explored_path, fail % go for next path
		  ; log('[maximum number of paths reached, program is assumed as safe]'),
		    !, % stop here
		    collect_path_limit_stats
		  )
	      ; fail % go for next path
	      )
	    )
	; log('[program is safe]'), % TODO: except for timeouts!
	  new_analysis_stat(status=string("safe"))
	).

% Compute MaxTime for full timeout
get_maxtime(MaxTime) :-
	( FullTO = ~get_limit(full_timeout),
	  FullTO > 0 ->
	    statistics(walltime, [Time0, _]),
	    MaxTime is Time0 + FullTO
	; MaxTime = 0 % no timeout
	).

% Check if we have reached the MaxTime limit (full timeout)
check_maxtime_limit(MaxTime) :-
	MaxTime > 0, % (disabled otherwise)
	statistics(walltime, [CurrTime, _]),
	CurrTime > MaxTime.

collect_stats(Safe, Trace, TimeP, TimeC) :- stats, !,
	trace_length(Trace, TL),
	add_path_stat(trace_length=TL),
	findall(X, conc_stats_json(X), LConc),
	add_path_stat(concolic_stats=LConc),
	( Safe = no(Mode) -> StatusStr = ~atom_codes(Mode)
	; Safe = unknown_noninter -> StatusStr = "unknown_noninter" % TODO: change?
	; Safe = global_timeout -> StatusStr = "global_timeout" % TODO: change?
	; StatusStr = "safe"
	),
	new_path([status=string(StatusStr),time_trace=TimeP,time_solve=TimeC]),
	( Safe = no(_) -> new_analysis_stat(status=string(StatusStr)) ; true ).
collect_stats(_, _, _, _).

conc_stats_json(json([len=ConcLen,time=ConcT,status=string(ConcStStr)])) :-
	conc_stats(ConcLen, ConcT, ConcSt),
	ConcStStr = ~atom_codes(ConcSt).

collect_path_limit_stats :- stats, !,
	new_analysis_stat(status=string("safe_bound")). % TODO: Check if there are no paths to inspect left
collect_path_limit_stats.

% Obtain a counter example for speculative non-interference.
% NOTE: see the paper for details, this check works on a single trace
%   at a time.

:- data noninter_status/2.

noninter_cex(Low, C0, Trace, MaxTime, no(Mode)) :-
	retractall_fact(noninter_status(_,_)),
	( Mode = data ; Mode = control ),
	\+ \+ noninter_cex_(Mode, Low, C0, Trace, MaxTime), !.
noninter_cex(_, _, _, _, Safe) :-
	( noninter_status(_, unknown) -> % unknown safety if some get_model/2 returned unknown
	    Safe = unknown_noninter
	; noninter_status(_, global_timeout) ->
	    Safe = global_timeout
	; Safe = yes
	).

noninter_cex_(Mode, Low, C0a, TraceA0, MaxTime) :-
	erase_and_dump_constrs(C0a, InGoalA),
	erase_model([InGoalA,TraceA0]), % remove all other concrete assignments
	( Mode = data ->
	    % Data-based leak
	    TraceA = TraceA0,
	    rename_symspec(Low,
	                   C0a, InGoalA, TraceA, [],
			   C0b, InGoalB, TraceB, [],
			   LowGoal),
	    differdisj(TraceA, TraceB, OrCond),
	    \+ OrCond = [], % (just fail)
	    DiffGoal = [~or_cond(OrCond) = 1]
	; Mode = control ->
	    % Control-based leak
	    % (nondet)
	    select_spec_cond(TraceA0, TraceA, CondA), % select cond/1 in speculative fragments
	    rename_symspec(Low,
	                   C0a, InGoalA, TraceA, CondA,
			   C0b, InGoalB, TraceB, CondB,
			   LowGoal),
	    NegCondB = ~negcond(CondB), DiffGoal = [CondA,NegCondB],
	    X = sym(cond(CondA)), Y = sym(cond(NegCondB))
	; throw(unknown_mode(Mode))
	),
	% Check MaxTime for possible timeouts
	( check_maxtime_limit(MaxTime) ->
	    !, % (stop search, remember status, and fail)
	    assertz_fact(noninter_status(Mode, global_timeout)),
	    fail
	; true
	),
	% Get input model for two different heaps
	Goal = ~append(InGoalA,
	          ~append(~pathgoal(~sym_filter(TraceA)),
		    ~append(InGoalB,
		      ~append(~pathgoal(~sym_filter(TraceB)),
		        ~append(LowGoal,DiffGoal))))),
	add_formula_length(~length(Goal)),
	set_solver_opt(timeout, ~get_limit(noninter_timeout)),
	get_model(Goal, Status),
	assertz_fact(noninter_status(Mode, Status)),
	Status = sat, % (fail otherwise)
	%
	show_cex(C0a, TraceA, C0b, TraceB, X, Y).

show_cex(C0a, _TraceA, C0b, _TraceB, X, Y) :-
	log('[path is unsafe, showing counter-example initial configurations A and B]'),
	pretty_print([
	  msg('Case A:'),
	  (C0a,[X]), % TODO: where?
	  % (C0a,~append(TraceA, [X])),
	  msg('Case B:'),
	  (C0b,[Y]) % TODO: where?
	  % (C0b,~append(TraceB, [Y]))
        ]).

% Obtain a copy of the trace, unifying:
%  - variables corresponding to low memory and registers
%    (all registers in initial configuration are implicitly low)
%  - the nonspec obs
% ExtraA and ExtraB are used to apply renaming to additional
% constraints not in the traces.
rename_symspec(Low,
	       CSymA, InGoalA, TraceA, ExtraA,
	       CSymB, InGoalB, TraceB, ExtraB,
	       LowGoal) :-
	filter_nonspec(TraceA, NTraceA),
	copy_term((CSymA,InGoalA,TraceA,NTraceA,ExtraA),(CSymB,InGoalB,TraceB,NTraceB,ExtraB)),
	%
	CSymA = c(_,A), CSymB = c(_,A), % TODO: all registers are low (we could also pass them explicitly)
	unif_obs(NTraceA,NTraceB),
	unif_low_goal(Low, CSymA, CSymB, LowGoal, []).

% generate a goal to unify low values in both configurations Ca and Cb
unif_low_goal([], _, _) --> [].
unif_low_goal([X|Xs], Ca, Cb) -->
	unif_low_goal1(X, Ca, Cb),
	unif_low_goal(Xs, Ca, Cb).

unif_low_goal1(X, Ca, Cb) -->
	{ Ca = c(Ma, Aa) },
	{ Cb = c(Mb, Ab) },
	( { atom(X) } -> [element(Aa, X, V), element(Ab, X, V)] % TODO: not needed since all registers are low, fix solver to deal with these if needed
	; { integer(X) } -> [element(Ma, X, V), element(Mb, X, V)]
	; { throw(unknown_low(X)) }
	),
	!.

unif_obs([], []).
unif_obs([X|Xs], [Y|Ys]) :-
	( X = load(A) -> Y = load(A)
	; X = store(A) -> Y = store(A)
	; weak_sni, X = value(A) -> Y = value(A) % For weak speculative non-interference, we consider also value(N) observations in the non-speculative trace
	; true
	),
	unif_obs(Xs,Ys).

% Obtain a non-speculative trace from a speculative trace
% (removes rollbacks)
filter_nonspec([start(I)|Xs], NTrace) :-
	append(Spec, [End|Rest], Xs),
	( End = commit(I)
	; End = rollback(I)
	),
	!,
	( End = commit(I) -> Rest2 = ~append(Spec, Rest)
	; Rest2 = Rest
	),
	filter_nonspec(Rest2, NTrace).
filter_nonspec([X|Xs], [X|NTrace]) :-
	filter_nonspec(Xs, NTrace).
filter_nonspec([], []).

% Given traces Xs and Ys, obtain a disjunction representing that at
% least one of the load or store addresses differ.
differdisj([], [], []).
differdisj([X|Xs], [Y|Ys], OrCond) :-
	( differ(X, Y, Cond) -> OrCond = [Cond|OrCond0]
	; OrCond = OrCond0
	),
	differdisj(Xs, Ys, OrCond0).

or_cond([X]) := R :- !, R = X.
or_cond([X|Xs]) := X\/(~or_cond(Xs)).

differ(load(A), load(B), (A\=B)) :- A \== B.
differ(store(A), store(B), (A\=B)) :- A \== B.

% Obtain trace prefixes before a C cond(_) during speculation (fail if
% there are no more prefixes)
select_spec_cond([start(I)|Xs], Trace, C) :-
	append(Spec, [End|Rest], Xs),
	End = rollback(I), % only rollbacks
	!,
	( % obtain cond and drop the rest of spec
	  append(BeforeC, [sym(cond(C))|AfterC], Spec),
	  Trace = ~append([start(I)|BeforeC], Trace0),
%	  Trace0 = ~only_specmarks(~append(AfterC, Rest)) % drop all (wrong, not enough)
	  Trace0 = ~append(~only_specmarks(AfterC), [End|Rest]) % drop spec (it should be fine)
%	  Trace0 = ~append(AfterC, [End|Rest]) % drop spec (spurious during spec, is it fine?)
	; % continue with other speculative fragment
	  append([start(I)|Spec], [End|Trace0], Trace),
	  select_spec_cond(Rest, Trace0, C)
	).
select_spec_cond([X|Xs], [X|Trace], C) :-
	select_spec_cond(Xs, Trace, C).

only_specmarks([], []).
only_specmarks([X|Xs], [X|Ys]) :-
	( X = start(_) ; X = commit(_) ; X = rollback(_) ), !,
	only_specmarks(Xs, Ys).
only_specmarks([_|Xs], Ys) :-
	only_specmarks(Xs, Ys).

:- export(trace_length/2).
trace_length(Xs, N) :-
	trace_length_(Xs, 0, N).

trace_length_([], N, N).
trace_length_([X|Xs], N0, N) :-
	( X = sym(cond(_)) ->
	    N1 is N0 + 1
	; X = load(_) ->
	    N1 is N0 + 1
	; X = store(_) ->
	    N1 is N0 + 1
	; N1 = N0
	),
	trace_length_(Xs, N1, N).


% ---------------------------------------------------------------------------
% (log messages)

:- use_module(engine(messages_basic), [message/2]).

log(X) :- message(user, X).
