# TypeUp — app context

Kennard (“Kean”) is building this by hand at the Apple Developer Academy (Bali). This file is the shared brief for humans and agents: what the app is, how we work, and what to build next.

**He types every Swift line. Agents do not create, edit, or scaffold Swift files.**

---

## App idea

**TypeUp** is a Monkeytype-style typing test that lives in the **macOS menu bar**, not as a normal document window.

- Closed: only a menu bar icon (`keyboard.fill`).
- Open: a compact popover. Timer, settings gear, history, one line of words to type, restart / quit.

Reference product: [Monkeytype](https://github.com/monkeytypegame/monkeytype). Look is CSS + default config, not an official Figma. Defaults to copy from that repo: `Roboto_Mono`, theme tokens like Serika Dark (`--bg-color`, `--main-color`, untyped vs typed vs error). TypeUp is a small popover, not a full browser page — one word line, not a tall test board.

### Typing UX (product)

The caret stays on the **first visible word**. The user types that word. On **space**, the whole list jumps left so the next word sits under the caret. **No animation.**

Recognition is Monkeytype-like: letter vs expected letter (correct / incorrect / untyped), extra letters past the word length, space commits the word even if it was wrong.

### Word bank (bundle)

One English list for now: `TypeUp/Resources/en_1k.json`. JSON **array of strings** (`["the", "of", …]`), 1000 words, from [deekayen’s 1–1000 gist](https://gist.githubusercontent.com/deekayen/4148741/raw/98d35708fa344717d8eee15d11987de6c8e26d7d/1-1000.txt). Decode as `[String]`. Load with `Bundle.main.url(forResource: "en_1k", withExtension: "json")`. Do **not** add a second corpus until Settings (slice G). The file is mostly lowercase; a few entries are `"I"` or contractions (`don't`, `won't`). Treat those as data, not as punctuation/capitalization settings.

### Settings (later)

Punctuation on/off, capitalization on/off. Optional later: 1000 vs 5000 word corpus. These are **filters on word generation**, not their own engine.

### Out of scope for now

WPM/accuracy UI, themes beyond a dark popover, iOS, a full windowed app, SwiftData history (until History is a real slice).

---

## Platform and stack

- **macOS** menu bar app (`MenuBarExtra` + `.menuBarExtraStyle(.window)`).
- Deployment target: **macOS 26.5**.
- **SwiftUI**. AppKit only if SwiftUI cannot take key focus in the popover — explain why before using it.
- **MVVM**, earned by state, not by folders. One session screen → one session ViewModel.
- No SwiftData until something is actually persisted (e.g. History results).

---

## How development works

Kean is a PM who codes. He has shipped SwiftUI + SwiftData (Cara). He is learning Apple-platform Swift **by typing it himself**. Speed is not the goal. Basics are explained, not skipped.

Work is **thin vertical slices**: something you can run and see. JSON on disk with no UI is not a slice. Color with no keystrokes is not a slice. Settings toggles with no generator are dead UI.

Typical loop:

1. Agree the slice (or **Validate mode** if Kean proposes the plan).
2. Swiftor teaches one small step: Goal → Why → Type this → What this is → Check → Next.
3. Kean types in Xcode, runs Preview / the menu bar extra, reports back.
4. Next step only after that, unless he says “keep going.”

Do **not** “fix” architecture by rewriting his files. Flag it, then teach the smaller correct step.

Leftover from an early tutorial (do not wire into TypeUp): `Task` / `TaskModel.swift`, `TaskViewModel.swift`, `ContentView.swift` (todo list). Gear and history `NavigationLink`s currently open `ContentView` — that is a later cleanup, not the next slice.

---

## Swiftor

**Swiftor** is the Swift tutor for this project: sit next to Kean while **he** writes every line. Not autocomplete. Not a code monkey.

Skill: `~/.cursor/skills/swiftor/SKILL.md` (or the `/swiftor` subagent). For Swift/SwiftUI/SwiftData, step-by-step “what to type,” architecture coaching, line-by-line explanation, or Validate mode — use Swiftor. Do not use it to ship the app by writing files.

### Hard rule

Never create, edit, delete, or scaffold **project Swift** (or Xcode project files). Read his code; teach against what he actually wrote. Snippets are labeled **Type this**. Never imply the agent already applied a change.

This `CONTEXT.md` is an exception: Kean asked for it as documentation, not as app source.

### Default lesson shape

One small step, then wait.

1. **Goal** — one sentence.
2. **Why** — beginner language, then the Swift name.
3. **Type this** — only this step.
4. **What this is** — each new keyword / wrapper / API.
5. **Check** — Preview, Simulator, or the compile error if it went wrong.
6. **Next** — one line. Do not dump the rest.

### Validate mode

Kean says **Validate mode**, “check my understanding,” or offers his own plan. Stay until he asks to leave or asks “what do I type.”

1. Quote him. Say what was on track and what was inaccurate. No cheerleading.
2. Explain in detail how to correct it (allowed to be long).
3. Do **not** start a Goal / Why / Type this lesson until he agrees and asks to type.

### Architecture already decided

- **Model** = data + rules that still make sense with no View. Not “a file in `Models/`.”
- Timer slice: no separate Model type. `Duration` nested in the ViewModel is enough. `startDate` is session state, not a document.
- **Same ViewModel for timer and typing** (`TypingViewModel`). First keystroke starts the countdown (`beginCountdown()`). Two ViewModels both owning “has the test started?” is two sources of truth.
- Do **not** name it `TimerViewModel` — the same object will own words, typed buffer, later WPM.
- Split ViewModels by **screen/session** (Settings, History later), not by widget.
- Prefer `@Observable` + `@MainActor` on the ViewModel; the view owns it with `@State`.
- Countdown is **Date math**, not `seconds -= 1`. Remaining = duration − `now.timeIntervalSince(startDate)`. Idle (`startDate == nil`) shows 15 / 30 / 60.
- Prompt model: `words: [String]` + `currentIndex`. Visible line is `words[currentIndex…]`, clipped. Space increments the index and clears the typed buffer. Color is per-letter state on the current word. The caret does not walk right; the window over the array moves.

---

## Where the code is now

| Piece | Status |
|---|---|
| Menu bar extra → `MenuBarContentView` → `MainMenuView` | Done |
| Duration cycle 15 → 30 → 60, Date-based countdown, `TimelineView` | Done |
| `restart()` clears `startDate` | Done (must also reshuffle words once a word list exists) |
| Debug **Begin Countdown** button | Temporary; first real keystroke should call `beginCountdown()` |
| Word bank JSON | `TypeUp/Resources/en_1k.json` exists; not loaded yet |
| Word line | Hardcoded dummy string |
| Keyboard input, recognition, color, viewport shift | Not started |
| `SettingsView` / `HistoryView` | `Hello, World!` stubs |
| Timer hits 0 | Number clamps at 0; typing is not frozen yet |

Session type: `TypeUp/ViewModels/TypingViewModel.swift` (`@MainActor @Observable`). View: `TypeUp/View/MainMenuView.swift`.

---

## Slice order (future development)

Why-this-then-that graphs: [SLICE_ORDER.md](SLICE_ORDER.md) (open with Markdown preview).

A slice is something Kean can run and see. Do these **in `TypingViewModel` + `MainMenuView`**. Leave Settings as a stub until G.

| | Slice | Why |
|---|---|---|
| **Done** | Timer: cycle 15/30/60, Date countdown, restart | First real session state |
| **A** | **One word bank + generate a list + show it** | Replaces the dummy sentence. Load `en_1k.json` from the bundle, shuffle, fill `words: [String]`. Not two corpora. `restart()` reshuffles. `[String]` is the model — not SwiftData, not a second ViewModel. Do not re-download or duplicate the JSON. |
| **B** | **Keystrokes into the session** 3| First character → `beginCountdown()`. Then remove the debug start button. `MenuBarExtra` must actually receive keys (first responder / focus). Treat this as its own slice. |
| **C** | **Recognition** | `currentIndex` + typed buffer for that word. Letter vs expected letter. Extra letters past the target. **Space commits** (even if wrong) and advances. **Backspace current word only** — empty buffer is a no-op; does **not** un-commit the previous word. |
| **D** | **Color** | Untyped / correct / incorrect per character. View of C’s state, not a second brain. |
| **E** | **Viewport** | Caret glued to the first visible word; list jumps left on space; no animation. After C works on a static line so layout and matching are not debugged at once. |
| **F** | **Time remaining == 0 → ignore further keys** | Only meaningful once B–C exist. |
| **G** | **Settings: punctuation, capitalization, optional 1000 vs 5000** | Inputs to the generator from A. Build A as plain lowercase words so G is a transform, not a rewrite. Own Settings with its **own** ViewModel when that screen has real state. Wire the gear `NavigationLink` to `SettingsView` as part of this work (not before). |
| **H** *(later)* | **Backspace onto previous word** | Monkeytype-default: if `typedBuffer` is empty and `currentIndex > 0`, backspace **un-commits** — `currentIndex -= 1`, restore that word’s typed string (e.g. `"thenjs"`), so extra letters can be deleted. Needs C’s commit **and** keeping per-word buffers, not throwing them away on space. Do **not** build this in C. |

**Park until after Typing Mode:** **H** (backspace onto previous word), History, WPM, dual JSON corpora, fixing history’s `NavigationLink`, deleting the leftover `Task` types (optional cleanup, never required to move A forward).

A and B can swap if Kean wants keys on the dummy sentence first. Prefer **A then B**: the dummy string will be thrown away, and A is how `restart()` becomes real.

---

## Recognition (for slice C)

Word-at-a-time, not “the whole sentence as one string”:

- Target = `words[currentIndex]`.
- Buffer = what they typed for this word.
- For each index `i` in the buffer: match `target[i]` or mark incorrect.
- Letters past `target.count` are extra-incorrect (still shown).
- Space: commit, `currentIndex += 1`, buffer = `""` (that commit is also when the list jumps, slice E).
- Backspace: `removeLast()` on `typedBuffer` only. Empty buffer → do nothing. Does **not** decrement `currentIndex` (that is **H**, later).
- First key of the session (`startDate == nil`): `beginCountdown()`.
