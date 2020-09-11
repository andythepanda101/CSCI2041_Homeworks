(* tables.ml - CSci 2041 HW 1 table slicer and dicer *)
(* Your Name Here *)

(* Free functions, don't question! *)
let read_lines () =
  let rec read_help acc =
    try read_help ((read_line ())::acc) with End_of_file -> List.rev acc
  in read_help []

let make_row delim str = List.map String.trim (Str.split (Str.regexp delim) str)

let rec write_row r delim = match r with
| [] -> ()
| h::[] -> print_endline h
| h::t -> let () = print_string h in
          let () = print_string delim in write_row t delim

let rec output_table od t = match t with
| [] -> ()
| r::rs -> let () = write_row r od in output_table od rs

(* Now your turn. *)

let rec table_of_stringlist delim rlist = [] (* replace this *)

let make_row_assoc (hr:bool) (table:string list list) = [] (* and this *)

let row_get_column col ralist = "" (* need this too! *)

let sort_assoc sortcol ralist = ralist (* you got this!!! *)

let cut_to_rows k ralist = [] (* you cut me real deep just now... *)

(* last one! *)
let reassemble (clist : string list)  (ralist : (string*string) list) = [[]]

(* OK, more free stuff *)
let rec main id od sortcol srev hr outcols outrows =
  let sl = read_lines () in
  let rtable = table_of_stringlist id sl in
  let ratab = make_row_assoc hr rtable in
  let stab = if sortcol = "" then ratab else sort_assoc sortcol ratab in
  let stab = if (sortcol <> "") && srev then List.rev stab else stab in
  let ktab = if outrows = max_int then stab else cut_to_rows outrows stab in
  let oclist = match (outcols,hr) with
  | ("*",false) -> nclist rtable
  | ("*",true) -> List.hd rtable
  | _ -> make_row "," outcols in
  let ntable = reassemble oclist ktab
  in
  output_table od (if hr then oclist::ntable else ntable)
(* magic you don't need to understand yet *)
and nclist rt =
  List.init (List.fold_left max 0 (List.rev_map List.length rt)) (fun n -> string_of_int (n+1))
