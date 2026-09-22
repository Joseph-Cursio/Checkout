# Checkout

A deliberately small SwiftUI shop app, used as the running example in the essay
*Architectural Fitness Functions for Swift Apps*.

It's a single target with four folders:

```
Sources/Checkout/
├── App/            composition root: the one place that picks an OrderStore
├── Domain/         Order, Money, DiscountCode, PaymentMethod, OrderStore protocol
├── Persistence/    CoreDataOrderStore
└── Presentation/   CheckoutView, CheckoutViewModel, SettingsView
```

Nothing in the build knows those folders are layers. The architecture lives in
[`.swiftprojectlint.yml`](.swiftprojectlint.yml), where
[SwiftProjectLint](https://github.com/Joseph-Cursio/SwiftProjectLint) can check it.

## Running the checks

```bash
git clone https://github.com/Joseph-Cursio/SwiftProjectLint.git
swift build --package-path SwiftProjectLint --product CLI -c release
export SWIFTPROJECTLINT="$PWD/SwiftProjectLint/.build/release/CLI"

cd Checkout
"$SWIFTPROJECTLINT" .          # the architecture rules
scripts/ratchet.sh             # the escape-hatch ratchet
```

On `main`, the only findings are two `info` notes saying `PaymentMethod` and
the settings screen's `supportedMethods` array list the same five names. That's
the cheap moment to consolidate, and the essay's §5 is about what happens if
you don't.

## One branch per section

Each `essay/` branch adds a single commit to `main` that breaks one fitness
function. Check one out and run the linter to see that finding and nothing else.

| Branch | Essay | The change | What reports it |
|---|---|---|---|
| `essay/s2-primitive-domain-type` | §2 | `apply(discountCode: String)` next to a `DiscountCode` type | `Primitive Named For Its Domain Type` (info) |
| `essay/s3-layer-violation` | §1, §3 | The view model constructs `CoreDataOrderStore()` "just for now" | `Layer Dependency` (warning, fails CI) |
| `essay/s4-escape-hatch` | §4 | `ReceiptCache: @unchecked Sendable` with no lock | `Unchecked Sendable` (warning); `scripts/ratchet.sh` fails |
| `essay/s5-drift` | §5, §6 | `PaymentMethod` gains `.applePay`; the settings array doesn't | `Parallel List Drift` (info) |
| `essay/s7-suppression` | §7 | Silences that drift finding with a suppression comment | `SwiftProjectLint Suppression` (warning, fails CI) |

For §6, on `essay/s5-drift`:

```bash
git log -S'applePay' -- Sources/Checkout/Presentation/SettingsView.swift
```

Empty output means `applePay` was never in the settings list. It wasn't
removed on purpose, it was never added, so adding it is safe.

## Building the app

```bash
swift build
swift run Checkout
```

Requires macOS 14 and Swift 6.
