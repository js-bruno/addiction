# Notificador do OpenCode para Telegram

CLI Go pequeno que envia uma mensagem para um chat ou grupo do Telegram. Ele não guarda o token e usa somente a API oficial do Telegram.

## Configuração do bot

1. Abra `@BotFather` no Telegram, use `/newbot` e guarde o token.
2. Adicione o bot ao grupo e envie uma mensagem nele.
3. Obtenha o `chat_id` abrindo `https://api.telegram.org/bot<TOKEN>/getUpdates`. Para grupos, o ID normalmente é negativo.

Defina as variáveis no ambiente:

```bash
export TELEGRAM_BOT_TOKEN='123456:ABC...'
export TELEGRAM_CHAT_ID='-1001234567890'
```

## Compilar e testar

```bash
go build -o opencode-telegram-notifier ./cmd/opencode-telegram-notifier
go test ./...
./opencode-telegram-notifier -message 'Mensagem de teste'
```

Também aceita texto pela entrada padrão:

```bash
printf '%s\n' 'Claude Code terminou.' | ./opencode-telegram-notifier
```

## Integrar ao OpenCode

O OpenCode pode emitir o evento `session.idle` quando termina de processar uma sessão. Crie um plugin no diretório de plugins do OpenCode, normalmente `~/.config/opencode/plugins/telegram.ts`, usando o binário compilado:

```ts
import type { Plugin } from "@opencode-ai/plugin"

export const TelegramNotifier: Plugin = async () => ({
  event: async ({ event }) => {
    if (event.type !== "session.idle") return

    const proc = Bun.spawn([
      "/caminho/absoluto/opencode-telegram-notifier",
      "-message",
      "OpenCode terminou de processar a sessão.",
    ], { stdout: "ignore", stderr: "inherit" })
    await proc.exited
  },
})
```

O processo que executa o OpenCode precisa receber `TELEGRAM_BOT_TOKEN` e `TELEGRAM_CHAT_ID`. O evento `session.error` pode ser tratado da mesma forma para avisar falhas.

Se a sua versão do OpenCode usar uma assinatura diferente de plugin, consulte `opencode plugin` ou a documentação instalada e mantenha a chamada ao binário acima; a integração Telegram permanece a mesma.

## Segurança

Não coloque o token no repositório. Use variáveis de ambiente, um arquivo de credenciais protegido ou o gerenciador de segredos do sistema.
