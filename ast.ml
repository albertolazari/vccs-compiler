type abop =
  | Add
  | Sub
  | Mult
  | Div
  | Mod

type expr =
  | Int of int
  | Var of string
  | AritBinop of abop * expr * expr

type bbop =
  | And
  | Or
  | Eq
  | Neq
  | Lt
  | Gt
  | Leq
  | Geq

type boolean =
  | True
  | False
  | Not of boolean
  | BoolBinop of bbop * boolean * boolean


type act =
  | Tau
  | Input of string * string
  | Output of string * expr

type proc =
  | Nil
  | Act of act * proc
  | Const of string * expr list
  | If of boolean * proc
  | Sum of proc * proc
  | Paral of proc * proc
  | Red of proc * (string * string) list
  | Res of proc * string list

type program =
  | Proc of proc
  | Def of string * string list * proc * program
