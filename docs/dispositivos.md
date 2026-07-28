# 📱 Conectando Dispositivos ao Hermes

> O verdadeiro poder do Hermes no Umbrel está em acessá-lo de **qualquer lugar**, de **qualquer dispositivo**.

---

## Visão geral

```
┌──────────────────────────────────────────────────────┐
│                    UMbrel OS                         │
│  ┌────────────────────────────────────────────────┐  │
│  │              Hermes Agent (24/7)                │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────────┐  │  │
│  │  │ Telegram │  │ WhatsApp │  │  API Server   │  │  │
│  │  │  Gateway │  │  Gateway │  │  (port 18789) │  │  │
│  │  └────┬─────┘  └────┬─────┘  └──────┬───────┘  │  │
│  └───────┼─────────────┼───────────────┼──────────┘  │
└──────────┼─────────────┼───────────────┼─────────────┘
           │             │               │
     ┌─────▼─────┐ ┌─────▼─────┐  ┌──────▼──────┐
     │  Celular  │ │  Celular  │  │  Notebook/  │
     │ Telegram  │ │ WhatsApp  │  │  MacBook    │
     └───────────┘ └───────────┘  │  (SSH/CLI)  │
                                  └─────────────┘
```

---

## Telegram — O essencial

O Telegram é o meio mais direto e confiável. O gateway faz polling do Telegram Bot API — **não requer expor portas nem configurar webhooks**.

### Setup

1. Crie um bot com [@BotFather](https://t.me/BotFather):
   ```
   /newbot
   Nome: Meu Hermes
   Username: meu_hermes_bot
   ```

2. Copie o token (formato: `123456789:AAH...`)

3. Configure no Hermes:
   ```yaml
   # config.yaml
   gateway:
     platforms:
       telegram:
         enabled: true
         bot_token: "${TELEGRAM_BOT_TOKEN}"
   ```
   ```env
   # .env
   TELEGRAM_BOT_TOKEN=123456789:AAH...
   ```

4. Reinicie o gateway

### Segurança: Whitelist

Restrinja o bot ao seu user ID pessoal:

```yaml
telegram:
  bot_token: "${TELEGRAM_BOT_TOKEN}"
  allowed_chats:
    - SEU_USER_ID    # Descubra com @userinfobot no Telegram
```

**Sem whitelist, qualquer um que encontrar seu bot pode usá-lo.** O bot não aparece em buscas, mas o username pode ser descoberto.

### Teste

1. Envie `/start` para o bot
2. Envie uma mensagem qualquer
3. O bot responde em segundos

---

## WhatsApp — Alternativa mobile

O Hermes suporta WhatsApp via plugin Baileys — não requer Business API nem servidor externo.

### Setup

1. No dashboard do Hermes, habilite o plugin WhatsApp
2. O gateway gera um QR code
3. No WhatsApp do celular: **Configurações → Dispositivos conectados → Conectar um dispositivo**
4. Escaneie o QR code

> ⚠️ O WhatsApp pode desconectar após períodos longos sem uso. Basta reescanear.

### Limitações

- Não suporta chamadas de voz/vídeo
- Sessão vinculada ao dispositivo que escaneou o QR
- Meta pode bloquear contas que usam clients não-oficiais (raro, mas possível)

---

## MacBook / Notebook — Hermes Desktop

Para usar o Hermes direto do terminal do seu computador (CLI completa, com TUI e syntax highlighting), você conecta via **Hermes Desktop** com túnel SSH.

### Arquitetura

```
┌─────────────┐      SSH Tunnel       ┌─────────────────┐
│  MacBook    │ ◄──────────────────► │     Umbrel       │
│             │   localhost:9118      │                  │
│  hermes CLI │ ──────────────────►  │  hermes-gateway  │
│  (remote)   │                       │  (port 18789)    │
└─────────────┘                       └─────────────────┘
```

### Setup no Umbrel

O gateway do Hermes expõe uma API interna na porta `18789`. O túnel SSH redireciona essa porta para o MacBook.

1. **Habilite SSH no Umbrel:**
   - Dashboard → Settings → SSH → Enable

2. **Instale e configure o Hermes CLI no MacBook:**
   ```bash
   curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
   ```

3. **Crie o túnel SSH:**
   ```bash
   ssh -N -L 9118:localhost:18789 usuario@ip-do-umbrel
   ```
   
   O comando mapeia `localhost:9118` no MacBook para `localhost:18789` dentro do Umbrel.

4. **Configure o Hermes Desktop para usar o túnel:**
   ```bash
   hermes config set remote.enabled true
   hermes config set remote.url "http://localhost:9118"
   ```

5. **Conecte:**
   ```bash
   hermes
   ```

### Automatizando o túnel

Adicione ao `~/.ssh/config` no MacBook:

```
Host umbrel
    HostName 192.168.0.X        # IP do Umbrel na rede local
    User umbrel
    LocalForward 9118 localhost:18789
    ServerAliveInterval 60
    ExitOnForwardFailure yes
```

Depois, basta `ssh umbrel` para abrir o túnel. Para acesso fora de casa, combine com [Tailscale](https://tailscale.com) ou WireGuard.

### Personalidade compartilhada

O Hermes Desktop e o Telegram **compartilham a mesma instância** — mesma memória, mesmas skills, mesmo `state.db`. Uma conversa iniciada no celular continua no terminal e vice-versa.

---

## Discord / Slack / Outros

O Hermes suporta 10+ plataformas de mensageria. Consulte a [documentação oficial](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/) para configurar cada uma.

Todas as plataformas compartilham a mesma sessão e contexto.

---

## Próximo passo

Com os dispositivos conectados, veja [`configuracao.md`](configuracao.md) para personalizar o comportamento do agente.
