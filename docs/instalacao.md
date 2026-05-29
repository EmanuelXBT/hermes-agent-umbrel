# Guia de Instalação — Hermes Agent no Umbrel

## Passo a passo completo

### 1. Acessar o Umbrel

Abra o navegador e acesse:

```
http://umbrel.local
```

Se não resolver pelo nome, use o IP local do dispositivo:

```
http://192.168.1.X
```

### 2. Instalar o app

1. No dashboard, clique em **App Store**
2. Na barra de busca, digite `Hermes`
3. Clique no card do **Hermes Agent**
4. Clique em **Install**
5. Aguarde o download (~600MB, depende da sua internet)

### 3. Obter uma API Key

O Hermes precisa de um provedor de IA para funcionar. Recomendamos o
**OpenRouter** (acesso unificado a múltiplos modelos):

1. Acesse [openrouter.ai](https://openrouter.ai)
2. Crie uma conta
3. Vá em **Keys** → **Create Key**
4. Copie a key gerada (começa com `sk-or-...`)

> Alternativas: OpenAI, Anthropic, Google AI — qualquer um funciona.

### 4. Configurar a API Key

1. No Umbrel, abra o app **Hermes Agent**
2. Vá em **Settings** (ou edite `/opt/data/config.yaml`)
3. Configure:

```yaml
api:
  provider: "openrouter"
  key: "sk-or-sua-key-aqui"
```

4. Salve e reinicie o gateway

### 5. Criar bot no Telegram

1. Abra o Telegram
2. Converse com [@BotFather](https://t.me/BotFather)
3. Envie:

```
/newbot
```

4. Escolha um nome: `Meu Hermes Agent`
5. Escolha um username: `meu_hermes_bot` (deve terminar em `bot`)
6. **Copie o token** (ex: `7123456789:AAHx...`)

### 6. Conectar Telegram ao Hermes

No `config.yaml`:

```yaml
telegram:
  bot_token: "7123456789:AAHx..."
```

Reinicie o gateway.

### 7. Testar

1. Abra o Telegram
2. Encontre seu bot (pesquise o username)
3. Envie `/start`
4. Envie uma mensagem qualquer
5. O bot deve responder

### 8. Proteger com whitelist (recomendado)

Descubra seu user ID (envie `/start` para [@userinfobot](https://t.me/userinfobot))
e adicione:

```yaml
telegram:
  bot_token: "SEU_TOKEN"
  allowed_chats:
    - SEU_USER_ID
```

Reinicie o gateway após alterar.

---

## Verificação pós-instalação

```bash
# Verificar containers rodando
docker ps | grep hermes

# Verificar logs
tail -f /opt/data/logs/gateway.log

# Verificar config
cat /opt/data/config.yaml
```

---

## Próximos passos

- [Configuração avançada](configuracao.md)
- [Manutenção e limpeza](manutencao.md)
- [Dicas e skills úteis](dicas.md)
