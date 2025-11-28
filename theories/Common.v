From MetaRocq.Erasure.Typed Require Import ResultMonad.
From MetaRocq.Erasure.Typed Require Import Utils.
From MetaRocq.Template Require Import Ast.
From MetaRocq.Template Require Import LiftSubst.
From MetaRocq.Template Require Import AstUtils.
From MetaRocq.Template Require Import Loader.
From MetaRocq.Template Require Import TemplateMonad.
From MetaRocq.Template Require Import Typing.
From MetaRocq.Utils Require Import utils.
From MetaRocq.Utils Require Import bytestring.
From MetaRocq.Erasure Require EAst.
From MetaRocq.SafeChecker Require Import PCUICSafeChecker.
From MetaRocq.SafeChecker Require Import PCUICWfEnvImpl.
From Stdlib.Strings Require Import Byte.

Import PCUICErrors.
Import MRMonadNotation.
Import String.


Definition to_globref (t : Ast.term) : option global_reference :=
  match t with
  | Ast.tConst kn _ => Some (ConstRef kn)
  | Ast.tInd ind _ => Some (IndRef ind)
  | Ast.tConstruct ind c _ => Some (ConstructRef ind c)
  | _ => None
  end.

#[warnings="-non-reversible-notation"]
Notation "<! t !>" :=
  (ltac:(let p y :=
             let e := eval cbv in (to_globref y) in
             match e with
             | @Some _ (ConstRef ?kn) => exact (kn : kername)
             | @Some _ (IndRef ?ind) => exact (ind : inductive)
             | @Some _ (ConstructRef ?ind ?c) => exact ((ind, c) : kername * nat)
             | _ => fail "not a globref"
             end in quote_term t p)).

Open Scope bs.

Definition extract_def_name_exists {A : Type} (a : A) : TemplateMonad kername :=
  a <- tmEval cbn a;;
  quoted <- tmQuote a;;
  let (head, args) := decompose_app quoted in
  match head with
  | tConstruct ind _ _ =>
    if eq_kername ind.(inductive_mind)
                        <%% sigT %%>
    then match nth_error args 3 with
         | Some (tConst name _) => ret name
         | Some t => tmFail ("Expected constant at second component, got " ++ string_of_term t)
         | None => tmFail ("existT: Expected 4 arguments, found less")
         end
    else tmFail ("Expected constructor existT at head, got " ++ string_of_term head)
  | _ => tmFail ("Expected constructor at head, got " ++ string_of_term head)
  end.

Notation "'unfolded' d" :=
  ltac:(let y := eval unfold d in d in exact y) (at level 100, only parsing).

Definition remap (kn : kername) (new_name : string) : kername * string :=
  (kn, new_name).

Definition quote_recursively_body {A : Type} (def : A) : TemplateMonad program :=
  p <- tmQuoteRecTransp def false ;;
  kn <- match p.2 with
       | tConst name _ => ret name
       | _ => tmFail ("Expected constant, got " ++
                       string_of_term p.2)
       end;;
  match lookup_env p.1 kn with
  | Some (ConstantDecl cb) =>
    match cb.(cst_body) with
    | Some b => ret (p.1, b)
    | None => tmFail ("The constant doesn't have a body: " ++ kn.2)
    end
  | _ => tmFail ("Not found: " ++ kn.2)
  end.

Fixpoint nat_syn_to_nat (t : EAst.term) : option nat :=
  match t with
  | EAst.tApp (EAst.tConstruct ind i []) t0 =>
    if eq_kername ind.(inductive_mind) <%% nat %%> then
      match i with
      | 1 => match nat_syn_to_nat t0 with
            | Some v => Some (S v)
            | None => None
            end
      | _ => None
      end
    else None
  | EAst.tConstruct ind 0 [] =>
    if eq_kername ind.(inductive_mind) <%% nat %%> then
      Some 0
    else None
  | _ => None
  end.

