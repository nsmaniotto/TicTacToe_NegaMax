	/*********************************
	DESCRIPTION DU JEU DU TIC-TAC-TOE
	*********************************/

	/*
	Une situation est decrite par une matrice 3x3.
	Chaque case est soit un emplacement libre (Variable LIBRE), soit contient le symbole d'un des 2 joueurs (o ou x)

	Contrairement a la convention du tp precedent, pour modeliser une case libre
	dans une matrice on n'utilise pas une constante speciale (ex : nil, 'vide', 'libre','inoccupee' ...);
	On utilise plut�t un identificateur de variable, qui n'est pas unifiee (ex : X, A, ... ou _) .
	La situation initiale est une "matrice" 3x3 (liste de 3 listes de 3 termes chacune)
	o� chaque terme est une variable libre.	
	Chaque coup d'un des 2 joureurs consiste a donner une valeur (symbole x ou o) a une case libre de la grille
	et non a deplacer des symboles deja presents sur la grille.		
	
	Pour placer un symbole dans une grille S1, il suffit d'unifier une des variables encore libres de la matrice S1,
	soit en ecrivant directement Case=o ou Case=x, ou bien en accedant a cette case avec les predicats member, nth1, ...
	La grille S1 a change d'etat, mais on n'a pas besoin de 2 arguments representant la grille avant et apres le coup,
	un seul suffit.
	Ainsi si on joue un coup en S, S perd une variable libre, mais peut continuer a s'appeler S (on n'a pas besoin de la designer
	par un nouvel identificateur).
	*/

situation_initiale([ [_,_,_],
                     [_,_,_],
                     [_,_,_] ]).

	% Convention (arbitraire) : c'est x qui commence

joueur_initial(x).


	% Definition de la relation adversaire/2

adversaire(x,o).
adversaire(o,x).


	/****************************************************
	 DEFINIR ICI a l'aide du predicat ground/1 comment
	 reconnaitre une situation terminale dans laquelle il
	 n'y a aucun emplacement libre : aucun joueur ne peut
	 continuer a jouer (quel qu'il soit).
	 ****************************************************/

% situation_terminale(_Joueur, Situation) :-   ? ? ? ? ?

	/***************************
	DEFINITIONS D'UN ALIGNEMENT
	***************************/

alignement(L, Matrix) :- ligne(    L,Matrix).
alignement(C, Matrix) :- colonne(  C,Matrix).
alignement(D, Matrix) :- diagonale(D,Matrix).

	/********************************************
	 DEFINIR ICI chaque type d'alignement maximal 
 	 existant dans une matrice carree NxN.
	 ********************************************/
	
% La ligne L appartient-elle à la matrice M ?
ligne(L, M) :-  nth1(_, M, L).

test_ligne() :-
	M = [[a,b,c], [d,e,f], [g,h,i]],
	ligne([a,b,c], M),
	ligne([d,e,f], M),
	ligne([g,h,i], M).
 
% La colonne C appartient-elle à la matrice M ?
colonne(C,M) :-
	maplist(nth0(_), M, C).

test_colonne() :-
	M = [[a,b,c], [d,e,f], [g,h,i]],
	colonne([a,d,g], M),
	colonne([b,e,h], M),
	colonne([c,f,i], M).




	/* Definition de la relation liant une diagonale D a la matrice M dans laquelle elle se trouve.
		il y en a 2 sortes de diagonales dans une matrice carree(https://fr.wikipedia.org/wiki/Diagonale) :
		- la premiere diagonale (principale)  : (A I)
		- la seconde diagonale                : (Z R)
		A . . . . . . . Z
		. \ . . . . . / .
		. . \ . . . / . .
		. . . \ . / . . .
		. . . . X . . .
		. . . / . \ . . . 
		. . / . . . \ . .
		. / . . . . . \ .
		R . . . . . . . I
	*/
		
diagonale(D, M) :- 
	premiere_diag(1,D,M).

diagonale(D, M) :- 
	length(M, K),
	seconde_diag(K,D,M).

test_diagonale() :-
	M = [[a,b,c], [d,e,f], [g,h,i]],
	diagonale([a,e,i], M),
	diagonale([c,e,g], M).

	
premiere_diag(_,[],[]).
premiere_diag(K,[E|D],[Ligne|M]) :-
	nth1(K,Ligne,E),
	K1 is K+1,
	premiere_diag(K1,D,M).

seconde_diag(_,[],[]).
seconde_diag(K,[E|D],[Ligne|M]) :-
	nth1(K,Ligne,E),
	K1 is K-1,
	seconde_diag(K1,D,M).


	/*****************************
	 DEFINITION D'UN ALIGNEMENT 
	 POSSIBLE POUR UN JOUEUR DONNE
	 *****************************/

