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
