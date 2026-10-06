---
name: cuca-flashcards
description: Build and manage language-learning flashcards with audio in the user's CucaCards collection. Use when the user wants to create flashcards (words, sentences, example sentences with pronunciation, listening cards) for any language, add or change audio on cards (several voices, front and back, Anki [sound:] format), fix, suspend or delete cards, organise or archive decks, study/quiz in the chat, or set the daily reminder. For new cards it interviews first, shows sample cards, creates ONE test card for approval, and only then creates the rest.
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/skills/cuca-flashcards/scripts/audio.sh *)
---

# Flashcards for CucaCards, one conversation at a time

CucaCards is a spaced-repetition flashcard app (Anki data model, FSRS
scheduling). Its MCP server — the `cuca` tools — creates decks, cards and audio
in the user's own collection. This skill is the method; the tools are the hands.

**Speak the user's language.** Every message to the user is in the language
they write to you in. The cards themselves are in whatever languages they are
studying. Nothing here assumes a language pair.

**The rule that matters most: no batch before a test card the user approved.**
Fifty cards in the wrong shape are fifty cards to delete. One card in the wrong
shape is a two-minute conversation.

## Where you are running decides the audio

Audio needs a shell: `audio.sh` synthesises the voice on the user's machine.
- **Claude Code** (you can run Bash): everything below applies.
- **claude.ai or the Claude app** (no shell): skip the `audio.sh server` check
  and all audio steps. Say once, at the start, that this environment creates
  cards **without audio**, and that audio works when the same plugin is used
  in Claude Code. Never try to produce audio another way here (no base64 of
  invented bytes, no other TTS).

If you are not sure, try `audio.sh server` once; if Bash is unavailable, you
are in the no-shell case.

## 0. Check the connection — and say where it points

First, find out which CucaCards server this plugin is talking to:

```bash
${CLAUDE_PLUGIN_ROOT}/skills/cuca-flashcards/scripts/audio.sh server
```

Tell the user in one line, with the site address (the URL without `/api/mcp`),
e.g. "Connected to CucaCards at https://cuca.felipenovaesrocha.xyz". If it is
not the default production address, say clearly that it is a **different
server** (a test copy of the plugin) so nobody creates cards in the wrong
place by accident. If the user expected another server, stop and say so.

Then call `list_decks`. If the `cuca` tools are missing or answer "unauthorized",
tell the user to sign in: in Claude Code, run `/mcp`, pick **cuca** and log in;
in the Claude app or claude.ai, connect the **cuca** connector in Settings →
Connectors. Either way it opens the CucaCards site, and the password never
reaches you. Stop until it works.

If `prepare_audio_upload` does not exist among the tools, that CucaCards server
predates direct audio upload: create the cards without audio and say so.

`list_decks` also tells you what they already have — use it in the interview
("you already have a deck called *Japanese::N5*, add there or start a new one?").

## 1. Interview — short, with defaults, never a form

Ask one or two things at a time, each with a suggested answer the user can
just accept. Skip what they already told you. You need:

1. **What they study and what they speak.** Target language + native language.
2. **Level and goal.** Beginner/intermediate/advanced; travel, exam (JLPT,
   DELE…), class, work, reading. The goal decides between words and sentences.
3. **Where the content comes from.** A topic ("food at a restaurant"), a list
   they paste, a text/lyrics/transcript, or "you choose for my level".
4. **Card shape** — show options as real cards *in their language pair*,
   never in the abstract (see section 2).
5. **Audio.** Default: audio of the target-language text on the **front**.
   Offer the back too (useful when the back is a sentence in the target
   language, or for listening practice). Offer two voices for the language —
   regional variant and gender — and let them pick (section 3).
6. **How many, and which deck.** Suggest a modest first batch (10–20).

Keep it light: if they say "just do something good for a beginner", choose
sensible defaults, say what you chose in one line, and go straight to the test
card.

## 2. Show the options as sample cards

Show 2–3 shapes, each as an actual card for *their* languages, as plain text:

```
A · word        Front: 猫 (ねこ)            Back: gato
B · sentence    Front: 猫が好きです。         Back: Eu gosto de gatos.
C · listening   Front: 🔊 (audio only)       Back: 猫が好きです。 — Eu gosto de gatos.
D · word + example, each with its own pronunciation
                Front: 猫 🔊(word)          Back: gato
                                                  猫が好きです。 — Eu gosto de gatos. 🔊(sentence)
```

