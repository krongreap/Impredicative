--- Impredicate encodings of (higher) inductive types
-- Formalization by Steve Awodey and Jonas Frey

import imp_prop_trunc .helpers

open funext eq trunc is_trunc prod sum pi function is_equiv sigma sigma.ops

definition n_to_sn {n : ℕ₋₂} (A : trunctype.{0} n) : trunctype.{0} (n+1)
  := trunctype.mk A !is_trunc_succ

abbreviation U     := Type.{0} 
abbreviation UPrp  := trunctype.{0} -1
abbreviation USet  := trunctype.{0} 0
abbreviation UGpd  := trunctype.{0} 1 
notation `↑`       := n_to_sn   -- type \u-
notation `t` x   := trunctype.mk x !is_trunc_pi -- shorthand to truncate Pi's
notation x `=⟨` n `⟩` y := @trunctype.mk n (x = y) !is_trunc_eq


-- truncated products
definition tprod {n : ℕ₋₂} {A : Type} (B : A → trunctype.{0} n) 
  :  trunctype.{0} n
  := trunctype.mk (∀ x, B x) !is_trunc_pi
notation `π` binders `,` r:(scoped P, tprod P) := r

-- trucated arrows
definition tto {n : ℕ₋₂} (A : Type) (B : trunctype.{0} n) : trunctype.{0} n
  := π x : A, B
reserve infixr ` ⇒ `:21
infixr ` ⇒ ` := tto

-- truncated equality
definition teq {n : ℕ₋₂} {A : trunctype.{0} (n.+1)} (x y : A) : trunctype.{0} n
  := trunctype.mk (x=y) !is_trunc_eq
reserve infix ` == `:50
infix ` == ` := teq

-- truncated sigma
notation `σ` binders `,` r:(scoped P, sigma P) := trunctype.mk r !is_trunc_sigma

/- Encoding of Propostions -/

/- Conjunction of propositions -/

definition and (A B : UPrp) : UPrp := tΠ X : UPrp, (A ⇒ B ⇒ X) ⇒ X

-- constructor
definition con  {A B : UPrp} (p : A) (q : B) : and A B := λ X f, f p q

-- projections
definition proj1 {A B : UPrp} (p : and A B) : A := p A (λ x y, x)
definition proj2 {A B : UPrp} (p : and A B) : B := p B (λ x y, y)

-- recursor
definition and_rec {A B C : UPrp} (f : A ⇒ B ⇒ C)  (p : and A B) : C := p C f

-- beta rule
definition and_beta {A B C : UPrp} (f : A ⇒ B ⇒ C) (a : A) (b : B) 
  : and_rec f (con a b) = f a b := rfl

-- eta rule
definition and_eta {A B C : UPrp} (f : and A B ⇒ C)
  :  f = and_rec (λ a b, f (con a b)) 
  := eq_of_homotopy (λ x, !is_prop.elim)

-- universal property
definition and_univ_prop {A B C : UPrp} : (and A B ⇒ C) ≃ (A ⇒ B ⇒ C) 
  := equiv_of_is_prop (λ f a b, f (@con A B a b)) and_rec

-- eliminators
-- definition and_prl {A B : UPrp} (p : and A B) : A := p (λ x y, x)
-- definition and_prr {A B : UPrp} (p : and A B) : B := p (λ x y, y)


/- Disjunction of propositions -/

definition or (A B : UPrp) : UPrp := tΠ X : UPrp, (A ⇒ X) ⇒ (B ⇒ X) ⇒ X

-- constructors
definition or_inl {A B : UPrp} (a : A) : or A B := λX f g, f a

definition or_inr {A B : UPrp} (b : B) : or A B := λX f g, g b

-- recursor
definition or_rec {A B C : UPrp} (f : A ⇒ C) (g : B ⇒ C) (v : or A B) : C
  := v C f g

-- beta rules
definition or_beta_l {A B C : UPrp} (f : A ⇒ C) (g : B ⇒ C) (a : A)
  : or_rec f g (@or_inl A B a) = f a := rfl

definition or_beta_r {A B C : UPrp} (f : A ⇒ C) (g : B ⇒ C) (b : B)
  : or_rec f g (@or_inr A B b) = g b := rfl

