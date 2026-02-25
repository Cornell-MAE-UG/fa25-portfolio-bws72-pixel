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

Below is a zip file containing the full program, that can be downloaded and built, compiler, and ran with the OPAM package manager and Dune. [Download the Wordle Program](/assets/wordle-program.zip)


Link to the game logic (a1/lib/wordle.ml): [Game logic](#logic)

Link to the text UI code: () [Link to the section heading](#main)

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