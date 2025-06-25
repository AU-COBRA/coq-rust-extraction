(** Examples of (mutual) nested fixpoints *)
From RustExtraction Require Import Loader.
From Stdlib Require Import Arith.
From Stdlib Require Import Bool.
From Stdlib Require Import Extraction.
From Stdlib Require Import List.
From Stdlib Require Import Program.


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

Redirect "Ack.rs" Rust Extract ack.
Redirect "Even.rs" Rust Extract even.