-- eta rule
definition or_eta {A B C : UPrp} (h : or A B ⇒ C)
  : h = or_rec (λ a, h (@or_inl A B a)) (λ b, h (@or_inr A B b)) 
  := eq_of_homotopy (λ v, !is_prop.elim)

-- universal property
definition or_univ_prop {A B C : UPrp} 
  :  (or A B ⇒ C) ≃ and (A ⇒ C) (B ⇒ C)
  := equiv_of_is_prop (λ h X k, k (h ∘ or_inl) (h ∘ or_inr))
     (λ p v, v C (p _ (λ x y, x)) (p _ (λ x y, y)))

/- Propositional truncation -/

definition prop_trunc (A : Type) : UPrp := tΠ X : UPrp, (A ⇒ X) ⇒ X

-- constructors
definition prop_trunc_in {A : U} (a : A) : prop_trunc A := λ X f, f a

definition prop_trunc_eq {A : U} (x y : prop_trunc A) : x = y := is_prop.elim x y

-- recursor
definition prop_trunc_rec {A : U} {P : UPrp} (f : A → P) (a : prop_trunc A) : P
  := a _ f

-- beta rules (as in HoTT book, 199)
definition prop_trunc_beta {A : U} {P : UPrp} (f : A → P) (a : A) 
  :  prop_trunc_rec f (prop_trunc_in a) = f a := rfl

definition prop_trunc_beta' {A : U} {P : UPrp} (f : A → P) (a b : prop_trunc A)
  :  ap (prop_trunc_rec f) (prop_trunc_eq a b) 
     = is_prop.elim (prop_trunc_rec f a) (prop_trunc_rec f b) := !is_prop.elim

-- eta rule
definition prop_trunc_eta {A : U} {P : UPrp} (f : prop_trunc A → P)
  :  f = prop_trunc_rec (f ∘ prop_trunc_in) 
  := eq_of_homotopy (λ x, !is_prop.elim)

-- universal property
definition prop_trunc_univ_prop {A : U} {P : UPrp} 
  :  (prop_trunc A ⇒ P) ≃ (A ⇒ P)
  := equiv_of_is_prop (λ f a, f (prop_trunc_in a)) (λ a x, x P a)


/- Set encodings -/

/- Encoding of a set -/

-- System F style encoding
definition preSetEncode (A : USet) : USet := 
  tΠ (X : USet),  (A ⇒ X) ⇒ X

-- naturality condition
definition nSetEncode {A : USet} (α : preSetEncode A) : UPrp 
  :=  tΠ (X Y : USet) (f : X → Y) (h : A → X), α Y (f ∘ h) == f (α X h)

--refined encoding
definition  SetEncode (A : USet) : USet := σ(α : preSetEncode A), nSetEncode α

-- constructor
definition eta {A : USet} (a : A) : SetEncode A := ⟨λ X f, f a, λ X Y f h, rfl⟩

/- The "Basic Lemma" -/

definition helper {A : USet} (x : SetEncode A) : is_prop (nSetEncode x.1)
  := begin exact _, end

definition eta_is_equiv (A : USet) : is_equiv (@eta A) 
  := begin fapply adjointify,
           {λ e, e.1 A id},
           {intro, induction b with b n, fapply sigma_eq, 
           apply eq_of_homotopy2, intro X f, symmetry, apply n, 
           apply is_prop.elimo},
           {λ x, rfl}
     end

/- Product A × B of sets -/

-- System F encoding
definition  preProduct (A B : USet) : USet :=
  tΠ (X : USet), (A ⇒ B ⇒ X) ⇒ X

-- naturality condition
definition nProduct {A B : USet} (α : preProduct A B) : UPrp 
  := tΠ(X Y : USet) (f : X → Y) (h : A ⇒ B ⇒ X), f (α X h) == α Y (λ a, f ∘ h a)

-- refined encoding
definition  Product (A B : USet) : USet := σ(α : preProduct A B), nProduct α
     
-- constructor
definition Pair {A B : USet} (a : A) (b : B) : Product A B 
  := ⟨λ X f, f a b, λ X Y f g, rfl⟩

-- eliminators
definition Proj1 {A B : USet} : Product A B → A 
  := sigma.rec (λ alpha p, alpha A (λ x y, x))

