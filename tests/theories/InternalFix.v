(** Examples of (mutual) nested fixpoints *)
From RustExtraction Require Import Loader.
From Coq Require Import Arith.
From Coq Require Import Bool.
From Coq Require Import Extraction.
From Coq Require Import List.
From Coq Require Import Program.


Fixpoint ack (n m : nat) : nat :=
match n with
| O => S m
| S p => let fix ackn (m : nat) :=
          match m with
          | O => ack p 1
          | S q => ack p (ackn q)
          end
        in ackn m
end.

(** Mutual fixpoints are extracted as mutual internal fixpoints with closure allocation *)
Fixpoint even n :=
  match n with
  | O => true
  | S m => odd m
  end
  with odd n :=
    match n with
    | O => false
    | S k => even k
    end.

Definition even_odd (n : nat) : bool := even n.

From RustExtraction Require Import ExtrRustBasic.
From RustExtraction Require Import ExtrRustUncheckedArith.

Redirect "extracted-code/Ack.rs" Rust Extract ack.
Redirect "extracted-code/Even.rs" Rust Extract even.
