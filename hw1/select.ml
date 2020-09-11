(* select.ml - command line "driver" for HW1, CSci 2041, Fall 2020 *)

(* parse the command line arguments and call the main function in tables.ml *)
let rec select arglist id od sortcol srev hr outcols outrows = match arglist with
| [] -> Tables.main id od sortcol srev hr outcols outrows
| "-id"::d::t -> select t d od sortcol srev hr outcols outrows
| "-od"::d::t -> select t id d sortcol srev hr outcols outrows
| "-k"::k::t -> select t id od sortcol srev hr outcols (int_of_string k)
| "-s"::c::t -> select t id od c       srev hr outcols outrows
| "-rs"::c::t -> select t id od c       true hr outcols outrows
| "-hr"::t -> select t id od sortcol srev true outcols outrows
| "-c"::c::t -> select t id od sortcol srev hr c outrows
| _ -> failwith "select: invalid argument format"


(* make the call! *)
let () = select (List.tl (Array.to_list Sys.argv)) "," "," "" false false "*" max_int
