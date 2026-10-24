# Roteiro de testes no Roblox Studio

Não substitui testes em servidor real com o Roblox Studio. Valide antes de abrir monetização.

1. **Carregamento:** com o acesso ao DataStore de teste ativado, entre na experiência. O inventário inicial deve ter 3 tortas, 2 bananas, 1 gravidade, 3 confetes, 65 fichas, modo Tranquilo e saldo 00:00.
2. **Cozinha:** prepare na bancada e entregue no balcão. Um pedido rende 20 Fichas de Risada. Repetir `Entregar` sem `Preparar` não gera fichas. Após 20 pedidos, receber 5 tortas.
3. **Comprar grátis:** abra loja, compre uma torta com fichas. Devem diminuir 15 fichas e aumentar exatamente uma carga. Se faltarem fichas, nenhuma alteração.
4. **Consentimento:** com dois jogadores, tente tortar alvo Tranquilo. Deve ser rejeitado e carga preservada; ative Leve no alvo e tente novamente fora da cozinha.
5. **Tortada:** deve mostrar projétil, creme parcial da tela por no máximo 10 segundos e contador diminuir uma carga. A conquista `firstPie` acrescenta 5 fichas na primeira vez.
6. **Banana:** tente fora da Arena (rejeitada, carga preservada); dentro (item debitado na colocação). Outro jogador Leve atravessa a casca, gira por ~2s, não morre, fica protegido de nova interrupção por 90s.
7. **Gravidade:** dois avatares na Arena; ação muda visual do alvo, retorna automaticamente; teste também respawn/sair no meio do efeito.
8. **Cantinho:** configure um Developer Product de teste com `cornerSeconds=600`, compre e verifique 10:00. Dois participantes em Caos, dentro da Arena: proprietário convida, convidado aceita. Teste encerrar, pausar e entrar novamente sem perder tempo não utilizado. Caminhar para fora do palco encerra sem prender o avatar. Teste desconexão.
9. **Retorno:** saia e entre novamente. Conferir fichas, cargas, saldo do Cantinho e modo persistidos.
10. **Compras pagas:** após configurar os Developer Product IDs, comprar 10 tortas deve conceder exatamente 10 unidades. Verifique duplicação de chamadas `ProcessReceipt` pelo mesmo PurchaseId: não duplica carga.
11. **Acessibilidade:** alternar efeitos visuais reduzidos. O creme e o blur não devem aparecer em modo reduzido. A loja deve caber em dispositivo móvel.
12. **Resistência:** 16 jogadores em simulação; observe DataStore throttling, limites de instâncias e latência. Não considere aprovado sem medição no Studio/servidor Roblox.

## Critérios pendentes

- Rig customizado R6 e R15 em todas as animações.
- Áudio publicado em Roblox e volume/acessibilidade por jogador.
- Acompanhamento automatizado de sessões do Cantinho em shutdown abrupto.
- Validação de recibos reais, versões especiais de pacotes e gamepasses.
- Festival com NPCs interativos, 16 usuários simultâneos, celular e console.
