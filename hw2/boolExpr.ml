(* read std input to eof, return list of lines *)
let read_lines () : string list =
  let rec read_help acc =
    try read_help ((read_line ())::acc) with End_of_file -> List.rev acc
  in read_help []

(* split a string at word boundaries and parens *)
let wordlist s : string list =
  let splitlist = Str.full_split (Str.regexp "\\b\\|(\\|)\\|\\$") s in
  let rec filter_splist lst = match lst with
    | [] -> []
    | (Str.Delim "(")::t -> "(" :: (filter_splist t)
    | (Str.Delim ")")::t -> ")" :: (filter_splist t)
    | (Str.Delim "$")::(Str.Text s)::t -> ("$"^s)::(filter_splist t)
    | (Str.Delim "$")::t -> "$"::(filter_splist t)
    | (Str.Delim _) :: t -> filter_splist t
    | (Str.Text s) :: t -> let s' = String.trim s in
			   let t' = (filter_splist t) in
			   if not (s' = "") then s' :: t' else t'
  in filter_splist splitlist

(* is s a legal variable name? *)
let is_varname s =
  let rec checker i = match (i,s.[i]) with
  | (0,'$') -> true
  | (0,_) -> false
  | (_,('a'..'z'|'0'..'9'|'_')) -> checker (i-1)
  | _ -> false
  in checker ((String.length s) - 1)

(* tokens - you need to add some here *)
type bexp_token = OP | CP | NAND | CONST of bool | VAR of string

(* convert a string into a token *)
let token_of_string = function
  | "(" -> OP
  | ")" -> CP
  | "nand" -> NAND
  | "T" -> CONST true
  | "F" -> CONST false
  | s -> if (is_varname s) then (VAR (Str.string_after s 1))
         else (invalid_arg ("Unknown Token: "^s))

(* convert a list of strings into a a list of tokens *)
let tokens wl : bexp_token list = List.map token_of_string wl

(* type representing a boolean expression, you need to add variants here *)
type boolExpr = Const of bool
| Id of string
| Nand of boolExpr * boolExpr

(* attempt to turn a list of tokens into a boolean expression tree.
A token list representing a boolean expression is either
 + a CONST token :: <more tokens> or
 + a VAR token :: <more tokens> or
 + an OPEN PAREN token :: a NAND token :: <a token list representing a boolean expression> @
                                          <a token list representing a boolen expression> @ a CLOSE PAREN token :: <more tokens>
 any other list is syntactically incorrect. *)
let parse_bool_exp tok_list =
(* when possibly parsing a sub-expression, return the first legal expression read
   and the list of remaining tokens  *)
  let rec parser tlist = match tlist with
    | (CONST b)::t -> (Const b, t)
    | (VAR s)::t -> (Id s, t)
    | OP::NAND::t -> let (a1, t1) = parser t in
                    let (a2, t2) = parser t1 in
                    (match t2 with
                     | CP::t' -> ((Nand (a1,a2)), t')
		                 | _ -> invalid_arg "sexp: missing )")
    | _ -> invalid_arg "parse failed."
  in let bx, t = parser tok_list in
     match t with
     | [] -> bx
     | _ -> invalid_arg "parse failed: extra tokens in input."

(* pipeline from s-expression string to boolExpr *)
let bool_exp_of_s_exp s = s |> wordlist |> tokens |> parse_bool_exp

(* evaluate the boolean expression bexp, assuming the variable names
   in the list tru are true, and variables not in the list are false *)
let rec eval_bool_exp bexp tru =
  match bexp with
  | Const b -> b
  | Id s -> List.mem s tru
  | Nand (x1, x2) -> not ((eval_bool_exp x1 tru) && (eval_bool_exp x2 tru))

(* You need to add some new stuff in here: *)

(* list all the subsets of the list s, sorted by size then lexicographically *)
let subsets s = [[]]

(* find all the variable names in a boolExpr, sorted and without duplicates *)
let var_list bexp = []

(* find the list of all lists of variables that when set to true make the expression true *)
let find_sat_sets bexp : string list list = []


let main count =
  let sExpr = String.concat " " (read_lines ()) in
  let bExpr = bool_exp_of_s_exp sExpr in
  let satslist = find_sat_sets bExpr in
  print_endline (match (count,satslist) with
    (true,sl) -> "Number of satisfying assignments = "^(string_of_int (List.length sl))
    | (false,[]) -> "No satisfying assignment"
    | (false,tv::t) -> "First satisfying assignment: {"^(String.concat ", " tv)^"}")
