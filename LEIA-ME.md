# PlusTV e TxGold para Vega OS (Fire TV novo)

NADA aqui foi compilado nem testado (o Vega SDK só roda em Ubuntu/macOS). Este projeto gera o app com o template oficial `vegaWebview` e troca o App.tsx por um que abre o Web Player do painel (`/player?tv=vega[&brand=txgold]`), com descoberta de domínio pelo mesmo arquivo `plustv.json`.

## Como gerar
1. Opção A (sem instalar nada): suba esta pasta num repositório GitHub → Actions → "Gerar VPKG (Vega OS)" → marca `plustv` e depois `txgold`. Baixe o `.vpkg` em Artifacts. (A instalação do SDK no runner é grande; pode falhar por espaço/tempo — se falhar, use a B.)
2. Opção B: num Ubuntu 20.04+ ou Mac: instale o SDK (`curl -fsSL https://sdk-installer.vega.labcollab.net/get_vvm.sh | bash && source ~/vega/env`) e rode `./generate.sh plustv` e `./generate.sh txgold`.
Saída: `out/<app>/build/{armv7,aarch64,x86_64}-release/*.vpkg` (armv7 = Fire TV Stick).

## Enviar à Amazon
Mesmo app/listagem do Fire OS: no Developer Console → app → Upload do binário Vega (pacote igual ao do APK: `com.plustv.player` / `com.txgold.player`; versão/build próprios). Não escreva "Vega" nos textos da loja.

## Pontos a validar no aparelho
- Controle remoto/foco dentro do player web e reprodução HLS/TS no WebView do Vega (não testado).
- Parâmetro `?tv=vega` é novo: o painel hoje trata como TV genérica; ajuste se algo ficar errado.
- Só HTTPS (domínios cleartext exigiriam `[network-traffic-policy.cleartext]` no manifest.toml).