possible([X|L], J) :- unifiable(X,J), possible(L,J).
possible(  [],  _).

	/* Attention 
	il faut juste verifier le caractere unifiable
	de chaque emplacement de la liste, mais il ne
	faut pas realiser l'unification.
	*/

unifiable(X,_J) :- var(X).
unifiable(X,J) :- X == J.

test_unifiable() :-
	unifiable(_X,x),
	unifiable(x,x).
	
	/**********************************
	 DEFINITION D'UN ALIGNEMENT GAGNANT
	 OU PERDANT POUR UN JOUEUR DONNE J
	 **********************************/
	/*
	Un alignement gagnant pour J est un alignement
possible pour J qui n'a aucun element encore libre.
	*/
	
	/*
	Remarque : le predicat ground(X) permet de verifier qu'un terme
	prolog quelconque ne contient aucune partie variable (libre).
	exemples :
		?- ground(Var).
		no
		?- ground([1,2]).
		yes
		?- ground(toto(nil)).
		yes
		?- ground( [1, toto(nil), foo(a,B,c)] ).
		no
	*/
		
	/* Un alignement perdant pour J est un alignement gagnant pour son adversaire. */

% alignement_gagnant(+Ali, ?J)
alignement_gagnant(Ali, J) :- 
	ground(Ali), % +Ali

	% Vérifier que l'alignement est possible
	possible(Ali, J),
	% Vérifier que aucun élément de l'alignement n'est libre
	findall(E, (nth1(_, Ali, E), ground(E)), ListeE),
	length(ListeE, TailleE),
	length(Ali, TailleE).

alignement_perdant(Ali, J) :- 
	adversaire(J,A),
	alignement_gagnant(Ali, A).

test_alignements() :-
	alignement_gagnant([x,x,x], x),
	(alignement_gagnant([x,o,x], x) -> false; true),

	alignement_perdant([o,o,o],x).


	/* ****************************
	DEFINITION D'UN ETAT SUCCESSEUR
	****************************** */

	/* 
	Il faut definir quelle operation subit la matrice
	M representant l'Etat courant
	lorsqu'un joueur J joue en coordonnees [L,C]
	*/	

% A FAIRE
% successeur(J, Etat,[L,C]) :- ? ? ? ?  
successeur(J,Etat,[L,C]) :-
	nth1(L,Etat,Lselected),nth1(C,Lselected,X),var(X),X=J
.
test_successeur :-
	M = [[_,_,_],[_,_,_],[_,_,_]],
	successeur(x,M,[1,1]), M=[[x,_,_],[_,_,_],[_,_,_]],

	
	M = [[_,_,_],[_,_,_],[_,_,_]],
	successeur(x,M,[2,2]), M=[[_,_,_],[_,x,_],[_,_,_]]
.

	/**************************************
   	 EVALUATION HEURISTIQUE D'UNE SITUATION
  	 **************************************/

	/*
	1/ l'heuristique est +infini si la situation J est gagnante pour J
	2/ l'heuristique est -infini si la situation J est perdante pour J
	3/ sinon, on fait la difference entre :
	   le nombre d'alignements possibles pour J
	moins
 	   le nombre d'alignements possibles pour l'adversaire de J
*/


heuristique(J,Situation,H) :-		% cas 1
   H = 10000,				% grand nombre approximant +infini
   alignement(Alig,Situation),
   alignement_gagnant(Alig,J), !.
	
heuristique(J,Situation,H) :-		% cas 2
   H = -10000,				% grand nombre approximant -infini
   alignement(Alig,Situation),
   alignement_perdant(Alig,J), !.	


% on ne vient ici que si les cut precedents n'ont pas fonctionne,
% c-a-d si Situation n'est ni perdante ni gagnante.

heuristique(J,Situation,H) :- 		% cas 3
	% le nombre d’alignements potentiellement réalisables par J dans la situation S
	findall(AliJ, (alignement(AliJ, Situation), possible(AliJ, J)), ListeAliJ),
	length(ListeAliJ, NBJ),
	% le nombre d’alignements potentiellement réalisables par l’adversaire de J dans la même situation S
	adversaire(J, A),
	findall(AliA, (alignement(AliA, Situation), possible(AliA, A)), ListeAliA),
	length(ListeAliA, NBA),

	% Calcul de H = nb_alignement_possible_J - nb_alignement_possible_A
	H is NBJ - NBA.

test_heuristique :-
	joueur_initial(J),
	S = [[_,_,_], [_,J,_], [_,_,_]], % Situation initiale d'après l'énnoncé
	heuristique(J,S,4),
	adversaire(J,A),
	heuristique(A,S,-4).