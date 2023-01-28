<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

# ConFreeLanDer in dart

**Con**text **Free** **Lan**guage **Der**ivatives in Dart

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.

## Syntax

The syntax is a simplified version of [[1]](#1) with the addition of the Reference operator, which handles recursivity in the context-free expressions.

```scala
Language 
   = Terminal
      = "∅" Empty
      | "ϵ" Epsilon
      | "τ" Token          (o: Object)
   | Composite
      = "|" Union          (lhs rhs: Language)
      | "∘" Concatenation  (lhs rhs: Language)
      | "Δ" Delta          (operand: Language)
      | "μ" Reference      (name: Object) (operand: Language)
```

## Semantics

The semantics is the same as [[1]](#1) with the addition of the rule for the Reference operator.

```scala
"D" derivative
D ∅         t ≜ ∅
D ϵ         t ≜ ∅
D (τ o)     o ≜ ϵ
D (τ o)     t ≜ ∅, where o ≠ c
D (L₁ | L₂) t ≜ (D L₁ t) | (D L₂ t)
D (L₁ ∘ L₂) t ≜ (Δ L₁) ∘ (D L₂ t) | (D L₁ t) ∘ L₂
D (Δ L)     t ≜ ∅
D (μ _₁ L)  t ≜ μ _₂ (D o t)

isNullable ∅         ≜ ⊥
isNullable ϵ         ≜ ⊤
isNullable (τ o)     ≜ ⊥
isNullable (L₁ | L₂) ≜ isNullable L₁ ∨ isNullable L₂
isNullable (L₁ ∘ L₂) ≜ isNullable L₁ ∧ isNullable L₂
isNullable (Δ L)     ≜ isNullable L
isNullable (μ _ L)   ≜ isNullable L

isProductive ∅          ≜ ⊥
isProductive ϵ          ≜ ⊤
isProductive (τ o)      ≜ ⊥
isProductive (L₁ | L₂)  ≜ isProductive L₁ ∨ isProductive L₂
isProductive (L₁ ∘ L₂)  ≜ isProductive L₁ ∧ isProductive L₂
isProductive (Δ L)      ≜ isProductive L
isProductive (μ _ L)    ≜ isProductive L
```

## Equivalences

```scala
∅ | p          = p
p | ∅          = p
ϵₛ | ϵₜ         = ϵ_{s ∪ t}

∅ ∘ p          = ∅
p ∘ ∅          = ∅
ϵₛ ∘ p         = p >> λu.(s, u)
p ∘ ϵₛ         = p >> λu.(u, s)

∅*             = ϵ_{∅}
p**            = p*

∅ >> f         = ∅
ϵₛ >> f        = ϵ_{s.map(λu.f(u))}
(ϵₛ ∘ p) >> f  = p >> λu. f( (s, u) )
(p >> f) >> g  = p >> (g ◯ f)
```

## Things that I don't like on the original article

1. The derive function is polluted with information needed for parseTree construction.
2. The cycles are direct
   1. Here I use explicit reference nodes, which reify the back-edges
3. Memoization for all composite nodes
   1. let's start by doing it first where it is really needed only.

## Some things to note

1. The reference name should not be used in the structural equality
   1. if the name it is used then we need α-conversion equality : ```X = 'a' | X ≡ Y = 'a' | Y```
2. if we want predicate tokens we might need structural equality on closures

```bnf
two = P(2)
X = (t)=> t ∈ {1, two} | X

≡

two = P(2)
Y = (t)=> t ∈ {1, two} | Y
```

3. Recursive vs iterative
   1. The recursive implementation
      1. does not need equality (and hash)
      2. relies on the implementation language stack
   2. An iterative implementation
      1. if it uses a hash-table to mark the visited nodes
         1. needs equality
      2. if it marks the nodes directly
         1. the nodes need to have the needed fields - (like an algorithm specific extension field)
         2. does not need equality
         3. In C -- if the algorithm specific marking is a small set (like 3-4 color) we could use pointer tagging.
         4. the marking can be implemented using Proxy objects.
4. CFE are a semiring 
   {
      zero: ∅, 
      one: ϵ, 
      +: union, 
      *: concatenation}


## Some numbers

- 2023/01/29 - v1.0.0: NestedQuantifiers(RunTime): 0.09164101415936503 us.

## References

<a id="1">[1]</a>
Matthew Might, David Darais, and Daniel Spiewak. "Parsing with derivatives: a functional pearl." Acm sigplan notices 46, no. 9 (2011): 189-195.