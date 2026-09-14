# Nasam Build Ledger

**Implementation plan — what is finished, and what is next.**

| | |
|---|---|
| Branch | `chore/commit-assets-and-fix-pubspec` |
| Commits | 7 |
| `flutter analyze` | clean |
| `flutter test` | 239 passing |
| Last updated | 2026-09-14 |

Six of the seven foundation steps are shipped, and the app now runs end to end for
the first time — splash, onboarding and the four auth screens. What is left splits
cleanly by who is blocked: a short queue we can pick up now, a shorter one that only
you can unblock, and a set of questions for the designer.

---

## The sequence

Numbered because each step depended on the ones above it.

| # | Step | Status | Commit |
|---|---|---|---|
| 01 | **Assets and pubspec** — the whole `assets/` tree tracked, `assets/icons/` declared, config files marked secret-free | Shipped | `47b95f5` |
| 02 | **Colour tokens** — primitives and semantics from the design file, both modes, wired into `ColorScheme` plus a `ThemeExtension` for the tokens M3 has no role for | Shipped | `3b6c8c1` |
| 03 | **Almarai and the design ratio** — font bundled, twelve measured type styles, frame corrected to 402×874 | Shipped | `0b05385` |
| 04 | **Sizes and asset registry** — three contradicted constants corrected, nine layout values added, `AppAssets` made real and CI-guarded | Shipped | `2c0bfe1` |
| 05 | **Icon pipeline** — skipped by agreement; `AppIcons` holds the two glyphs as nearest-Material stand-ins with the export convention documented | **Waiting on export** | partial, in `50ae21b` |
| 06 | **Shared components** — button, text field and app bar rebuilt; OTP input, page dots and logo new; 40 goldens across light/dark × en/ar | Shipped | `50ae21b` |
| 07 | **Splash, onboarding, auth** — the splash now advances; onboarding is three slides; auth is four screens over a full slice against a mock datasource | Shipped | `038761e`, `b2c6bfc` |

Every step is one commit, so `git show <sha>` gives the full reasoning for any
decision here, including the ones that departed from the original spec and why.

---

## What we can pick up now

### Tests for the flows — *deferred debt*

The seven cubits and six pages added in step 07 have no coverage, deferred by
agreement so the feature work could move. The cubits are the cheap win: they hold
all the branching (submit guards, the rule breakdown, the reset-token hand-off) and
need no widget pumping.

**Order:** cubit tests first, then one golden per screen, then the router redirects.

### The WebSocket has two real bugs — *open*

`connect()` is never called anywhere in `lib/`, so the socket never starts — the
status dot in the app bar is wired to a stream that no one opened. Separately,
`_establishConnection` emits `connected` on the line after
`WebSocketChannel.connect()` returns, which is before the handshake completes, so
the dot would go green on a host that is refusing connections.

**Fix:** await the first frame or the `ready` future before emitting connected, and
start the socket where a session begins.

### Keep the mock out of production builds — *open*

`AuthRemoteDataSourceMock` is registered as *the* binding for
`AuthRemoteDataSource`. That is right while the API does not exist, but a prod build
today would ship a fake login that accepts one hard-coded password.

**Fix:** put it behind an injectable `@Environment` so a prod build fails loudly on
the missing binding instead of authenticating.

### Home is still a placeholder — *open*

Every route now leads somewhere real except the destination. `home_page.dart`
renders the string "Home Screen Placeholder". The tracking map is the obvious next
feature — `map_placeholder.png` was extracted for it — but no screen for it has been
designed or specified yet, so treat this as the next thing to scope rather than the
next thing to build.

**Needs:** a design for the post-login screen before it can be estimated.

---

## Blocked on you

Nothing here can move without something only you can supply.

### Export the two icons

User (Solar Bold) and Hamburger Menu (Solar Outline), both 24×24, single colour, no
embedded fills — an embedded fill defeats the tint and the icon stops following the
theme. Save as `assets/icons/user.svg` and `assets/icons/menu.svg`; the folder is
already declared in pubspec, so no config change is needed.

**Unblocks:** step 05, and replaces the Material stand-ins currently drawn in the
button and app bar.

### Approved copy for onboarding and auth

**This is the one item that must not ship as-is.** The design file supplied the
onboarding artwork but no text for it, and nothing for the four auth screens, so
**14 English strings are invented placeholders** — each marked as such in its ARB
description — and the matching Arabic is a translation of that invented English, not
design copy. The OTP screen is the exception: its two Arabic strings are verbatim
from the design.

**Where:** `lib/core/localization/l10n/app_en.arb` and `app_ar.arb`; grep
`PLACEHOLDER COPY`.

### A real vector export of the logo

`Vector.svg` is an SVG only by extension: Figma wrapped a 1 MB base64 PNG in a
`<pattern>` fill, which flutter_svg cannot draw, so it rendered as nothing — the
splash emblem had been invisible since it was written. `AppLogo` and the splash now
use `logo_mark.png` instead, which works but will not scale cleanly.

**Ask for:** a true vector export with real path data, not a traced bitmap.

---

## Questions for the designer

All implemented as specified; none are blocking.

| What | The issue | Shipped as |
|---|---|---|
| Warning & info tokens | The library defines success and fail but neither of these, while the socket dot and the warning/info snackbars need them | Mapped onto the secondary and primary ramps rather than inventing an amber. One line each to change |
| Dark `divider` | `neutral50` (#F6F6F6) is a near-white line on a #202020 page — stark next to the subtle #D9D9D9 it uses in light. Looks mirrored rather than chosen | As specified |
| Page-dot split | The block is given as 60×8 with three dots, but not how the 60 divides. Two readings both sum to 60 | Elongated active dot (24+8+8, 10pt gaps), the commoner pattern. Constructor arguments, so trivial to correct |
| `onboarding_2.png` | 402×481 is exactly 1× for a 402pt screen, so it will look soft on any 2× or 3× device | Shipped as-is; worth a re-export at 3× |
| `onboarding_3` | Shows people at a planning wall with sticky notes, which does not read as fleet tracking beside the other two | Shipped as-is |
| `primary` in dark | bluePurple500 on #202020 is roughly 2:1 — fine as a button fill under white text, but it will fail as text or a thin stroke | As specified. Avoid it for dark-mode text |

---

## Suggested order

| | Work | Why here |
|---|---|---|
| 1 | Environment-guard the auth mock | Small, and it closes a way to ship a fake login by accident |
| 2 | Cubit tests for the seven new cubits | Fastest coverage per hour, and it locks the flows before anyone edits them |
| 3 | WebSocket: start it, and stop lying about connected | Independent of the design queue, and the status dot is visibly wrong until it lands |
| 4 | Icons and copy, as they arrive | Both are drop-in by construction; neither needs a rebuild of anything |
| 5 | Goldens for the six new screens | Worth doing after the icons land, or they get regenerated twice |
| 6 | Scope the home / tracking screen | The only remaining placeholder route, and it needs a design first |

---

## Walking the app today

The mock answers predictably so every error path can be reached by hand:

- Sign in with any username and `Nasam@123`
- Any five-digit verification code is accepted — there is no backend to check
  one against, and a hard-coded "correct" code only tests whether the tester
  remembered it
- Use `unknown@nasam.sa` to see the unrecognised-address path

Any other password or code takes the failure branch. Each call waits 600 ms, so the
loading states are visible rather than theoretical.
