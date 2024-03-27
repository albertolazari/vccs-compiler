open Ast
open Var_substitution

let ch_n ch n = Printf.sprintf "%s_%d" ch n

(*
  (Unused) Expand input-bound variables for each value in domain:
  let domain = {min..max}

  a(x). P(x) -> a_min. P(min) + a_min+1. P(min+1)  + ... + a_max. P(max)
*)
let rec expand_act_var domain a p = match a with
  | Input (ch, x) ->
      begin match domain with
      | [] -> Nil
      | n :: [] -> Act (Input (ch_n ch n, x), substitute_proc_var x n p)
      | n :: rest -> Sum (
          Act (Input (ch_n ch n, x), substitute_proc_var x n p),
          expand_act_var rest a p
        )
      end
  | a -> Act (a, p)

(*
  Expand redirected channels for each value in domain:
  let domain = {min..max}

  P[a/b] -> P[a_min/b_min, a_min+1/b_min+1, ..., a_max/b_max]
*)
let rec expand_f_var domain f = match f with
  | [] -> []
  | (a, b) :: rest ->
      let expanded_red =
        List.map (fun n -> (ch_n a n, ch_n b n)) domain
      in
      expanded_red @ (expand_f_var domain rest)

(*
  Expand restricted channels for each value in domain:
  let domain = {min..max}

  P \ a -> P \ {a_min, a_min+1, ..., a_max}
*)
let rec expand_resL_var domain l = match l with
  | [] -> []
  | a :: acts ->
      let expanded_ch =
        List.map (fun n -> ch_n a n) domain
      in
      expanded_ch @ (expand_resL_var domain acts)

(*
  Expand process definition parameters for each value in domain:
  let domain = {min..max}

  P(x) = proc(x); pi ->
  P_min = proc(min); P_min+1 = proc(min+1); ...; P_max = proc(max); pi
*)
let rec expand_prog_var domain first pi =
  let sep = if first then "_" else "," in
  match pi with
  | Def (_, [], _, _) -> pi
  | Def (k, x :: params, p, next_pi) ->
      begin match domain with
      | [] -> Proc Nil
      | n :: [] -> substitute_prog_var x n
          (Def (k ^ sep, params, p, next_pi))
      | n :: rest ->
          (Def (k ^ sep, params, p, expand_prog_var rest first pi)) |>
          substitute_prog_var x n
      end
  | pi -> pi