% For SICStus, uncomment line below: (needed for member/2)
%:- use_module(library(lists)).
% Load model, initial state and formula from file.
verify(Input) :-
  see(Input),
  read(T),
  read(L),
  read(S),
  read(F),
  seen,
  check(T, L, S, [], F).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check(T, L, S, U, F)
% T - The transitions in form of adjacency lists
% L - The labeling , visar 
% S - Current state
% U - Currently recorded states
% F - CTL Formula to check. %

% Should evaluate to true if the sequent below is valid. %
% (T,L), S |- F %U
% To execute: consult('your_file.pl'). verify('input.txt').
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%% "Literals" %%%


% Kontrollerar regeln "p"
% Vi tittar om vi matchar strukturen av en "state" S och en tillhörande lista ("AdjList") mot L. 
% Vi kollar samtidigt att X finns i AdjList.  

check(_, L, S, [], X) :-
	member([S,AdjList],L),
	member(X, AdjList).


%% Kontrollerar regeln "icke-p", dvs "negation". 
% Vi tittar om vi matchar strukturen av en "state" S och en tillhörande lista ("AdjList") mot L. 
% Vi kollar samtidigt att X inte finns i AdjList.

check(_, L, S, [], neg(X)) :-
	member([S,AdjList],L),
	\+ member(X, AdjList).

%Kontrollerar "Or"
% Om X är sann eller Y är sann uppfylls predikatet.

check( T , L, S, [] , or(X, Y )) :-
  check( T , L , S , [], X);
  check( T , L , S , [], Y).


% Kontrollerar "And"
%Om både X och Y är sann uppfylls predikatet.

check(T, L, S, [], and(X,Y)) :-
  check( T , L , S , [], X),
  check( T , L , S , [], Y).



%%%% "A-regler" %%%%


% Kontrollerar "AX"
check( T, L, S, [], ax(X)) :-
  transition_A(T, L, S, [], X).


%Kontrollerar "AG1"
check(_, _, S, U, ag( _ )) :-
 member(S,U).


%Kontrollerar "AG2"
check( T , L , S , U , ag(X) ):-
  \+member(S,U),                                         
  check(T , L , S , [] , X), 
  transition_A(T , L , S , [S|U] , ag(X)).


% Kontrollerar "AF1"
check( T , L , S , U , af(X) ):-
  \+member(S,U),                                        
  check( T , L , S , [] , X ).                         


% Kontrollerar "AF2"
check( T , L , S , U , af(X) ):-
  \+member(S,U),
  transition_A(T , L , S , [S|U] , af(X)).          



%%%% "E-regler" %%%%


% Kontrollerar "EX"
check( T , L , S , [] , ex(X)) :-
  transition_E( T , L , S , [] , X).

%Kontrollerar "EG1"
check( _, _, S, U, eg( _ )) :-
 member(S,U).

%Kontrollerar "EG2"
 check( T , L , S , U , eg(X) ):-
   \+member(S,U),
   check(T , L , S , [] , X),
   transition_E(T , L , S , [S|U] , eg(X)).


% Kontrollerar "EF1"
check(T , L, S, U , ef(X)):-
  \+member(S,U),
  check(T, L, S, [] , X).

% Kontrollerar "EF2"
check(T , L, S, U , ef(X)):-
  \+member(S,U),
  transition_E(T, L, S, [S|U] , ef(X)).


%%%% Används för "A-regler" %%%%


%% kollar alla states som current state kan gå till

check_all(_, _, _, _, []).

check_all(T, L, U, F, [Head|Tail]) :-
  check(T, L, Head, U, F), 
  check_all(T, L, U, F, Tail). 

%%%% Används för "E-regler" %%%%


%% kollar något state som current state kan gå till

check_min_one(T, L, U, F, [Head|Tail]) :-
  check(T, L, Head, U, F); 
  check_min_one(T, L, U, F, Tail),
  !. 


%%%% "Transitions" %%%%

transition_A(T, L, S, U, F) :-
  member([S, N], T), 
  check_all(T, L, U, F, N).

transition_E(T, L, S, U, F) :-
  member([S, N], T), 
  check_min_one(T, L, U, F, N),
  !.





