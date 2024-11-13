type term =
    TmVar of int
  | TmAbs of string * term
  | TmApp of term * term

type context = string list

let rec tmToStr ctx t = match t with
    TmVar(x) -> List.nth ctx x
  | TmAbs(x, t1) ->
      let ctx' = List.cons x ctx in
      Printf.sprintf "(lambda %s. %s)" x (tmToStr ctx' t1)
  | TmApp(t1, t2) ->
      Printf.sprintf "(%s %s)" (tmToStr ctx t1) (tmToStr ctx t2)

let shift d t =
  let rec walk c t = match t with
    TmVar(x) -> TmVar(if c <= x then (x+d) else x)
  | TmAbs(x, t1) -> TmAbs(x, walk (c+1) t1)
  | TmApp(t1, t2) -> TmApp(walk c t1, walk c t2) in
  walk 0 t

let subst j s t =
  let rec walk c t = match t with
    TmVar(x) -> if x=j+c then shift c s else TmVar(x)
  | TmAbs(x, t1) -> TmAbs(x, walk (c+1) t1)
  | TmApp(t1, t2) -> TmApp(walk c t1, walk c t2) in
  walk 0 t

let rec isVal t = match t with
    TmAbs(_, _) -> true
  | _ -> false

let rec eval1 t =
  let eApp1 t1 t2 = Option.map (function t1' -> TmApp (t1', t2)) (eval1 t1) in
  let eApp2 v1 t2 = Option.map (function t2' -> TmApp (v1, t2')) (eval1 t2) in
  let eAppAbs t12 v2 = Some (shift (-1) (subst 0 (shift 1 v2) t12)) in
  match t with
  | TmApp(TmAbs(_, t12), v2) when isVal v2 -> eAppAbs t12 v2
  | TmApp(v1, t2) when isVal v1 -> eApp2 v1 t2
  | TmApp(t1, t2) -> eApp1 t1 t2
  | _ -> None

let rec eval t =
  match eval1 t with
    Some(t') -> eval t'
  | None -> t
