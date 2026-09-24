# TypeUp — slice order graphs

Open this file in Cursor and use **Markdown preview** (preview the file, not the raw source) so the diagrams render. GitHub preview also renders Mermaid.

Read **top → bottom** as “this is why we need the next box.” Dashed boxes are already done or parked.

**Status:** timer and slices A–I are in the app. History and the leftover task list stay parked.

```mermaid
flowchart TB
  P["Big feature: type like Monkeytype<br/>caret stays, space jumps the line left"]

  P --> NeedTarget["So we need a target to type against"]
  NeedTarget --> A["A. One word bank, generate list, show it"]

  A --> NeedKeys["So we need those characters to enter the popover"]
  NeedKeys --> B["B. Keystrokes into the session<br/>first key starts the timer"]

  B --> NeedJudge["So we need to know if each key was right"]
  NeedJudge --> C["C. Recognition: buffer vs current word<br/>space commits, backspace included"]

  C --> NeedPaint["So we need that judgment on screen"]
  NeedPaint --> D["D. Color: untyped / correct / incorrect"]

  C --> NeedJump["So we need the line to behave like the product"]
  NeedJump --> E["E. Viewport: active word stays in the middle"]

  B --> NeedStop["So we need the clock to end the test"]
  C --> NeedStop
  NeedStop --> F["F. Remaining == 0 → ignore further keys"]

  A --> NeedKnobs["So we can flavor generation without rewriting the engine"]
  F --> NeedKnobs
  NeedKnobs --> G["G. Settings: punctuation, caps, 1000 vs 5000"]

  G --> NeedMix["So a bigger bank does not flood the line with long words"]
  NeedMix --> I["I. Difficulty: fixed mix, short more often than long"]

  Done["Already done: timer, A–H"] -.-> B
  Done -.-> F
  Done -.-> G
  Done -.-> H["H. Backspace onto previous word"]

  Park["Parked: History, leftover Task list"]
```

Same chain as a straight pipeline (what you type next):

```mermaid
flowchart LR
  Done["Timer done"] --> A["A Words on screen"] --> B["B Keys"] --> C["C Judge"] --> D["D Color"]
  C --> E["E Jump"]
  C --> F["F Freeze at 0"]
  B --> F
  A --> G["G Settings knobs"]
  F --> G
  G --> I["I Difficulty"]
  C --> H["H Backspace previous word"]
  E --> H
```

Where “show words” vs “each key is written” sit:

```mermaid
flowchart LR
  A["A. Show words<br/>the target"] --> C["C. Judge"]
  B["B. Key written into a buffer<br/>the input"] --> C
  C --> D["D. Paint those letters<br/>on the word, not a second line"]
```

Slice table and rules: [CONTEXT.md](CONTEXT.md).