Shape **D** is often the best default for vocabulary: the word is heard
alone on the front, and the back shows it *in use*, with the sentence spoken.
Put the example sentence (and its translation) in `back`; the word's audio goes
in `Frente`, the sentence's audio in `Verso`. Variations the user may want:
both audios on the front (word, then sentence — two markers in `Frente`, the
second with `mode: "append"`), or the same sentence in two voices.

Adapt to the language:
- **Japanese/Chinese:** ask about reading aids (furigana/pinyin) — on the front
  they give the answer away; in the hint they don't.
- **Gendered languages (es, fr, pt, de…):** include the article (*la mesa*,
  *der Tisch*).
- **Verbs:** infinitive alone, or inside a sentence? Sentences teach use;
  infinitives teach recognition.
- **False friends and traps** go in `hint` — it shows with the answer.

## 3. Voices

```bash
${CLAUDE_PLUGIN_ROOT}/skills/cuca-flashcards/scripts/audio.sh voices ja     # or es, pt-BR, en-GB...
```

Pick two plausible voices (e.g. `es-MX-DaliaNeural` vs `es-ES-AlvaroNeural`).
If the user wants to hear them first, write samples and give the paths:

```bash
${CLAUDE_PLUGIN_ROOT}/skills/cuca-flashcards/scripts/audio.sh sample "<sentence>" <voice> ./voice-a.mp3
```

The audio of the **native-language** side is usually unnecessary — ask before
adding it.

## 4. One test card

1. `create_deck` if needed (Anki-style `Parent::Child` names work), or use an
   existing deckId.
2. `create_card` with ONE card: `front`, `back`, optional `hint`, `clase`
   (word class) and `tags`. It returns the `cardIds`.
3. For each side that gets audio:
   - `prepare_audio_upload` → returns `uploadUrl` (one per file);
   - `audio.sh say "<exact text spoken>" <voice> "<uploadUrl>"` → prints
     `{"storageId":"..."}`;
   - `add_audio` with `cardId`, `field` (`Frente` for the front, `Verso` for
     the back), `uploadId` = that storageId, `text` = the text spoken,
     `voice` = the voice id, and `mode: "append"` — the text stays in the
     field, and a second audio in the same field (example sentence, another
     voice) is added instead of replacing the first.
   Speak only the target-language text — strip furigana in parentheses,
   translations and HTML before synthesising. For shape D, the back's audio
   is the example sentence alone, not the translation.
4. Ask the user to open CucaCards and look at it (the deck shows it under
   "Estudar" / the deck page) and play the audio. Ask: shape right? voice
   right? too long? Adjust and, if the shape changed, fix the test card with
   `update_card` (or delete it with `delete_card` after they agree).

Do not continue until they say it's good.

## 5. The batch

- **No duplicates:** before creating, `search_cards` in that deck for the
  fronts you are about to add, and drop the ones already there.
- **One `create_card` call per group** of up to ~20 cards (it takes an array).
- **Audio after each group**, one `prepare_audio_upload` + `audio.sh say` +
  `add_audio` per side per card. If a tool fails, retry once, then move on and
  list the failures at the end — never stop the batch silently.
- **Report briefly** after each group ("20/60 cards, audio done").
- At the end: total created, skipped duplicates, anything that failed, and
  where to find the deck.

## Beyond creating

Audio nuances (several audios per field, replace vs append, nothing is lost,
reuse of the same text+voice, editing without dropping audio), decks,
archiving, editing, suspending, studying in the chat and the daily reminder:
read [reference/capabilities.md](reference/capabilities.md) when the user asks
for any of it, or asks what else CucaCards can do. Answer from there and offer
to do it.

## Never

- Never create the batch before the test card is approved.
- Never delete or overwrite cards the user did not ask you to — imported decks
  often have their own recorded audio; `add_audio` replaces by default, which
  is why this skill always passes `mode: "append"` on new cards.
- Never paste audio as base64 into a tool call when `audio.sh` is available.
- Never rate/review cards on the user's behalf (`review_card`).
