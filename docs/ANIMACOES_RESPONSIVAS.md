# Animações em celulares e computadores

Atualização de 16/11/2026, conforme o pedido de manter as animações nos diferentes dispositivos.

A logo do Jornal DM e o Giro agora iniciam animados em telas móveis e de computador, inclusive quando o navegador informa movimento reduzido. Essa regra específica substitui a configuração anterior que desativava automaticamente essas duas animações pela preferência do dispositivo. As demais transições ainda podem respeitar essa preferência.

Foi adicionado um botão de pausa/retomada no cabeçalho e no painel. A escolha do visitante é salva localmente; nenhuma credencial é armazenada ali. O controle pausa a flutuação, o Giro e o avanço automático dos destaques. A pausa específica do Giro e os controles do carrossel continuam disponíveis.

A implementação usa CSS e APIs já presentes no projeto, sem biblioteca adicional. A movimentação foi verificada em Chrome com larguras de 390 e 1.440 pixels e preferência de movimento reduzido emulada. O teste observa a mudança real da posição da logo, o movimento do Giro, ausência de transbordamento, pausa e persistência após atualizar a página. Isso não representa teste físico de todos os modelos de celulares e notebooks.

Validação final: 8 testes no navegador, 77 asserções, nenhuma falha ou erro. A suite inclui o movimento real da logo com preferência de movimento reduzido emulada nas duas larguras, Giro em execução e persistência da pausa escolhida pelo visitante.
