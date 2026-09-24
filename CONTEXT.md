# TypeUp — app context

Kennard (“Kean”) is building this by hand at the Apple Developer Academy (Bali). This file is the shared brief for humans and agents: what the app is, how we work, and what to build next.

**He types every Swift line. Agents do not create, edit, or scaffold Swift files.**

---

## App idea

**TypeUp** is a Monkeytype-style typing test that lives in the **macOS menu bar**, not as a normal document window.

- Closed: only a menu bar icon (`keyboard.fill`).
- Open: a compact popover. Timer, settings gear, history, one line of words to type, restart / hide. Hide and Escape leave the menu bar icon running.

Reference product: [Monkeytype](https://github.com/monkeytypegame/monkeytype). Look is CSS + default config, not an official Figma. Defaults to copy from that repo: `Roboto_Mono`, theme tokens like Serika Dark (`--bg-color`, `--main-color`, untyped vs typed vs error). TypeUp is a small popover, not a full browser page — one word line, not a tall test board.

### Typing UX (product)

The word being typed sits in the **middle** of the line. A blinking line caret marks where the next character goes. On **space**, the whole line jumps left instantly so the next word sits in the middle. Committed words stay visible on the left.

Recognition is Monkeytype-like: letter vs expected letter (correct / incorrect / untyped), extra letters past the word length, space commits the word even if it was wrong.

### Word bank (bundle)

Two English lists, chosen in Settings:

- `TypeUp/Resources/en_1k.json` — 1000 words, from [deekayen’s 1–1000 gist](https://gist.githubusercontent.com/deekayen/4148741/raw/98d35708fa344717d8eee15d11987de6c8e26d7d/1-1000.txt). Mostly lowercase; a few entries are `"I"` or contractions (`don't`, `won't`). Treat those as data, not as the punctuation/capitalization settings.
- `TypeUp/Resources/en_5k.json` — first 5000 lines of [google-10000-english-usa-no-swears](https://github.com/first20hours/google-10000-english). A different list, not “the 1k file plus 4000 more.”

Both are JSON **arrays of strings**, common words first. Decode as `[String]`. Load with `Bundle.main.url(forResource:withExtension:)`. A test is 200 draws from the **first 200** words of the selected list. The setting changes which 200 that is.

### Settings

Punctuation on/off, capitalization on/off, and 1000 vs 5000. These are **filters on word generation**, not their own engine. They live on `SettingsViewModel` and are copied into `TypingViewModel` when a toggle changes. A running test keeps its current words; restart builds a new list. The gear opens `SettingsView`.

### Difficulty (slice I)

The generator copies Monkeytype’s default draw. It uses the 200 most common words in the selected list, picks any of them with equal chance, and allows a word to appear again as long as it is not the same as the word just before it. No length control in Settings.

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

Leftover from an early tutorial (do not wire into TypeUp): `Task` / `TaskModel.swift`, `TaskViewModel.swift`, `ContentView.swift` (todo list). The gear opens `SettingsView`. The history `NavigationLink` still opens `ContentView` — that cleanup stays parked with History.

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
- Prompt model: `words: [String]` + `currentIndex`. The line shows committed words, then the current word, then the rest, clipped on both sides. The current word stays centered. Space jumps that window left instantly. Color is per-letter on the current word and on committed words. The caret walks through the current word.

---

## Where the code is now

| Piece | Status |
|---|---|
| Menu bar extra → `MainMenuView` | Done |
| Duration cycle 15 → 30 → 60, Date-based countdown, `TimelineView` | Done |
| `restart()` clears the session and reshuffles words | Done |
| First keystroke calls `beginCountdown()` | Done |
| Word banks | `en_1k.json` and `en_5k.json`, 200-word prompt |
| Keyboard input, recognition, color, viewport shift | Done |
| Time remaining == 0 | Typing stops; `FinishedView` shows WPM and correct-word count |
| Settings: punctuation, capitalization, 1,000 vs 5,000 | Done. Gear opens `SettingsView` |
| Backspace onto the previous word | Done. Committed buffers are kept |
| Difficulty | Done (slice I). 200 most common words, equal chance, no word twice in a row |
| History | Clock icon still opens the leftover todo `ContentView` |

Session type: `TypeUp/ViewModels/TypingViewModel.swift` (`@MainActor @Observable`). View: `TypeUp/View/MainMenuView.swift`.

---

## Slice order (future development)

Why-this-then-that graphs: [SLICE_ORDER.md](SLICE_ORDER.md) (open with Markdown preview).

A slice is something Kean can run and see.

| | Slice | Why |
|---|---|---|
| **Done** | Timer: cycle 15/30/60, Date countdown, restart | First real session state |
| **A** | **One word bank + generate a list + show it** | Load a JSON bank, shuffle, fill `words: [String]`. `restart()` reshuffles. `[String]` is the model — not SwiftData, not a second ViewModel. |
| **B** | **Keystrokes into the session** | First character → `beginCountdown()`. `MenuBarExtra` receives keys. |
| **C** | **Recognition** | `currentIndex` + typed buffer for that word. Letter vs expected letter. Extra letters past the target. **Space commits** (even if wrong) and advances. |
| **D** | **Color** | Untyped / correct / incorrect per character. View of C’s state, not a second brain. |
| **E** | **Viewport** | The word being typed stays in the middle. A blinking line caret sits in that word. On space the whole line jumps left instantly; committed words remain on the left. |
| **F** | **Time remaining == 0 → ignore further keys** | Typing stops and the finish screen shows. |
| **G** | **Settings: punctuation, capitalization, 1000 vs 5000** | Inputs to the generator from A. `SettingsViewModel` owns the toggles. Gear opens `SettingsView`. A running test is not reshuffled until restart. |
| **H** | **Backspace onto previous word** | If `typedBuffer` is empty and `currentIndex > 0`, backspace **un-commits** — `currentIndex -= 1`, restore that word’s typed string (e.g. `"thenjs"`). Exact matches give the correct-word count back. |
| **I** | **Difficulty: how often each word length shows** | `generatePrompt()` draws from the 200 most common words in the selected bank. Each is equally likely. A word may repeat, but not twice in a row. |

**Park:** History, fixing history’s `NavigationLink`, deleting the leftover `Task` types. The finish screen already shows WPM and correct words; live WPM during the test is not a slice.

### Slice I — difficulty

Monkeytype’s default test uses its `english` list: 200 common words. Each word in that list is equally likely, a word may show up again later, and the same word is not placed twice in a row. That list is 130 short (1–4), 66 medium (5–7), and 4 long (8+), so a test is about that mix. TypeUp does the same draw on the first 200 words of whichever bank is selected. Those 200 are not the same list, so the mix is close rather than identical: the 1,000-word file’s first 200 are 153 short, 46 medium, and 1 long. The 5,000-word file’s first 200 are 142 short, 49 medium, and 9 long.

Words after those first 200 stay in the file and are not drawn. Punctuation and capitalization still run after the draw. Judging stays buffer vs `words[currentIndex]`. No new control on `SettingsView`.

Monkeytype’s own “difficulty” control (normal / expert / master) is what happens after a wrong letter. It is not this slice.

---

## Recognition (for slice C)

Word-at-a-time, not “the whole sentence as one string”:

- Target = `words[currentIndex]`.
- Buffer = what they typed for this word.
- For each index `i` in the buffer: match `target[i]` or mark incorrect.
- Letters past `target.count` are extra-incorrect (still shown).
- Space: commit, save that word’s typed string, `currentIndex += 1`, buffer = `""` (that commit is also when the line jumps left instantly, slice E).
- Backspace, buffer not empty: `removeLast()` on `typedBuffer`.
- Backspace, buffer empty and `currentIndex > 0`: un-commit. `currentIndex -= 1`, restore the saved string. If that string was an exact match, `correctWordCount` drops by one.
- Backspace, buffer empty and `currentIndex == 0`: do nothing.
- First key of the session (`startDate == nil`): `beginCountdown()`.
