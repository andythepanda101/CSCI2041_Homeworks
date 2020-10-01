open FTools

let ngram_n = 3
(* Your code goes here: *)

(* Define the function that lower-cases and filters out non-alphabetic characters *)
let cleanup_chars s = ""

(* extract a list of n-grams from a string, naively *)
let ngrams n s = [""]

(* Define the function that converts a string into a list of "normalized" n-grams *)
let n_grams s = [""]

(* Define a function to convert a list into a multiset *)
let multiset_of_list lst = [("",0)]

(* multiset utility functions *)

(* multiplicity of e in multiset b - 0 if not in the multiset *)
let multiplicity e b = 0
(* size of a multiset is the sum of the multiplicities of its elements *)
let size b = 0

(* Define the similarity function between two multisets: size of intersection / size of union *)
let intersection_size s1 s2 = 0
let union_size s1 s2 = 0
let similarity s1 s2 = 0.0

(* Find the most similar representative file *)
let find_max repsims repnames = (0.,"")

let main all replist_name target_name =
  (* Read the list of representative text files *)
  let repfile_list = [""] in
  (* Get the contents of the repfiles and the target file as strings *)
  let rep_contents = [""] in
  let target_contents = "" in
  (* Compute the list of normalized n-grams from each representative *)
  let rep_ngrams = [[]] in
  (* Convert the target text file into a list of normalized n-grams *)
  let target_ngrams = [] in
  (* Convert all of the stem lists into stem sets *)
  let rep_multisets = [[]] in
  let target_multiset = [] in
  (* Compute the similarities of each rep set with the target set *)
  let repsims = [] in
  let (sim,best_rep) = ("",0.) in
  let () = if all then
  (* print out similarities to all representative files *)
  let () = print_endline "" in
  () else begin
  (* Print out the winner and similarity *)
  let () = print_endline "" in
  print_endline ""  end in
  (* this last line just makes sure the output prints before the program exits *)
  flush stdout
