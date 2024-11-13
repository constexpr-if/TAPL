open Option

type fileInfo = (
    string (* Filename *)
  * int    (* Line *)
  * int    (* Column *)
) option

type term =
    TmTrue   of fileInfo
  | TmFalse  of fileInfo
  | TmIsZero of fileInfo * term
  | TmIf     of fileInfo * term * term * term
  | TmZero   of fileInfo
  | TmSucc   of fileInfo * term
  | TmPred   of fileInfo * term

let rec isNumValue t =
  match t with
    TmZero(_) -> true
  | TmSucc(_, t1) -> isNumValue t1
  | _ -> false

let isBoolValue t =
  match t with
    TmTrue (_) -> true
  | TmFalse(_) -> true
  | _ -> false

let isValue t =
    isNumValue t
  ||isBoolValue t

let rec eval1 t =
  let eIf       fi t1 t2 t3 = map (function t1' -> TmIf    (fi, t1', t2, t3)) (eval1 t1)
  and eSucc     fi t1       = map (function t1' -> TmSucc  (fi, t1'))         (eval1 t1)
  and ePred     fi t1       = map (function t1' -> TmPred  (fi, t1'))         (eval1 t1)
  and eIsZero   fi t1       = map (function t1' -> TmIsZero(fi, t1'))         (eval1 t1)
  in match t with
    TmIf(_, TmTrue (_), t2, _) -> Some (t2)
  | TmIf(_, TmFalse(_), _, t3) -> Some (t3)
  | TmIf  (fi, t1, t2, t3)     -> eIf fi t1 t2 t3
  | TmSucc(fi, t1)             -> eSucc fi t1
  | TmPred(_, TmZero(_))       -> Some (TmZero (None))
  | TmPred(_, TmSucc(_, t1)) when (isNumValue t1) -> Some (t1)
  | TmPred(fi, t1)             -> ePred fi t1
  | TmIsZero(_, TmZero(_))     -> Some (TmTrue  (None))
  | TmIsZero(_, TmSucc(_, t1)) when (isNumValue t1) -> Some (TmFalse (None))
  | TmIsZero(fi, t1)           -> eIsZero fi t1
  | _ -> None

let rec eval t =
  match eval1 t with
    Some(t') -> eval t'
  | None -> t
