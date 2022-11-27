

main:-
	build_kb,play.

build_kb:-
    write('Welcome to Pro-Wordle!'),nl,
    write('----------------------'),nl,nl,
    build_kbH([]).

build_kbH(Acc):-
    write('Please enter a word and its category on separate lines:'),nl,
    read(Word),
    ((Word=done,nl,write('Done building the words database...'),nl,reverse(Acc, AccR),assert(categories(AccR)));
    (Word\=done,read(Category),assert(word(Word, Category)),((member(Category, Acc), build_kbH(Acc));(\+member(Category,Acc),build_kbH([Category|Acc]))))).
    

is_category(X):-
	word(_,X).
	
pick_word(W,L,C):-
	setof(X, word(X,C), Bag),
	random_member(W, Bag),
    string_length(W,L).
   
available_length(L):-
    word(X, _),
    string_length(X,L).
    
available_length_help(L, C):- 
	word(X, C),
	string_length(X,L). 
 
correct_letters(_,[],Acc,AccR):-
	reverse(Acc,AccR).

correct_letters(L,[H|T],Acc,Res1):-
    member(H,L),
    \+member(H,Acc),
    Acc1 = [H|Acc],
    correct_letters(L,T,Acc1,Res1).

correct_letters(L,[H|T],Acc,Res1):-
   ( \+member(H,L); member(H,L),member(H,Acc)), %if head isnt member of Word OR its a member of word but we aleady took it as a correct letter
    correct_letters(L,T,Acc,Res1).
    
correct_positions([],[],[]).

correct_positions([H|T1],[H|T2],[H|T]):-
    correct_positions(T1,T2,T).

correct_positions([H1|T1],[H2|T2],T):-
    H1\==H2,
    correct_positions(T1,T2,T).
    
takeLength(Len, Cat):-
	write('Choose a length:'), nl,
    read(LenX),((available_length_help(LenX, Cat), Len is LenX);
	(\+available_length_help(LenX, Cat),write('There are no words of this length:'),nl,takeLength(Len, Cat))).

takeCategory(Cat):-
	write('Choose a category:'), nl,
    read(CatX),((is_category(CatX), Cat = CatX);
	(\+is_category(CatX),write('This category does not exist.'),nl,takeCategory(Cat))).

guess(Len, Word, Acc):-
	(Acc=0, write('You lost!'));
	(	
		Acc\=0,
		write('Enter a word composed of '),write(Len), write(' letters:'),nl,
		read(WordG),continue(Len,Word,WordG,Acc)
	).
continue(L,Word,WordG,Acc):-
	string_length(WordG, L), 
	L=Len,
	\+word(WordG,_),
	write('Word is not in words database. Try again.'), nl,
	write('Remaining Guesses are '),write(Acc),nl,nl,
	guess(Len, Word,Acc).
continue(_,Word,Word,_):-
	write('You Won!').	
continue(Len, Word, WordG,Acc):-
	string_length(WordG, L), 
	L\=Len, 
	write('Word is not composed of '),write(Len), write(' letters. Try again.'), nl,
	write('Remaining Guesses are '),write(Acc),nl,nl,
	guess(Len, Word,Acc).
continue(Len, Word, WordG,Acc):-
	string_length(WordG, L),
	L=Len,
	Word\=WordG,
	string_chars(Word,L1), string_chars(WordG,L2),
    
	correct_letters(L1,L2,[],Res1),
	write('Correct letters are: '), write(Res1), nl,
	correct_positions(L1,L2,Res2),
	write('Correct letters in correct positions are: '), write(Res2), nl,
	Acc1 is Acc-1,
	write('Remaining Guesses are '),write(Acc1),nl,nl,
	guess(Len, Word, Acc1).
	
	

play:-
    categories(Category),
    write('The availale categories are: '), write(Category), nl,
	takeCategory(Cat),
    takeLength(Len, Cat),
	Guesses is Len +1,
	write('Game started. You have '), write(Guesses), write(' guesses.'),nl,nl,
	pick_word(Word,Len,Cat), 
	guess(Len, Word, Guesses),!.
	
	
	
    
    