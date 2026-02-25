---
layout: project
title: OCaml Wordle
description: The NY Times Wordle game coded in OCaml
technologies: OCaml, 
image: /assets/images/Wordle-NYT-Game.jpg.webp
---
First collapsable section for main:

<details>

<summary> The logic and data structures that make up the Wordle game. </summary>

### lib/Wordle.ml


```
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

```


</details>