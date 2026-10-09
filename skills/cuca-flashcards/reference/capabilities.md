# What CucaCards can do through the MCP

Read this when the user asks for something beyond creating cards, or asks
"what else can it do". Every claim here matches the tool descriptions; when a
tool's own description says more, the tool wins.

## Audio — the Anki format, and its nuances

Audio is not a separate attachment. It is a **marker inside a field**:
`[sound:file.mp3]`, exactly as Anki stores it. Everything follows from that:

- **Several audios in one field.** Two voices for the same sentence (a female
  and a male voice, Mexican and Castilian Spanish), or a word and then an
  example sentence: each is one more marker in the same field. Use
  `add_audio` with `mode: "append"`.
- **Each field has its own audio.** Front (`Frente`) and back (`Verso`) are
  independent — audio of the question on the front, audio of the answer on
  the back.
- **`add_audio` REPLACES by default.** If the field already has a marker, the
  new one takes its place and the old marker goes away (the response lists it
  in `removedMarkers`). To keep both, ask for `mode: "append"`.
- **Nothing is destroyed.** A replaced audio file stays on the server; its
  marker can be written back into the field with `update_card`.
- **Same text + same voice = same file.** `add_audio` with `text` and `voice`
  fingerprints the audio. If that pair already exists for this user, the file
  is reused (`reusedExistingAudio: true`) — you can even call it WITHOUT audio
  first to check, and only synthesise on a miss.
- **Editing text can silently drop audio.** `update_card` writes whole fields.
  If you rewrite a field and leave its `[sound:...]` marker out, the card
  stops playing it. Always read the raw field with `get_card` first and carry
  the markers through, unless the user asked to remove them.
- **Search hides the markers.** `search_cards` / `get_due_cards` show the
  rendered text without markers; they report `hasAudio`. Use `get_card` to see
  the raw fields.
- **Imported decks usually have recorded audio.** Check `hasAudio` / the raw
  fields before adding any; never replace a human recording unless asked.
- **Round-trips with Anki.** Because it is Anki's own format, audio survives
  exporting to Anki and importing from it.

When the user asks "can a card have two audios?", "can the back have audio?",
"what happens to the old audio?", answer from this list — and offer to do it.

## Readings (furigana / pinyin)

Anki's furigana syntax, rendered as ruby text above the word in `front`,
`back` and `hint` of the cards `create_card` makes: `日本語[にほんご]`,
`食[た]べる`, `你好[nǐ hǎo]`. The reading shows exactly where brackets are
written; a space before an annotated word is a delimiter and disappears. It
exports to Anki unchanged (`{{furigana:Field}}` is Anki's own filter). Search
ignores the readings. For imported decks, readings show only if their own
template uses `{{furigana:...}}` — check a card with `get_card` before
adding brackets to their fields. Brackets are the only place for a reading:
never romaji or readings in parentheses. Rules: SKILL.md 2b; converting old
cards that have romaji/parenthesized readings: SKILL.md 2c. In the review, a
字 button shows or hides the readings, and a hidden reading appears when the
word is tapped.

## Decks

| Tool | What it does | Watch out |
|---|---|---|
| `list_decks` | All decks with ids, full paths, counts | Every other tool takes ids, never names |
| `create_deck` | New deck; nest with `parentId` → `Parent::Child` | Idempotent by path: same path returns the existing deck |
| `delete_deck` | **Archives** the deck *and every subdeck* for 30 days | Say how many subdecks/cards go with it. Reversible |
| `restore_deck` | Brings an archived tree back whole | Restoring a subdeck also restores its parents |
| `list_archived_decks` | What can still be restored, and until when | Check here before saying a deck is "gone" |

`delete_deck` with `permanent: true` destroys cards and review history for
good. Only when the user explicitly asks for irreversible deletion.

## Cards

| Tool | What it does | Watch out |
|---|---|---|
| `create_card` | Batch create (array, up to 200) | One fixed note type: fields `Frente`, `Verso`, `Pista` (hint, shown with the answer), `Clase` (word class); one direction per entry. It cannot make cards shaped like an imported deck's custom note types — say so instead of a near-miss |
| `search_cards` | Find by front text, optionally in one deck; empty query = most recent | Searches the front only. Same `noteId` on two rows = one note with two cards, not a duplicate |
| `get_card` | One card with raw fields, note type, audio | Read before any edit |
| `update_card` | Writes named fields | Changes every card of that note; keeps the scheduling (the user's memory) intact |
| `suspend_card` / `unsuspend_card` | Parks a card out of the rotation, losing nothing | The reversible answer to "I don't want to see this one" |
| `delete_card` | Deletes the note, its sibling cards and their history | Irreversible. Prefer `update_card` (wrong text) or `suspend_card` (unwanted) |

## Studying inside the chat

`get_due_cards` returns today's queue (respecting daily limits — it is the
session, not the backlog). To quiz the user:

1. Show only the front. Wait for their answer.
2. Show the back. Ask how it went: **1 Again · 2 Hard · 3 Good · 4 Easy**.
3. Call `review_card` with **their** rating.

Never pick the rating yourself, never review a card the user did not answer,
never use `review_card` to "fix" a schedule. It writes their study history.

## Daily reminder (only on servers that have it)

`get_reminder` / `set_reminder`: a push notification once a day, at the user's
local time, only when cards are due. You can turn it on/off and change the
time; you **cannot** enable notifications on a device — the user does that in
the app's **Ajustes** on the phone. If `devices` is 0, tell them so. If these
tools are absent, the server does not have reminders yet.

## Not through the MCP — point to the app

- Importing an Anki `.apkg` and exporting the collection: **Ajustes** in the app.
- Daily limits and scheduler settings of a deck: the deck page in the app.
- Turning notifications on for a device: **Ajustes → Lembrete diário**.
