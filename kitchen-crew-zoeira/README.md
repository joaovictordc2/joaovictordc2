# Kitchen Crew — Loja da Zoeira (protótipo Luau)

Projeto editável para **Roblox Studio** com módulos em **Luau**, pronto para ser versionado no GitHub e sincronizado usando **Rojo**. Esta entrega é uma **base demonstrativa jogável para desenvolvimento**, não um jogo Roblox integralmente finalizado/publicado.

## O que está incluído

- Cozinha de demonstração com bancadas `Preparar` e `Entregar`, clientes NPC decorativos, fichas grátis e recompensa de 5 tortas a cada 20 pedidos entregues.
- Arena da Zoeira e loja física básica geradas pelo servidor, mais interface para desktop/mobile.
- 14 pegadinhas com implementações iniciais: tortada, banana, gravidade invertida, confete, cabeção, espaguete, panela musical, farinha, bigode, pato, chuva de queijo, pizza, bolhas e trombone triste.
- Catálogo completo de conceitos adicionais marcado **Em breve** para itens ainda não implementados (sem cobrar ou consumir cargas).
- Três modos de participação: `Tranquilo` (padrão), `Leve` e `Caos`. Direcionamento respeita consentimento e cozinha protegida. Interrupções têm 90s de proteção.
- Cantinho da Confusão com convite aceito voluntariamente, sair ao caminhar para fora do palco, pausar e saldo de tempo acumulado persistido no servidor.
- Fichas de Risada, inventário e compras de cargas gratuitas, persistência por DataStore com `UpdateAsync`.
- Processamento idempotente de Developer Products via `ProcessReceipt` com recibo e recompensa gravados na mesma operação.
- Sons originais sintetizados em `assets/audio/*.wav` (precisam ser enviados ao Roblox Creator Dashboard para obter IDs).

### Limitações desta fase

O jogo **não está publicado no Roblox**; não há modelos 3D finais, animações de personagem finalizadas, NPCs com IA, passe Mestre da Zoeira, efeitos autorais completos para todo o catálogo, eventos Festival da Zoeira nem testes reais com 16 jogadores. A loja paga vem intencionalmente **desativada** até configurar IDs oficiais, preços reais e realizar testes de compra. A arte e os sons em jogo são placeholders estilizados; arquivos de áudio originais estão incluídos para publicação manual.

A demonstração gera seu próprio mapa de teste em `Workspace/KitchenCrewZoeira`. Para integrar ao seu Kitchen Crew original, substitua o mapa de demonstração pela geometria existente **e mantenha as referências/zonas** (`PrankArena`, `KitchenZone`, `Shop`, `CornerStage`, `RecipeStation`, `ServeStation`) ou adapte `WorldService.luau`. Não substitua um `ProcessReceipt` preexistente: consolide os handlers num só.

## Como abrir e editar

1. Instale **Roblox Studio**, **Rojo** e o plugin Rojo do Studio. Documentação: https://create.roblox.com/docs/pt-br/projects/external-tools
2. Baixe/clone o projeto do GitHub ou descompacte o ZIP no seu computador.
3. No terminal, dentro da pasta onde está `default.project.json`, execute:

```sh
rojo build -o KitchenCrew-Zoeira.rbxl
```

4. Abra o arquivo `.rbxl` gerado no Roblox Studio; ou execute `rojo serve` e conecte o plugin para sincronização em tempo real.
5. No Studio, abra **Game Settings > Security** e ative acesso do Studio a API Services *para testes de DataStore num jogo de testes publicado*. Não ative acesso a produção sem considerar segurança e backup dos dados.
6. Teste com pelo menos dois jogadores: modo `Leve` para tortadas; ambos em `Caos` dentro da Arena para experimentar Cantinho.

**Não confunda GitHub com publicação do jogo**: o código fica no GitHub, mas a experiência precisa ser criada/publicada pelo Roblox Studio.

## Ativar monetização (quando estiver pronta)

- Crie os **Developer Products** no Roblox Creator Dashboard **dentro desta mesma experiência**.
- Ajuste `src/ReplicatedStorage/Shared/ProductConfig.luau`: substitua cada `productId=0` pelo ID real. O campo `price` é apenas texto de referência: confirme o preço no painel Roblox.
- Suba os sons `assets/audio/` ao Roblox, obtenha os IDs e altere `src/ReplicatedStorage/Shared/AssetConfig.luau`.
- Faça testes de compras e reentrada antes de permitir compras reais. Nunca conceda itens em evento cliente de conclusão de compra.
- Se a experiência possuir outros produtos monetizados, integre todos ao único `MarketplaceService.ProcessReceipt` do jogo.

## Onde modificar

| Arquivo | Responsabilidade |
| --- | --- |
| `Shared/PrankConfig.luau` | nomes, tipos, custos, permissões e duração |
| `Shared/ProductConfig.luau` | pacotes e Developer Product IDs |
| `Shared/AssetConfig.luau` | IDs de áudio |
| `Services/PrankService.luau` | validação no servidor e uso de cargas |
| `Services/EffectService.luau` | efeitos e animações iniciais |
| `Services/CornerService.luau` | convites, saldo temporal e liberdade de sair |
| `Services/ProfileStore.luau` | DataStore, inventário, recompensas, recibos |
| `Services/KitchenService.luau` | pedidos de cozinha e recompensas |
| `Services/WorldService.luau` | mapa de demonstração e zonas seguras |
| `StarterPlayerScripts/Shop.client.luau` | interface visual e acessibilidade |

## Segurança e consentimento

- O jogador entra em `Tranquilo`, recusando automaticamente direcionamento. Mudar de modo é opção reversível.
- O cliente **não pode** inventar cargas, conceder saldo ou alterar duração de pegadinhas.
- O Cantinho só funciona com **convite voluntário**; dá para sair no botão ou andando.
- Os scripts não implementam pay-to-escape nem efeitos nocivos em áreas de trabalho.
- DataStore pode falhar: alterações e recibos ficam pendentes se a gravação falhar. `ProcessReceipt` retorna `NotProcessedYet` para novas tentativas.
- **Limite técnico conhecido:** o campo `purchases` cresce com o número de recibos. Para alto volume de transações, faça uma migração auditada da estratégia de recibos antes de atingir o limite por chave do DataStore.

## Testes

Veja `docs/TESTES.md` para um roteiro de validação manual no Studio e `tests/check_project.py` para verificação estrutural local sem depender de Roblox.

## Status de desenvolvimento

Entrega atual: base funcional demonstrativa, sem verificação de runtime no Roblox Studio. Próximas fases: assets definitivos, efeitos realmente físicos, NPCs interativos, confirmação da loja em grupo, testes de carga, acessibilidade completa, evento Festival, sistema de passe e integração com jogo principal.
