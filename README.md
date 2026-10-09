# Plugin do CucaCards para o Claude

Monte flashcards de idiomas **com áudio** no [CucaCards](https://cuca.felipenovaesrocha.xyz)
conversando com o Claude — em qualquer par de idiomas.

> English version below: [In English](#in-english).

## O que ele faz

Ele não sai despejando cards. Numa conversa normal, ele:

1. **pergunta** o que você estuda, seu nível, seu objetivo e de onde vem o
   conteúdo (um tema, uma lista sua, um texto, uma música);
2. **mostra** dois ou três formatos de card como exemplos reais no seu idioma;
3. cria **um card de teste**, com áudio, para você abrir no CucaCards e aprovar;
4. só então cria o resto, em grupos pequenos, sem repetir o que já existe.

## Instalar

Você precisa de uma conta no [CucaCards](https://cuca.felipenovaesrocha.xyz)
(criar é um toque, com Face ID ou digital).

> **Áudio: chegando.** O envio de áudio está sendo implantado no servidor do
> CucaCards. Até lá, os cards saem **sem áudio** em qualquer lugar — o plugin
> avisa quando isso acontece. Todo o resto funciona.

### No Claude Code (recomendado — é onde os cards vão ganhar áudio)

1. Instale o **[uv](https://docs.astral.sh/uv/getting-started/installation/)**, que
   gera a voz. No Mac e no Linux:

   ```
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

2. Dentro do Claude Code, rode:

   ```
   /plugin marketplace add kamikazebr/cuca-cards-plugin
   /plugin install cuca-cards@cuca-cards
   ```

3. Rode **`/mcp`**, escolha **cuca** e entre na sua conta do CucaCards — abre o
   navegador, você confirma com a passkey e volta. O Claude nunca vê sua senha;
   dá para revogar o acesso quando quiser.

### No app do Claude ou em claude.ai (sem áudio)

1. **Configurações → Plugins → Adicionar → Adicionar marketplace.**
2. Cole **`kamikazebr/cuca-cards-plugin`** e confirme.
3. Abra o plugin **Cuca cards** e toque em **Adicionar**.
4. Conecte o conector **cuca** e entre na sua conta (esse passo é manual).

No app os cards são criados **sem áudio**: a voz é gerada no seu computador, e
só o Claude Code consegue rodar isso. A entrevista e o card de teste funcionam
igual.

## Como usar

**Peça em linguagem normal**, em qualquer idioma:

- *"Quero flashcards de japonês, sou iniciante."*
- *"Faz cards com as palavras desta música:"* (e cola a letra)
- *"Cria 20 cards de espanhol sobre viagem, nível intermediário."*

Se ele não começar sozinho, chame direto:

```
/cuca-cards:cuca-flashcards
```

**Como saber que o plugin entrou:** a primeira coisa que ele diz é em qual
CucaCards está gravando (por exemplo, *"Conectado ao CucaCards em
https://cuca.felipenovaesrocha.xyz"*). Se não disser, use o comando acima.

### O que mais dá para pedir

| Peça | O que acontece |
|---|---|
| *"Põe áudio nesses cards"* | Gera a voz no idioma certo e anexa; mantém o áudio que já existir |
| *"Quero duas vozes, uma masculina e uma feminina"* | Vários áudios no mesmo lado do card, como no Anki |
| *"Vamos estudar aqui no chat"* | Mostra o card, espera sua resposta e registra a nota que **você** der |
| *"Apaga o deck X"* | Arquiva por 30 dias — dá para trazer de volta |
| *"Me lembra de revisar às 19h"* | Liga o lembrete diário (a permissão de notificação se dá no celular, em Ajustes) |

### Problemas comuns

- **Ele pede login de novo / "unauthorized":** rode `/mcp`, escolha **cuca** e
  entre de novo.
- **Os cards saíram sem áudio:** no app do Claude não há áudio (veja acima). No
  Claude Code, confira se o `uv` está instalado (`uv --version`).
- **O plugin não aparece no app depois de atualizar:** em **Gerenciar
  marketplaces**, use **Verificar atualizações** no `cuca-cards-plugin`.

## Detalhes técnicos

- A voz vem das vozes neurais do Microsoft Edge ([edge-tts](https://github.com/rany2/edge-tts)):
  grátis, sem conta, ~90 vozes. É um serviço não oficial; se parar, troque a
  função `synth` em `skills/cuca-flashcards/scripts/audio.sh` por qualquer TTS
  que gere mp3.
- O arquivo de áudio vai direto do seu computador para o CucaCards — não passa
  pela conversa.
- `dev/run-against.sh <url-do-mcp>` abre o Claude Code com uma cópia do plugin
  apontada para outro servidor do CucaCards (para testes).

---

## In English

A Claude plugin that builds language flashcards **with audio** in
[CucaCards](https://cuca.felipenovaesrocha.xyz) through a short conversation:
it interviews you, shows
sample cards in your languages, makes **one test card** for you to approve,
and only then creates the rest.

**Install (Claude Code — audio coming soon):** install [uv](https://docs.astral.sh/uv/),
then run `/plugin marketplace add kamikazebr/cuca-cards-plugin` and
`/plugin install cuca-cards@cuca-cards`, then `/mcp` → **cuca** → sign in.

**Install (Claude app / claude.ai — no audio):** Settings → Plugins → Add →
Add marketplace → `kamikazebr/cuca-cards-plugin`; add **Cuca cards**; connect
the **cuca** connector and sign in.

**Use:** just ask (*"I want Japanese flashcards, I'm a beginner"*), or run
`/cuca-cards:cuca-flashcards`. It first tells you which CucaCards it is
writing to — if it doesn't, the plugin isn't active.

## License

[GNU Affero General Public License v3.0 only](LICENSE) (`AGPL-3.0-only`).
