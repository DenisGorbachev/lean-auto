namespace Auto.Embedding

structure GLift.{u, v} (α : Sort u) : Sort (max u (v + 1)) where
  /-- Lift a value into `GLift α` -/    up ::
  /-- Extract a value from `GLift α` -/ down : α

def notLift.{u} (p : GLift.{1, u} Prop) :=
  GLift.up (Not p.down)

def andLift.{u} (p q : GLift.{1, u} Prop) :=
  GLift.up (And p.down q.down)

def orLift.{u} (p q : GLift.{1, u} Prop) :=
  GLift.up (Or p.down q.down)

def iffLift.{u} (p q : GLift.{1, u} Prop) :=
  GLift.up (Iff p.down q.down)

def impLift.{u}
  (p : GLift.{t + 1, v} (Sort t))
  (q : GLift.{u + 1, v} (Sort u)) :=
  GLift.up (p.down → q.down)

def liftTyConv.{u, v} (tyUp : GLift.{u + 1, v} (Sort u)) :=
  GLift.{u, v} (GLift.down.{u + 1, v} tyUp)

structure IsomType (α : Sort u) (β : Sort v) where
  f : α → β
  g : β → α
  eq₁ : ∀ (x : α), g (f x) = x
  eq₂ : ∀ (x : β), f (g x) = x

-- Isomorphic domain, β is the lifted one
def eqLift {α : Sort u} {β : Sort v} (I : IsomType α β) (x y : β) :=
  GLift.up.{_, v} (I.g x = I.g y)

def eqLift_refl {α : Sort u} {β : Sort v} (I : IsomType α β) (x : β) :
  GLift.down (eqLift I x x) := rfl

def eqLift.down {α : Sort u} {β : Sort v} (I : IsomType α β)
  (x y : β) (H : GLift.down (eqLift I x y)) : x = y := 
  let H₁ : I.f (I.g x) = I.f (I.g y) := H ▸ rfl
  let H₂ : x = I.f (I.g y) := I.eq₂ x ▸ H₁
  I.eq₂ y ▸ H₂

def eqLift.up {α : Sort u} {β : Sort v} (I : IsomType α β)
  (x y : β) (H : x = y) : GLift.down (eqLift I x y) :=
  H ▸ eqLift_refl I x

structure EqLift (α : Sort u) where
  eqF  : α → α → GLift.{1, v} Prop
  down : ∀ (x y : α), (eqF x y).down → x = y
  up   : ∀ (x y : α), x = y → (eqF x y).down

def forallF {α : Sort u} (p : α → Sort v) := ∀ (x : α), p x

-- Isomorphic domain, β is the lifted one
def forallLift {α : Sort u} {β : Sort v} (I : IsomType α β)
  (p : β → GLift.{w + 1, v} (Sort w)) :=
  GLift.up.{_, v} (∀ (x : α), GLift.down (p (I.f x)))

def forallLift.down
  {α : Sort u} {β : Sort v} (I : IsomType α β)
  (p : β → GLift.{w + 1, v} (Sort w)) (H : GLift.down (forallLift I p))
  (x : β) : GLift.down (p x) :=
  I.eq₂ x ▸ H (I.g x)

def forallLift.up
  {α : Sort u} {β : Sort v} (I : IsomType α β)
  (p : β → GLift.{w + 1, v} (Sort w))
  (H : ∀ (x : β), GLift.down (p x)) : GLift.down (forallLift I p) :=
  fun x => I.eq₁ x ▸ H (I.f x)

structure ForallLift (α : Sort t) where
  forallF : (α → GLift.{u + 1, v} (Sort u)) → GLift.{u + 1, v} (Sort u)
  down    : ∀ (p : α → GLift.{u + 1, v} (Sort u)), (forallF p).down → (∀ x : α, (p x).down)
  up      : ∀ (p : α → GLift.{u + 1, v} (Sort u)), (∀ x : α, (p x).down) → (forallF p).down

-- Isomorphic domain, β is the lifted one
def existsLift {α : Sort u} {β : Sort v} (I : IsomType α β)
  (p : β → GLift.{1, v} Prop) :=
  GLift.up.{_, v} (∃ (x : α), GLift.down (p (I.f x)))

def existsLift.down
  {α : Sort u} {β : Sort v} (I : IsomType α β)
  (p : β → GLift.{1, v} Prop)
  (H : GLift.down (existsLift I p)) : ∃ x, GLift.down (p x) := by
  cases H; case intro x proof => exists I.f x;

def existsLift.up
  {α : Sort u} {β : Sort v} (I : IsomType α β)
  (p : β → GLift.{1, v} Prop)
  (H : ∃ x, GLift.down (p x)) : GLift.down (existsLift I p) := by
  cases H; case intro x proof => exists I.g x; rw [I.eq₂]; exact proof

structure ExistsLift (α : Sort u) where
  existsF : (α → GLift.{1, v} Prop) → GLift.{1, v} Prop
  down    : ∀ (p : α → GLift.{1, v} Prop), (existsF p).down → (∀ x : α, (p x).down)
  up      : ∀ (p : α → GLift.{1, v} Prop), (∀ x : α, (p x).down) → (existsF p).down

end Auto.Embedding