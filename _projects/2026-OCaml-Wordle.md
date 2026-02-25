---
layout: project
title: OCaml Wordle
description: The NY Times Wordle game coded in OCaml
technologies: OCaml, 
image: /assets/images/Wordle-NYT-Game.jpg.webp
---
### Overview

This page contains the OCaml code for a fully functioning Wordle game based on the online New York Times game Wordle played in a computer terminal. 

There are 3 following sections, containing code snippets of the game logic and data structures used to create the game, the interactions with the user that make up the textual UI in the terminal, and the testing for this game. 

Below is a zip file containing the full program, that can be downloaded and built, compiler, and ran with the OPAM package manager and Dune. [Download the Wordle Program]({{ "wordle-program.zip" | relative_url }})


Link to the game logic (a1/lib/wordle.ml in zip): [Game logic](#logic)

Link to the text UI code: (a1/bin/main.ml) [Input/Output code](#main)

Link to test suite: (a1/test/test_a1.ml) [Test Suite](#tests)


## Logic

~~~ ocaml
(*Allows a random number to be generated later.*)
let () = Random.self_init ()

(** Type [state] contains the important data for a game. string [secret_word] is
    the word the player tries to guess. string list [secret_dictionary] contains
    words that can be selected to be [secret_word] and can be guessed. string
    list [not_secret_dictionary] contains words that cannot be selected as the
    secret_word and can be guessed.*)
type state = {
  secret_word : string;
  secret_dictionary : string list;
  not_secret_dictionary : string list;
}


(** [init] returns a [state] type containing string lists made from the text
    files [secret_file_path] and [not_secret_file_path] with a random secret
    word selected from the [secret_file_path] dictionary. *)
let init (secret_file_path : string) (not_secret_file_path : string) : state =
  let secret_list = BatList.of_enum (BatFile.lines_of secret_file_path) in
  let rand_position = Random.int (List.length secret_list) in
  let not_secret_list =
    BatList.of_enum (BatFile.lines_of not_secret_file_path)
  in
  {
    secret_word = List.nth secret_list rand_position;
    secret_dictionary = secret_list;
    not_secret_dictionary = not_secret_list;
  }

(** Returns a bool that string [guess] string [secret_word] are equal and the
    guess is correct.*)
let is_guess_secret_word (guess : string) (secret_word : string) : bool =
  String.equal guess secret_word

(** Variant [letter_color] tells the color a guess letter should be printed.
    [Green] means the letter is correct. [Yellow] means the letter is in the
    secret word, but not in the right spot. [Gray] means the letter is not in
    the secret word. *)
type letter_color =
  | Green
  | Yellow
  | Gray

(** [default_color_list ()] creates a letter_color list containing 5 [Gray]s.*)
let default_color_list = fun () -> [ Gray; Gray; Gray; Gray; Gray ]

(** [count_char lst str letter] is the number of times char [letter] is found in
    string [str] at indicies that do not correspond to a value of [Green] in
    letter_color list [lst]. *)
let count_char (lst : letter_color list) (str : string) (letter : char) : int =
  let filtered =
    String.mapi
      (fun i x -> if x = letter && List.nth lst i != Green then '1' else x)
      str
  in
  String.fold_left (fun acc x -> if x = '1' then acc + 1 else acc) 0 filtered

(** [greens lst guess secret_word] is a letter_color list with a value of
    [Green] at every list index in which the chars at that index in string
    [guess] and string [secret_word] are the same. *)
let greens (lst : letter_color list) (guess : string) (secret_word : string) :
    letter_color list =
  List.mapi
    (fun i x ->
      if String.get guess i = String.get secret_word i then Green else Gray)
    lst

(** [yellows lst guess secret_word] is a letter_color list with a value of
    [Yellow] at every list index in which the char at that index in string
    [guess] is in string [secret_word], but is in the wrong spot in [guess],
    according to the rules of Wordle. letter_color list [lst] must be the output
    of a [greens] call.*)
let yellows (lst : letter_color list) (guess : string) (secret_word : string) :
    letter_color list =
  List.mapi
    (fun i x ->
      if x = Green then Green
      else
        let letter = String.get guess i in
        let guess_letter_count = count_char lst (String.sub guess 0 i) letter in
        let secret_letter_count = count_char lst secret_word letter in
        if secret_letter_count > guess_letter_count then Yellow else Gray)
    lst

(** [guess_colors_list guess secret_word] is a letter_color list in which the
    value at each index corresponds to the color the the letter at that string
    index of [guess] should be printed based on its relationship to string
    [secret_word]. *)
let guess_colors_list (guess : string) (secret_word : string) :
    letter_color list =
  let blank = default_color_list () in
  let greens_list = greens blank guess secret_word in
  yellows greens_list guess secret_word

(** [is_valid_guess guess secret_dictionary not_secret_dictionary] is a bool
    value of whether string [guess] is an element of string lists
    [secret_dictionary] or [not_secret_dictionary]. *)
let is_valid_guess guess secret_dictionary not_secret_dictionary : bool =
  List.exists (fun str -> String.equal str guess) secret_dictionary
  || List.exists (fun str -> String.equal str guess) not_secret_dictionary 
~~~


## Main

~~~ ocaml
(** @author Ben Sedran (bws72)

    Starts a game of Wordle in the terminal using the logic from functions and
    types in [lib/wordle.ml] and the dictionaries in [data/wordle-La.txt] and
    [data/wordle-Ta.txt].*)

(** Create a state type using [data/wordle-La.txt] and [data/wordle-Ta.txt]. *)
let state = A1.Wordle.init "data/wordle-La.txt" "data/wordle-Ta.txt"

(** [format_print_char letter color] prints char [letter] on a [color] - colored
    background. *)
let format_print_char (letter : char) (color : A1.Wordle.letter_color) =
  match color with
  | Green ->
      ANSITerminal.print_string
        [ ANSITerminal.black; ANSITerminal.on_green ]
        (String.make 1 letter)
  | Yellow ->
      ANSITerminal.print_string
        [ ANSITerminal.black; ANSITerminal.on_yellow ]
        (String.make 1 letter)
  | Gray ->
      ANSITerminal.print_string
        [ ANSITerminal.black; ANSITerminal.on_white ]
        (String.make 1 letter)

(** [format_print_word guess lst] prints each char in string [guess] on a
    background of its corresponding color value in letter_color list [lst]. *)
let rec format_print_word (guess : string) (lst : A1.Wordle.letter_color list) =
  match lst with
  | [] -> print_endline "\n"
  | h :: t ->
      let _ = format_print_char (String.get guess 0) h in
      format_print_word (String.sub guess 1 (String.length guess - 1)) t

(** [get_valid_guess dict1 dict2] recursively calls itself, prompting the user
    to input a valid word until returning their input, a string element of lists
    [dict1] or [dict2]. *)
let rec get_valid_guess (dict1 : string list) (dict2 : string list) : string =
  let () = print_string "> " in
  let input = String.lowercase_ascii (read_line ()) in
  if A1.Wordle.is_valid_guess input ("quit" :: dict1) ("cheat_mode" :: dict2)
  then input
  else
    let _ =
      print_endline
        "Input was not a valid word in the current dictionaries.\n\
        \ Please try a new input of a five letter word,\n\
        \ or type 'quit' to quit the program."
    in
    get_valid_guess dict1 dict2

(** Continually asks for and recieves a valid guess from the user until either
    quitting, the user gets the word right, or the user uses up all [remaining]
    guesses. The function prints each each guess back to the user with the
    feedback of the background color. The user can see the secret word by
    inputting 'cheat_mode' or quit with 'quit'. *)
let rec prompt_and_print (remaining : int) =
  if remaining = 0 then
    print_endline ("Out of guesses! The secret word was " ^ state.secret_word)
  else
    let the_input =
      get_valid_guess state.secret_dictionary state.not_secret_dictionary
    in
    if the_input = "quit" then ()
    else if the_input = "cheat_mode" then
      let () =
        print_endline ("The secret word is " ^ state.secret_word ^ ".\n")
      in
      prompt_and_print remaining
    else if A1.Wordle.is_guess_secret_word the_input state.secret_word then
      print_endline "Correct! You win!"
    else
      let color_list =
        A1.Wordle.guess_colors_list the_input state.secret_word
      in
      let () =
        print_endline
          ("Wrong! "
          ^ string_of_int (remaining - 1)
          ^ " guess"
          ^ (if remaining - 1 = 1 then "" else "es")
          ^ " remaining")
      in
      let () = format_print_word the_input color_list in
      prompt_and_print (remaining - 1)

(** Prints the instructions for the Wordle game. *)
let print_instructions () =
  print_endline
    "In this game, a five letter word is selected at random,\n\
    \ and you, the user, can input five letter words as guesses.\n\
    \ It can be played on a terminal in either dark or light mode theme.\n";
  print_endline
    "If these words are not in this program's dictionary of valid \n\
    \ five letter words, then you will be prompted for another word.\n";
  print_endline
    "You get six tries to guess the secret word.\n\
    \ At any time, type 'quit' to exit the program.\n\
    \ Each time you guess, your guess will be printed back for you,\n\
    \ and every letter will be on a\n\
    \ white, yellow, or green background.\n";
  print_endline
    "The background color of a letter gives you feedback about your guess.\n\
     A green background means the letter is correct,\n\
    \ and in the correct location in the word.\n\
    \ A yellow background means the letter is in the secret word,\n\
    \ but in the wrond spot.\n\
    \ A white background means the letter is not in the secret word.\n";
  print_endline
    "At any time, type 'cheat_mode' to be given the secret word.\n\
    \ This does not count as a guess.\n"

(** Starts and runs the wordle game. *)
let () =
  print_instructions ();
  print_endline
    "Please enter a 5 letter guess, or type 'quit' to quit the program.";
  prompt_and_print 6
~~~


## Tests

~~~ ocaml

open OUnit2
open A1.Wordle

(**Creates a string listing the colors in a letter_color list with spaces
   between. Used for testing. *)
let rec color_list_to_string = function
  | [] -> ""
  | h :: t ->
      let str =
        if h = Yellow then "Yellow "
        else if h = Green then "Green "
        else "Gray "
      in
      str ^ color_list_to_string t

(** [make_init_test name expected_dict1 expected_dict2 input_state] creates an
    OUnit test named [name], testing that the function [A1.Wordle.init]
    correctly creates a state value containing values equal to [expected_dict1],
    [expected_dict2], and [secret_word]*)
let make_init_test name (expected_dict1 : string list)
    (expected_dict2 : string list) (input_state : state) =
  name >:: fun _ ->
  assert_equal expected_dict1 input_state.secret_dictionary ~printer:(fun lst ->
      List.fold_left (fun acc str -> acc ^ " " ^ str) "" lst);
  assert_equal expected_dict2 input_state.not_secret_dictionary
    ~printer:(fun lst -> List.fold_left (fun acc str -> acc ^ " " ^ str) "" lst);
  assert_equal true
    (List.exists
       (fun str -> if str = input_state.secret_word then true else false)
       expected_dict1)
    ~printer:string_of_bool

(** [make_default_color_list_test name expected_list] creates an OUnit test
    named [name] that asserts [default_color_list ()] correctly creates the
    expected letter_color list [expected_list]. *)
let make_default_color_list_test name expected_list =
  name >:: fun _ ->
  assert_equal expected_list (default_color_list ())
    ~printer:color_list_to_string

(** [make_greens_test name expected_list guess secret_word] creates an OUnit
    test named [name] that asserts
    [greens (default_color_list ()) guess secret_word] correctly identifies
    which values in a letter_color list to make Green. *)
let make_greens_test name expected_list guess secret_word =
  name >:: fun _ ->
  assert_equal expected_list
    (greens (default_color_list ()) guess secret_word)
    ~printer:color_list_to_string

(** [make_guess_colors_list_test name expected_list guess secret_word] creates
    an OUnit test named [name] that asserts
    [guess_colors_list guess secret_word] correctly returns a list of
    letter_colors corresponding to the feedback that should be given for each
    letter of [guess]. *)
let make_guess_colors_list_test name expected_list guess secret_word =
  name >:: fun _ ->
  assert_equal expected_list
    (guess_colors_list guess secret_word)
    ~printer:color_list_to_string

(** [make_count_char_test name expected_count lst word letter] creates an OUnit
    test named [name] that asserts [count_char lst word letter] correctly counts
    the instances of char [letter] in string [word] that do not correspond to a
    Green value in letter_color list [lst] *)
let make_count_char_test name expected_count lst word letter =
  name >:: fun _ ->
  assert_equal expected_count
    (count_char lst word letter)
    ~printer:string_of_int

(** [make_is_valid_guess_test name expected_val guess sec_filepath
     not_sec_filepath] creates an OUnit test named [name] that asserts
    [is_valid_guess] correctly identifies whether string [guess] is an element
    of the lists storing the rows of text files [sec_filepath] and
    [not_sec_filepath]. *)
let make_is_valid_guess_test name expected_val guess sec_filepath
    not_sec_filepath =
  name >:: fun _ ->
  let state = init sec_filepath not_sec_filepath in
  assert_equal expected_val
    (is_valid_guess guess state.secret_dictionary state.not_secret_dictionary)
    ~printer:string_of_bool

(** [make_is_secret_word_test name expected_val guess secret_word] creates an
    OUnit test named [name] that asserts
    [is_guess_secret_word guess secret_word] correctly identifies whether
    [guess] and [secret_word] are equal. *)
let make_is_secret_word_test name expected_val guess secret_word =
  name >:: fun _ ->
  assert_equal expected_val
    (is_guess_secret_word guess secret_word)
    ~printer:string_of_bool

(** Creates a test suite to test all of the top-level functions in A1.Wordle. *)
let tests =
  "test suite"
  >::: [
         make_init_test "small-secret-dictionary and small-dictionary test"
           (BatList.of_enum
              (BatFile.lines_of "../data/small-secret-dictionary.txt"))
           (BatList.of_enum (BatFile.lines_of "../data/small-dictionary.txt"))
           (init "../data/small-secret-dictionary.txt"
              "../data/small-dictionary.txt");
         make_init_test "wordle-La and wordle-Ta test"
           (BatList.of_enum (BatFile.lines_of "../data/wordle-La.txt"))
           (BatList.of_enum (BatFile.lines_of "../data/wordle-Ta.txt"))
           (init "../data/wordle-La.txt" "../data/wordle-Ta.txt");
         make_default_color_list_test "test default color list"
           [ Gray; Gray; Gray; Gray; Gray ];
         make_greens_test "test greens with no similar letters"
           [ Gray; Gray; Gray; Gray; Gray ]
           "apple" "cross";
         make_greens_test "test greens 1 correct letter"
           [ Green; Gray; Gray; Gray; Gray ]
           "place" "pours";
         make_greens_test "test greens with letters in the wrong spaces"
           [ Gray; Gray; Gray; Gray; Gray ]
           "abcde" "bcdea";
         make_greens_test "test greens with all correct letters"
           [ Green; Green; Green; Green; Green ]
           "apple" "apple";
         make_greens_test "test greens with dupicates letters"
           [ Gray; Gray; Green; Green; Gray ]
           "gloom" "spoon";
         make_greens_test
           "test greens with some similar letters but 1 correct letter"
           [ Gray; Gray; Gray; Gray; Green ]
           "apple" "place";
         make_count_char_test "test count char with no matches" 0
           (default_color_list ()) "apple" 'q';
         make_count_char_test "test count char with 1 match" 1
           (default_color_list ()) "apple" 'a';
         make_count_char_test "test count char with 2 matches" 2
           (default_color_list ()) "apple" 'p';
         make_count_char_test "test count char with all matches" 5
           (default_color_list ()) "bbbbb" 'b';
         make_count_char_test "test count char with greens preventing matches" 0
           [ Green; Green; Green; Green; Green ]
           "bbbbb" 'b';
         make_count_char_test "test count char with Green preventing a match" 1
           [ Gray; Green; Gray; Gray; Gray ]
           "apple" 'p';
         make_count_char_test "test count char with smaller word" 1
           [ Yellow; Yellow; Yellow; Yellow; Yellow ]
           "pdf" 'f';
         make_count_char_test
           "test count char with small word, 1 match, and Green preventing one"
           1
           [ Yellow; Green; Yellow; Green; Yellow ]
           "gloo" 'o';
         make_guess_colors_list_test
           "guess_colors_list test with no similar letters"
           [ Gray; Gray; Gray; Gray; Gray ]
           "apple" "turns";
         make_guess_colors_list_test "guess_colors_list test with the same word"
           [ Green; Green; Green; Green; Green ]
           "apple" "apple";
         make_guess_colors_list_test
           "guess_colors_list test with all letters in the wrong spot"
           [ Yellow; Yellow; Yellow; Yellow; Yellow ]
           "abcde" "eabcd";
         make_guess_colors_list_test
           "guess_colors_list test with 1 similar letter in wrong spot"
           [ Gray; Gray; Gray; Yellow; Gray ]
           "apple" "moldy";
         make_guess_colors_list_test
           "guess_colors_list test with both similar and correct letters"
           [ Green; Yellow; Gray; Yellow; Gray ]
           "goals" "ghoul";
         make_guess_colors_list_test
           "test guess_colors_list with both duplicate letters"
           [ Gray; Yellow; Yellow; Green; Gray ]
           "robot" "bloom";
         make_guess_colors_list_test
           "test guess_colors_list with no 2 'O's in guess and 1 in secret_word"
           [ Yellow; Yellow; Gray; Gray; Yellow ]
           "robot" "storm";
         make_guess_colors_list_test
           "test guess_colors_list with duplicates and similar letters"
           [ Gray; Yellow; Green; Yellow; Gray ]
           "dooms" "gloom";
         make_guess_colors_list_test
           "test guess_colors_list with 3 'l's in guess and 2 in secret"
           [ Gray; Green; Green; Green; Green ]
           "lulls" "pulls";
         make_guess_colors_list_test
           "test guess_colors_list with 3 's's in guess and 2 in secret_word"
           [ Yellow; Yellow; Gray; Green; Gray ]
           "sassy" "glass";
         make_is_valid_guess_test "small dictionaries valid in secret" true
           "small" "../data/small-secret-dictionary.txt"
           "../data/small-dictionary.txt";
         make_is_valid_guess_test "small dictionaries valid in not secret" true
           "sling" "../data/small-secret-dictionary.txt"
           "../data/small-dictionary.txt";
         make_is_valid_guess_test "small dictionaries real word invalid guess"
           false "blind" "../data/small-secret-dictionary.txt"
           "../data/small-dictionary.txt";
         make_is_valid_guess_test "small dictionaries not real word" false
           "asdft" "../data/small-secret-dictionary.txt"
           "../data/small-dictionary.txt";
         make_is_valid_guess_test "small dictionaries invalid wrong length"
           false "bottle" "../data/small-secret-dictionary.txt"
           "../data/small-dictionary.txt";
         make_is_valid_guess_test "small dictionaries invalid too short" false
           "mall" "../data/small-secret-dictionary.txt"
           "../data/small-dictionary.txt";
         make_is_valid_guess_test
           "small dictionaries invalid special characters" false "9gs.4"
           "../data/small-secret-dictionary.txt" "../data/small-dictionary.txt";
         make_is_valid_guess_test "big dictionaries valid in La" true "above"
           "../data/wordle-La.txt" "../data/wordle-Ta.txt";
         make_is_valid_guess_test "big dictionaries valid in Ta" true "beeps"
           "../data/wordle-La.txt" "../data/wordle-Ta.txt";
         make_is_valid_guess_test "big dictionaries invalid word" false "afdlk"
           "../data/wordle-La.txt" "../data/wordle-Ta.txt";
         make_is_valid_guess_test "big dictionaries invalid too short" false
           "car" "../data/wordle-La.txt" "../data/wordle-Ta.txt";
         make_is_valid_guess_test "big dictionaries invalid too long" false
           "bottles" "../data/wordle-La.txt" "../data/wordle-Ta.txt";
         make_is_valid_guess_test "big dictionaries invalid special characters"
           false "from!" "../data/wordle-La.txt" "../data/wordle-Ta.txt";
         make_is_secret_word_test "guess is secret word" true "table" "table";
         make_is_secret_word_test "guess is not secret word" false "table"
           "place";
       ]

(** Runs the test suite [tests]. *)
let _ = run_test_tt_main tests

~~~