definition Proj2 {A B : USet} : Product A B → B 
  := sigma.rec (λ alpha p, alpha B (λ x y, y))

-- recursor
definition Product_rec {A B C : Set} (f : A ⇒ B ⇒ C) (p : Product A B) : C 
  := p.1 C f

-- beta rule
definition Product_beta {A B C : USet} (f : A → B → C) (a : A) (b : B) 
  :  Product_rec f (Pair a b) = f a b := rfl

-- weak eta rule
definition Product_weak_eta {A B : USet} (x : Product A B)
  :  Product_rec Pair x = x
  := begin induction x with p n, fapply sigma_eq, apply eq_of_homotopy2, 
     intros X f, exact (n _ _ (Product_rec f) Pair), apply is_prop.elimo end

-- commuting conversion
definition Product_com_con {A B C D : USet} (f : A → B → C) (g : C → D)
  :  Product_rec (λ a b, g (f a b)) = g ∘ Product_rec f
  := (eq_of_homotopy (λ x, x.2 C D g f))⁻¹

-- strong eta rule
definition Product_eta {A B C : USet} (g : Product A B → C) 
  :  Product_rec (λ a b, g (Pair a b)) = g
  := (Product_com_con Pair g) ⬝ eq_of_homotopy (λ x, ap g (Product_weak_eta x))

-- classical eta rule
definition Product_classical_eta {A B : USet} (p : Product A B) 
  :   Pair (Proj1 p) (Proj2 p) = p
  :=  ap (λ f, f p) (Product_eta _)⁻¹ ⬝ (Product_weak_eta p)
        
-- universal property
definition Product_univ_prop {A B C : USet} : is_equiv (@Product_rec A B C)
  := adjointify Product_rec 
                (λ f a b, f (Pair a b))
                Product_eta
                (λ g, eq_of_homotopy2 (Product_beta g))

/- Sum A + B of sets -/

-- System F encoding
definition  preSum (A B : USet) : USet :=
  tΠ(X : USet), (A ⇒ X) ⇒ (B ⇒ X) ⇒ X

-- naturality condition
definition nSum {A B : USet} (a : preSum A B) : UPrp 
  := tΠ(X Y : USet) (f : X→Y) (h : A→X) (k : B→X), f(a X h k) == a Y (f∘h) (f∘k)

-- refined encoding
definition Sum (A B : USet) : USet := σ(α : preSum A B), nSum α

-- constructors
definition Sum_inl {A B : USet} (a : A) : Sum A B 
  := ⟨λ X f g, f a, λ X Y f h k, rfl⟩

definition Sum_inr {A B : USet} (b : B) : Sum A B 
  := ⟨λ X f g, g b, λ X Y f h k, rfl⟩

-- recursor
definition Sum_rec {A B X : USet} (f : A → X) (g : B → X) (c : Sum A B) : X 
  := c.1 X f g

-- beta rules
definition Sum_beta_l {A B X : USet} (f : A → X) (g : B → X)
  : Sum_rec f g ∘ Sum_inl = f := rfl

definition Sum_beta_r {A B X : USet} (f : A → X) (g : B → X)
  : Sum_rec f g ∘ Sum_inr = g := rfl

-- weak eta
definition Sum_weak_eta {A B : USet} (x : Sum A B) 
  : Sum_rec Sum_inl Sum_inr x = x
  := begin induction x with α p, fapply sigma_eq, 
     apply eq_of_homotopy3, intro X f g,  unfold Sum_rec, apply p, 
     apply is_prop.elimo end

--commuting conversion 
definition Sum_com_con {A B X Y : USet} (f : A → X) (g : B → X) (h : X → Y) 
  :  Sum_rec (h ∘ f) (h ∘ g) = h ∘ Sum_rec f g
  := begin apply eq_of_homotopy, intro α, induction α with α p, symmetry, apply p end

-- strong eta
definition Sum_eta {A B X : USet} (h : Sum A B → X) 
  :  Sum_rec (h∘Sum_inl) (h∘Sum_inr) = h
  := !Sum_com_con ⬝ eq_of_homotopy (λ x, ap h (Sum_weak_eta x))

