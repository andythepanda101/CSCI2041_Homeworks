(* solver.ml - command line driver for hw2 boolExpr *)

let arglist = Array.to_list Sys.argv in match arglist with
| _::"--count"::[] -> BoolExpr.main true
| _::"--solve"::[] -> BoolExpr.main false
| _ -> failwith "unexpected argument list.  valid arguments: --solve, --count"
