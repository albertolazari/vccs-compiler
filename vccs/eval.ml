open Ast

let rec eval_expr e =
  let eval_abop op e1 e2 = match op with
    | Add -> eval_expr e1 + eval_expr e2
    | Sub -> eval_expr e1 - eval_expr e2
    | Mult -> eval_expr e1 * eval_expr e2
    | Div -> eval_expr e1 / eval_expr e2
    | Mod -> eval_expr e1 mod eval_expr e2
  in
  match e with
  | Num n -> n
  | Var x -> Format.sprintf "unbound variable '%s'" x |> failwith
  | AritBinop (op, e1, e2) -> eval_abop op e1 e2

let rec eval_boolean b =
  let eval_bbop op e1 e2 = match op with
    | Eq -> eval_expr e1 = eval_expr e2
    | Neq -> eval_expr e1 != eval_expr e2
    | Lt -> eval_expr e1 < eval_expr e2
    | Gt -> eval_expr e1 > eval_expr e2
    | Leq -> eval_expr e1 <= eval_expr e2
    | Geq -> eval_expr e1 >= eval_expr e2
  in
  match b with
  | True -> true
  | False -> false
  | Not b -> not (eval_boolean b)
  | And (b1, b2) -> (eval_boolean b1) && (eval_boolean b2)
  | Or (b1, b2) -> (eval_boolean b1) || (eval_boolean b2)
  | BoolBinop (op, e1, e2) -> eval_bbop op e1 e2