Definition _xI :=
  EAst.tConstruct {| inductive_mind := <%% positive %%>; inductive_ind := 0 |} 0 [].

Definition _xO :=
  EAst.tConstruct {| inductive_mind := <%% positive %%>; inductive_ind := 0 |} 1 [].

Definition _xH :=
  EAst.tConstruct {| inductive_mind := <%% positive %%>; inductive_ind := 0 |} 2 [].

Definition _N0 := EAst.tConstruct {| inductive_mind := <%% N %%>; inductive_ind := 0 |} 0 [].

Definition _Npos := EAst.tConstruct {| inductive_mind := <%% N %%>; inductive_ind := 0 |} 1 [].

Definition _Z0 := EAst.tConstruct {| inductive_mind := <%% Z %%>; inductive_ind := 0 |} 0 [].

Definition _Zpos := EAst.tConstruct {| inductive_mind := <%% Z %%>; inductive_ind := 0 |} 1 [].

Definition _Zneg := EAst.tConstruct {| inductive_mind := <%% Z %%>; inductive_ind := 0 |} 2 [].

Fixpoint pos_syn_to_nat_aux (n : nat) (t : EAst.term) : option nat :=
  match t with
  | EAst.tApp (EAst.tConstruct ind i []) t0 =>
    if eq_kername ind.(inductive_mind) <%% positive %%> then
      match i with
      | 0 => match pos_syn_to_nat_aux (n + n) t0 with
            | Some v => Some (n + v)
            | None => None
            end
      | 1 => pos_syn_to_nat_aux (n + n) t0
      | _ => None
      end
    else None
  | EAst.tApp _xO t0 => pos_syn_to_nat_aux (n + n) t0
  | EAst.tConstruct ind 2 [] =>
    if eq_kername ind.(inductive_mind) <%% positive %%> then Some n
    else None
  | _ => None
  end.

Definition pos_syn_to_nat := pos_syn_to_nat_aux 1.

Definition N_syn_to_nat (t : EAst.term) : option nat :=
  match t with
  | EAst.tConstruct ind 0 [] =>
    if eq_kername ind.(inductive_mind) <%% N %%> then Some 0
    else None
  | EAst.tApp (EAst.tConstruct ind 1 []) t0 =>
    if eq_kername ind.(inductive_mind) <%% N %%> then
      match pos_syn_to_nat t0 with
      | Some v => Some v
      | None => None
      end
    else None
  | _ => None
  end.

Definition Z_syn_to_Z (t : EAst.term) : option Z :=
  match t with
  | EAst.tConstruct ind 0 [] =>
    if eq_kername ind.(inductive_mind) <%% Z %%> then Some 0%Z
    else None
  | EAst.tApp (EAst.tConstruct ind i []) t0 =>
    if eq_kername ind.(inductive_mind) <%% Z %%> then
      match i with
      | 1 => match pos_syn_to_nat t0 with
            | Some v => Some (Z.of_nat v)
            | None => None
            end
      | 2 => match (pos_syn_to_nat t0) with
            | Some v => Some (-(Z.of_nat v))%Z
            | None => None
            end
      | _ => None
      end
    else None
  | _ => None
  end.

Definition parens (top : bool) (s : string) : string :=
  if top then s else "(" ++ s ++ ")".

Definition nl : string := String x0a EmptyString.

Definition string_of_list_aux {A} (f : A -> string) (sep : string) (l : list A) : string :=
  let fix aux l :=
      match l return string with
      | nil => ""
      | cons a nil => f a
      | cons a l => (f a ++ sep ++ aux l)
      end
  in aux l.

Definition string_of_list {A} (f : A -> string) (l : list A) : string :=
  ("[" ++ string_of_list_aux f "," l ++ "]").

Definition print_list {A} (f : A -> string) (sep : string) (l : list A) : string :=
  string_of_list_aux f sep l.
