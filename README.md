# CucaCards plugin for Claude Code

Build language flashcards **with audio** in [CucaCards](https://cuca.felipenovaesrocha.xyz)
by talking to Claude. Any language pair.

It does not start dumping cards. It:

1. **asks** what you study, your level, your goal and where the content comes from;
2. **shows** two or three card shapes as real examples in your languages
   (word, sentence, listening…);
3. creates **one test card**, with audio, for you to open in CucaCards and approve;
4. only then creates the rest, in small batches, skipping duplicates.

## Install

In Claude Code:

```
/plugin marketplace add kamikazebr/cuca-cards-plugin
/plugin install cuca-cards@cuca-cards
```

Then run `/mcp`, choose **cuca** and sign in to your CucaCards account in the
browser. Claude never sees your password; you can revoke access at any time.

Now just ask: *"I want flashcards for Japanese, I'm a beginner"* — in any language.

## Audio

Generated on your machine with the neural voices from Microsoft Edge's
read-aloud ([edge-tts](https://github.com/rany2/edge-tts)): free, no account,
~90 voices. It needs **[uv](https://docs.astral.sh/uv/)** (or `pipx`) installed;
the script runs `uvx edge-tts` on demand.

The audio file goes straight from your machine to CucaCards — it does not pass
through the conversation.

> edge-tts uses an unofficial endpoint. If it stops working, replace the
> `synth` function in `skills/cuca-flashcards/scripts/audio.sh` with any TTS
> that writes an mp3.

## Requirements

- Claude Code
- A CucaCards account
- `uv` (or `pipx`) and `curl`

## Using claude.ai or the Claude app instead

Add `https://cuca.felipenovaesrocha.xyz/api/mcp` as a custom connector. You can
create cards there, but not audio: the voice script needs a shell, which only
Claude Code has.

---

# Em português

Plugin do Claude Code que monta flashcards de idiomas **com áudio** no CucaCards
conversando com você: entrevista curta, exemplos de card no seu par de idiomas,
**um card de teste** para você aprovar, e só depois o resto.

Instalar: os dois comandos `/plugin` acima, depois `/mcp` → **cuca** → entrar na
conta. Precisa do `uv` instalado para a voz.

## License

MIT
