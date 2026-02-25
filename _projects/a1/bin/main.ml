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