--universal property
definition Sum_univ_prop {A B X : USet} 
  :  (Sum A B ⇒ X) ≃ (Product (A ⇒ X) (B ⇒ X))
  := equiv.MK (λ h, Pair (h ∘ Sum_inl) (h ∘ Sum_inr))
              (λ a, Sum_rec (Proj1 a) (Proj2 a))
              Product_classical_eta
              Sum_eta

/- Natural numbers -/

-- System F encoding
definition preNat : USet := tΠ X : USet, (X ⇒ X) ⇒ X ⇒ X

-- naturality condition
definition nNat (α : preNat) : UPrp 
  := tΠ (X Y : USet) (x : X) (y : Y) (h : X → X) (k : Y → Y) (f : X → Y),
         f x = y ⇒ f ∘ h = k ∘ f ⇒ f (α X h x) == α Y k y

-- refined encoding
definition Nat : USet := σ(α : preNat), nNat α

-- constructors
definition Z : Nat := ⟨λ X f x, x, λ X Y x y h k f u v, u⟩

definition S (n : Nat) : Nat
  := begin fconstructor, λ X h x, h (n.1 X h x), intros X Y x y h k f u v,
     refine (ap (λ f, f (n.1 X h x)) v) ⬝ _, apply ap k, apply n.2, exact u, 
     assumption end

-- recursor
definition Nat_rec {X : USet} (h : X → X) (x : X) (n : Nat) : X := n.1 X h x

-- beta rules
definition Nat_beta {X : USet} (h : X → X) (x : X) : Nat_rec h x Z = x := rfl
definition Nat_beta' {X : USet} (h : X → X) (x : X) (n : Nat) 
  :  Nat_rec h x (S n) = h (Nat_rec h x n) := rfl 

-- eta rules
definition Nat_weak_eta (n : Nat) : Nat_rec S Z n = n
  := begin 
     induction n with n p, 
     fapply sigma_eq, apply eq_of_homotopy3, intro X h x, 
     apply p Nat X Z x S h (Nat_rec h x), reflexivity, apply eq_of_homotopy,
     intro, reflexivity, apply is_prop.elimo end

definition Nat_eta {X:USet} (h:X→X) (x:X) (f:Nat→X) (p : f Z = x) (q:f∘S=h∘f)
  :  f = Nat_rec h x
  := begin fapply eq_of_homotopy, intro n, refine (ap f (Nat_weak_eta n))⁻¹ ⬝ _,
     unfold Nat_rec, induction n with m k, apply k, assumption, assumption end


/- 1-types -/

/- unit circle -/

definition preS1 : UGpd := tΠ ⦃X : UGpd⦄ ⦃x : X⦄, x = x ⇒ X

-- naturality
definition nS1 (α : preS1) : USet 
  := tΠ ⦃X Y : UGpd⦄ (f:X→Y) {x:X} (l:x=x), f (α l) == α (f◅l)

-- coherence
definition cS1id {α : preS1} (θ : nS1 α) : UPrp
  := tΠ ⦃X : UGpd⦄ ⦃x : X⦄ (l : x = x), θ id l =⟨-1⟩  @α X x ◅ ap_id l

definition cS1comp {α : preS1} (θ : nS1 α) : UPrp
  := tΠ ⦃X Y Z: UGpd⦄ (f : X→Y) (g:Y→Z) {x : X} (l : x = x), 
       θ (g ∘ f) l =⟨-1⟩ g◅(θ f l) ⬝ θ g (f◅l) ⬝ @α Z (g (f x)) ◅ ap_comp l f g

-- refined encoding
definition S1 : UGpd := σ(α : preS1) (θ : nS1 α), and (cS1id θ) (cS1comp θ)

-- constructors
definition prebase : preS1 := λ X x l, x

definition nbase : nS1 prebase := λ X Y f x l, refl (f x)

definition cidbase : cS1id nbase := λ X x l, ap_const (eq.rec rfl l) x

definition ccompbase : cS1comp nbase 
  := begin intros X Y Z f g x l, unfold teq, symmetry, refine idp_con _ ⬝ _, 
     exact eq.rec rfl (ap_comp l f g) end

definition base : S1
 := begin fconstructor, exact prebase, fconstructor, apply nbase, apply con, 
    apply cidbase, apply ccompbase end

