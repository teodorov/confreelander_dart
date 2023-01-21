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

## Equivalences

```lean
∅ | p ⟹ p
p | ∅ ⟹ p
ϵₛ | ϵₜ ⟹ ϵ_{s ∪ t}

∅ ∘ p ⟹ ∅
p ∘ ∅ ⟹ ∅
ϵₛ ∘ p ⟹ p >> λu.(s, u)
p ∘ ϵₛ ⟹ p >> λu.(u, s)

∅* ⟹ ϵ_{∅}
p** ⟹ p*

∅ >> f ⟹ ∅
ϵₛ >> f ⟹ ϵ_{s.map(λu.f(u))}
(ϵₛ ∘ p) >> f ⟹ p >> λu. f( (s, u) )
(p >> f) >> g ⟹ p >> (g ◯ f)
```

## Things that I don't like on the original article

1. The derive function is polluted with information needed for parseTree construction.
2. The cycles are direct
   1. Here I use explicit reference nodes, which reify the back-edges
3. Memoization for all composite nodes
   1. let's start by doing it first where it is really needed only.
