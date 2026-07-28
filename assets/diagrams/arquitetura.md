# 📊 Diagrama de Arquitetura

> Diagrama completo da arquitetura Hermes Agent no Umbrel OS.
> Veja [`../docs/arquitetura.md`](../docs/arquitetura.md) para a explicação detalhada.

```mermaid
flowchart TB
    subgraph Umbrel["Umbrel OS"]
        direction TB
        
        subgraph Containers["Hermes App Containers"]
            WEB["web container<br/>Dashboard / Terminal / Proxy"]
            GW["gateway container<br/>WebSocket Gateway"]
            WEB <--> GW
        end
        
        DATA["/opt/data<br/>Persistent Storage"]
        WEB --> DATA
        GW --> DATA
    end
    
    TELEGRAM["Telegram Bot API"]
    WHATSAPP["WhatsApp (Baileys)"]
    OPENROUTER["OpenRouter / Anthropic / OpenAI"]
    
    USER_PHONE["📱 Celular"] --> TELEGRAM
    USER_PHONE --> WHATSAPP
    USER_LAPTOP["💻 Notebook/MacBook (SSH)"] --> GW
    
    TELEGRAM --> GW
    WHATSAPP --> GW
    GW --> OPENROUTER
    GW --> TELEGRAM
    GW --> WHATSAPP
    
    DATA -->|"config.yaml"| GW
    DATA -->|"state.db"| GW
    DATA -->|"skills/"| GW
    DATA -->|"memories/"| GW
```

## Fluxo de uma mensagem

```
1. Usuário envia mensagem no Telegram/WhatsApp
2. Plataforma entrega ao gateway (polling no Telegram)
3. Gateway carrega contexto da sessão (state.db)
4. Gateway envia prompt ao modelo de IA (OpenRouter)
5. Modelo responde com texto ou tool calls
6. Gateway executa ferramentas e devolve ao modelo
7. Resposta final é entregue ao usuário
8. Conversa é persistida em state.db
```

## Persistência

```
/opt/data/
├── config.yaml          ← Config principal
├── .env                 ← API keys (⚠️ nunca commitado)
├── SOUL.md              ← Personalidade
├── state.db             ← SQLite (sessões, mensagens)
├── skills/              ← Skills instaladas
├── memories/            ← Memórias de longo prazo
├── sessions/            ← Histórico (.jsonl)
└── logs/                ← Logs do sistema
```