definition preloop : prebase = prebase 
  := begin apply eq_of_homotopy, intro X, 
           apply eq_of_homotopy, intro x, 
           apply eq_of_homotopy, intro l, exact l end

definition aux1 (α β : preS1) (p : α = β) (θ : nS1 α) (ζ : nS1 β)
  (H : Π {X Y : UGpd} (f:X→Y) {x:X} (l:x=x), 
            θ f l ⬝ p ▻ Y ▻ f x ▻ (f ◅ l) =  f ◅ (p ▻ X ▻ x ▻ l) ⬝ ζ f l) 
  :  θ =[p] ζ
  := begin induction p, apply po_of_eq, repeat (apply eq_of_homotopy; intro),
     refine !H ⬝ _, apply idp_con end

definition aux2 {A : Type} {B : A → Type} {f g : Π a, B a} (H : f ~ g) (a : A) 
  : eq_of_homotopy H ▻ a = H a := right_inv apd10 H ▻ a

definition nloop : nbase =[preloop] nbase 
  := begin fapply aux1, intros X Y f x l, 
     krewrite idp_con, repeat krewrite aux2 end

definition loop : base = base 
  := begin fapply sigma_eq, exact preloop, fapply sigma_pathover',
     exact nloop, apply is_prop.elimo end

-- recursor 
definition S1_rec {X : UGpd} {x : X} (l : x = x) (a : S1) : X := @a.1 X x l

-- beta rules
definition S1_beta_base {X : UGpd} {x : X} (l : x = x) : S1_rec l base = x := rfl

definition aux {X : UGpd} {x : X} (l : x = x) {a b : S1} (p : a = b) 
  : S1_rec l ◅ p = p..1 ▻ X ▻ x ▻ l :=
begin
induction p, unfold pa,
end

definition S1_beta_loop {X : UGpd} {x : X} (l : x = x) : S1_rec l ◅ loop = l 
  := begin krewrite [aux, sigma_eq_pr1], repeat krewrite aux2 end

-- set_option unifier.max_steps 50000
-- definition aux1 (a : trunctype.carrier preS1)
-- (n : trunctype.carrier (nS1 a))
-- (c : trunctype.carrier (and (cS1id n) (cS1comp n)))
-- (X Y : UGpd)
-- (f : trunctype.carrier X → trunctype.carrier Y)
-- (x y : trunctype.carrier X)
-- (l : x = x) : 
-- (@a S1 base loop).2.1 X Y f x l 
-- ⬝ @n S1 Y (S1_rec (f ◅ l)) base loop 
-- ⬝ @a Y (f x) ◅ @S1_beta_loop Y (f x) (f ◅ l) 
-- = f ◅ @n S1 X (S1_rec l) base loop 
-- ⬝ f ◅ (@a X x ◅ @S1_beta_loop X x l) 
-- ⬝ @n X Y f x l:=
-- begin
-- --note z0 := (@a S1 base loop).2.1 X Y f x l,
-- note z1 := @n S1 Y (S1_rec (f ◅ l)) base loop,
-- note z2 := @a Y (f x) ◅ @S1_beta_loop Y (f x) (f ◅ l),
-- note z3 := f ◅ @n S1 X (S1_rec l) base loop,
-- note z4 := f ◅ (@a X x ◅ @S1_beta_loop X x l),
-- note z5 := @n X Y f x l,
-- unfold S1_rec at *,
-- end

definition S1_eta : S1_rec loop = id
  := begin apply eq_of_homotopy, intro a, induction a with a n, induction n with n c,
fapply sigma_eq, 
apply eq_of_homotopy, intros X,  
apply eq_of_homotopy, intros x,  
apply eq_of_homotopy, intros l,  
refine n (S1_rec l) loop⬝_,
apply ap (@a X x), apply S1_beta_loop,
 fapply sigma_pathover',
apply aux1, intros X Y f x l, esimp, unfold S1_rec,
repeat rewrite aux2,
repeat rewrite ap_con, repeat rewrite con.assoc',
assert d : cS1id n, exact proj1 c,
assert e : cS1comp n, exact proj2 c,
--note z := @d X x l,
exact sorry,
apply is_prop.elimo,
end
