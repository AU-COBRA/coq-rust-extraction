(** * Definitions below are used in the extracted plugin *)

From MetaCoq.Erasure.Typed Require Import ExAst.
From MetaCoq.Erasure.Typed Require Import Extraction.
From MetaCoq.Erasure.Typed Require Import ResultMonad.
From MetaCoq.Erasure.Typed Require Import Utils.
From RustExtraction Require Import PrettyPrinterMonad.
From RustExtraction Require Import Printing.
From RustExtraction Require Import RustExtract.
From MetaCoq.Common Require Import Kernames.
From MetaCoq.Utils Require Import monad_utils.
From Coq Require Import List.
From Coq Require Import String.
From MetaCoq.Utils Require Import bytestring.

Import ListNotations.
Import MCMonadNotation.

Local Instance plugin_extract_preamble : Preamble :=
{| top_preamble := [
"#![allow(dead_code)]";
"#![allow(non_camel_case_types)]";
"#![allow(unused_imports)]";
"#![allow(non_snake_case)]";
"#![allow(unused_variables)]";
"";
"use std::marker::PhantomData;";
"";
"fn __nat_succ(x: u64) -> u64 {";
"  x.checked_add(1).unwrap()";
"}";
"";
"macro_rules! __nat_elim {";
"    ($zcase:expr, $pred:ident, $scase:expr, $val:expr) => {";
"        { let v = $val;";
"        if v == 0 { $zcase } else { let $pred = v - 1; $scase } }";
"    }";
"}";
"";
"macro_rules! __andb { ($b1:expr, $b2:expr) => { $b1 && $b2 } }";
"macro_rules! __orb { ($b1:expr, $b2:expr) => { $b1 || $b2 } }";
"";
"fn __pos_onebit(x: u64) -> u64 {";
"  x.checked_mul(2).unwrap() + 1";
"}";
"";
"fn __pos_zerobit(x: u64) -> u64 {";
"  x.checked_mul(2).unwrap()";
"}";
"";
"macro_rules! __pos_elim {";
"    ($p:ident, $onebcase:expr, $p2:ident, $zerobcase:expr, $onecase:expr, $val:expr) => {";
"        {";
"            let n = $val;";
"            if n == 1 {";
"                $onecase";
"            } else if (n & 1) == 0 {";
"                let $p2 = n >> 1;";
"                $zerobcase";
"            } else {";
"                let $p = n >> 1;";
"                $onebcase";
"            }";
"        }";
"    }";
"}";
"";
"fn __Z_frompos(z: u64) -> i64 {";
"  use std::convert::TryFrom;";
"";
"  i64::try_from(z).unwrap()";
"}";
"";
"fn __Z_fromneg(z : u64) -> i64 {";
"  use std::convert::TryFrom;";
"";
"  i64::try_from(z).unwrap().checked_neg().unwrap()";
"}";
"";
"macro_rules! __Z_elim {";
"    ($zero_case:expr, $p:ident, $pos_case:expr, $p2:ident, $neg_case:expr, $val:expr) => {";
"        {";
"            let n = $val;";
"            if n == 0 {";
"                $zero_case";
"            } else if n < 0 {";
"                let $p2 = n.unsigned_abs();";
"                $neg_case";
"            } else {";
"                let $p = n as u64;";
"                $pos_case";
"            }";
"        }";
"    }";
"}";
"";
"fn __N_frompos(z: u64) -> u64 {";
"  z";
"}";
"";
"macro_rules! __N_elim {";
"    ($zero_case:expr, $p:ident, $pos_case:expr, $val:expr) => {";
"        { let $p = $val; if $p == 0 { $zero_case } else { $pos_case } }";
"    }";
"}";
"";
"type __pair<A, B> = (A, B);";
"";
"macro_rules! __pair_elim {";
"    ($fst:ident, $snd:ident, $body:expr, $p:expr) => {";
"        { let ($fst, $snd) = $p; $body }";
"    }";
"}";
"";
"fn __mk_pair<A: Copy, B: Copy>(a: A, b: B) -> __pair<A, B> { (a, b) }";
"";
"fn hint_app<TArg, TRet>(f: &dyn Fn(TArg) -> TRet) -> &dyn Fn(TArg) -> TRet {";
"  f";
"}" ];
program_preamble := [
"fn alloc<T>(&'a self, t: T) -> &'a T {";
"  self.__alloc.alloc(t)";
"}";
"";
"fn closure<TArg, TRet>(&'a self, F: impl Fn(TArg) -> TRet + 'a) -> &'a dyn Fn(TArg) -> TRet {";
"  self.__alloc.alloc(F)";
"}" ] |}.

#[local]
Instance RustConfig : RustPrintConfig :=
  {| term_box_symbol := "()";
     type_box_symbol := "()";
     any_type_symbol := "()";
     print_full_names := true |}.

Definition default_attrs : ind_attr_map := fun _ => "#[derive(Debug, Clone)]".

Module T := Ast.Env.

Definition extract_lines
           (p : T.program)
           (remaps : remaps)
           (should_inline : kername -> bool) : result (list bytestring.string) bytestring.string :=
  entry <- match snd p with
           | T.tConst kn _ => ret kn
           | T.tInd ind _ => ret (inductive_mind ind)
           | _ => Err "Expected program to be a tConst or tInd"
           end;;
  let without_deps kn :=
      if remap_inductive remaps (mkInd kn 0) then true else
      if remap_constant remaps kn then true else
      if remap_inline_constant remaps kn then true else false in
  Σ <- extract_template_env
         (extract_rust_within_coq (fun _ => None) should_inline)
         (fst p)
         (KernameSet.singleton entry)
         without_deps;;
  let p := print_program Σ remaps default_attrs in
  '(_, s) <- timed "Printing"%string (fun _ => (finish_print_lines p));;
  Ok s.

Definition extract p remaps should_inline :=
  lines <- extract_lines p remaps should_inline;;
  ret (bytestring.String.concat MCString.nl lines).
