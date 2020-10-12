open Similar
type etype = NG of int | ST

let rec take n ls = match (n,ls) with
| (0,_) | (_,[]) -> []
| (_,h::t) -> h::(take (n-1) t)

let do_main ms elem tn rl tname =
let mainfunc = match (ms,elem) with
| ("mset",NG n) ->
  let module Sim = FindSim(Ngram(struct let n=n end))(ListMSet) in Sim.main
| ("set",NG n) ->
  let module Sim = FindSim(Ngram(struct let n=n end))(SetSummary) in Sim.main
| _ -> failwith "not implemented"
in
  let rlist = mainfunc rl tname in
  List.iter (fun (s,n) -> Printf.printf "%0.4f\t%s\n" s n) (take tn rlist)

let rec setargs arglist ms elem tn = match arglist with
| rlistname::tname::[] -> do_main ms elem tn rlistname tname
| "--mset"::tl -> setargs tl "mset" elem tn
| "--set"::tl -> setargs tl "set" elem tn
| "--map"::tl -> setargs tl "map" elem tn
| "--ngram"::n::tl -> setargs tl ms (NG (int_of_string n)) tn
| "--stem"::tl -> setargs tl ms ST tn
| "--top"::n::tl -> setargs tl ms elem (int_of_string n)
| _ -> failwith "setargs"

let () = setargs (List.tl (Array.to_list Sys.argv)) "mset" (NG 3) max_int
