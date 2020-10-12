let file_lines fname =
  let in_file = open_in fname in
  let rec loop acc =
    let next_line = try Some (input_line in_file) with End_of_file -> None in
    match next_line with
    | (Some l) -> loop (l::acc)
    | None -> acc
  in
  let lines = try List.rev (loop []) with _ -> [] in
  let () = close_in in_file in
  lines

let file_as_string fname = String.concat "\n" (file_lines fname)

module type Summary = sig
  type e
  type t
  val empty : t
  val union_size : t -> t -> int
  val inter_size : t -> t -> int
  val size : t -> int
  val of_list : e list -> t
end

module type Element = sig
  type e
  val of_string : string -> e list
end

(* These two are not for real use, just for testing *)
module Nilement = struct
  type e = int
  let of_string s = [String.length s]
end

module Nummary = struct
  type e = int
  type t = int
  let empty = 0
  let of_list = function [] -> 0 | h::t -> h
  let size s = s
  let inter_size s1 s2 = min s1 s2
  let union_size s1 s2 = max s1 s2
end

(* now back to real uses *)

module Ngram(N : sig val n : int end) = struct
  type e = string
  let of_string str = [] (* your implementation of n_gram N.n *)
end

module Stem = struct
  type e = string
  let of_string str = List.map Stemmer.stem (Str.split (Str.regexp {|\b|}) str)
end

(* Your multiset implementation from HW3 *)
module ListMSet = struct
  type e = string
  type t = (string * int) list
  let empty = []
  let of_list lst = [] (* your implementation of multiset_of_list *)
  let union_size m1 m2 = 0 (* your implementation of union_size *)
  let inter_size m1 m2 = 0 (* your implementation of intersection_size *)
  let size m1 = 0 (* sum of the multiplicities *)
end

module SetSummary = struct
  type e = string
  type t = string list (* NO!!! WRONG!!! *)
  let empty = [] (* NOPE NOT RIGHT AT ALL *)
  let of_list lst = [] (* YEAH... CHANGE ALL THE REST OF THIS TOO *)
  let union_size s1 s2 = 0
  let inter_size s1 s2 = 0
  let size s = 0
end

(* SAME STORY HERE CHANGE IT ALL *)
module MapMSet = struct
  type e = string
  type t = string list
  let empty = []
  let of_list lst = []
  let union_size s1 s2 = 0
  let inter_size s1 s2 = 0
  let size s = 0
end

module FindSim (E : Element)(MS : Summary) = struct
  let similarity s1 s2 = 0.0
  let main replist_name target_name =
    let repfile_list = [""] in
    let rep_contents = [""] in
    let target_contents = [""] in
    let rep_elems = [[]] in (* _almost_ the same as your rep_ngrams *)
    let target_elems = [] in (* _almost the same as your target_ngrams *)
    let rep_summaries = [MS.empty] in (* change this to the right thing *)
    let target_summary = MS.empty in (* this too *)
    let repsims = [] in (*your repsims*)
    List.stable_sort (Fun.flip compare) repsims
end
