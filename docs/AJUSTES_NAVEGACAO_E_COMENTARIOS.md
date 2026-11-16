# Ajustes de navegação, identidade e participação

Atualização de 16/11/2026.

- Filtros de categorias centralizados e com quebra de linha responsiva nos dois portais. Ícones locais específicos para Educação, Tecnologia, Ciência, Eventos, Esportes, Cultura, Projetos, Entrevistas, Comunidade e Avisos; categorias adicionais usam o ícone de etiqueta.
- Carteirinha retirada da apresentação. O Jornal DM mostra apenas sua logo à esquerda, com movimento vertical de subida e descida, respeitando movimento reduzido. Logo do cabeçalho ampliada e ponto após o nome removido.
- Inter para interface e textos; Lora para títulos e chamadas, com fontes alternativas caso o carregamento das fontes externas não esteja disponível.
- Acesso administrativo no cabeçalho representado somente por ícone de pessoa, com nome acessível e descrição para leitores de tela.
- FECT passa a ser item da navegação ao lado de Início, Últimas notícias e Agenda. No FECT, Jornal DM também fica na navegação.
- Mais lidas substituído por Mais comentadas nas páginas iniciais e listagens dos dois portais. Ranking calculado por consulta real, considerando somente notícias públicas e comentários publicados do ambiente correspondente. Comentários ocultos e notícias em rascunho não entram na contagem; empates usam data e identificador. As leituras anteriores foram preservadas como indicador administrativo.
- Recebimento de fotografias e Configurações retirados do menu administrativo. Os dados e as rotas existentes foram preservados; os demais itens do painel permanecem disponíveis.

Não houve alteração destrutiva de banco, nova migração, contratação de serviços ou implantação no Render. Assets recompilados e servidor local reiniciado em http://localhost:3000.

Verificações: suíte de aplicação com 55 testes e 465 asserções, sem falhas ou erros; consulta de ranking e isolamento dos portais cobertos pelos testes. Chrome: 4 testes e 45 asserções, sem falhas, erros ou testes ignorados. Carregamento Zeitwerk e compilação de assets concluídos; Brakeman sem alertas. A verificação visual em Chrome inclui navegação, filtros centralizados, logo única flutuante, carrossel, tema e ausência de transbordamento no celular.

## Giro, flutuação e tema do painel

O Giro agora repete os títulos até preencher a largura visível e usa dois grupos idênticos para um ciclo contínuo da direita para a esquerda. A velocidade se ajusta à largura, sem pausa automática ao passar o mouse. Duplicatas são ignoradas pela navegação por teclado e pela leitura assistiva. A logo junto ao título principal tem flutuação vertical de 38 pixels em ciclo de 3,6 segundos. As animações respeitam movimento reduzido e o Giro mantém pausa manual.

O controle de tema administrativo usa o mesmo botão circular com sol/lua e a mesma preferência salva da página principal. Verificados no navegador o deslocamento real do Giro para a esquerda, a mudança de posição vertical da logo e a alternância claro/escuro no painel: 4 testes de navegador, 52 asserções, sem falhas. A suíte de aplicação permaneceu com 55 testes e 465 asserções aprovados.
