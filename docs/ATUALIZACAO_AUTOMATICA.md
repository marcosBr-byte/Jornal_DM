# Atualização automática das páginas

Implementada em 16/11/2026, mantendo Rails, Hotwire e a infraestrutura existente.

## Funcionamento

O controlador Stimulus `live-updates` consulta a própria URL a cada 20 segundos. Somente regiões cujo conteúdo mudou são substituídas. Filtros e paginação são mantidos porque a consulta usa o endereço atual completo. Não há recarregamento integral da página nem reinício contínuo da logo e do carrossel de destaques.

Áreas atualizadas: manchetes do Giro; destaques; notícias recentes e listagens; ranking de comentários; conteúdo, fotografias, relacionadas, curtidas e comentários da notícia aberta; agenda e galeria; indicadores e listas administrativas.

O Giro recebe novas manchetes por evento local, mantém o mesmo elemento animado e preserva o deslocamento horizontal. As manchetes continuam passando da direita para a esquerda mesmo se uma consulta falhar. Pausa manual e movimento reduzido continuam respeitados.

## Preservação de dados em edição

O editor de notícias não é substituído. Formulários alterados, regiões com foco, envios pendentes e galerias com foto ampliada ficam protegidos contra substituição naquele ciclo. O formulário de comentário permanece separado da lista atualizada. Não há envio automático de formulários.

Abas ocultas suspendem consultas; ao retornar, o controlador busca as novidades. Não são feitas requisições sobrepostas; cada uma tem limite de dez segundos. Falhas de rede preservam a tela atual e são tentadas novamente no próximo ciclo. Telas sem regiões dinâmicas, como login e envio de fotos, não recebem consultas desnecessárias.

Requisições de atualização não são armazenadas em cache e continuam sujeitas à autenticação e às permissões existentes. Atualizar uma notícia em segundo plano não cria uma nova leitura nos indicadores. A atualização não exige serviços externos nem novas tabelas ou migrações.

## Verificações

- Aplicação: 57 testes, 484 asserções, nenhuma falha, erro ou teste ignorado.
- Chrome headless: 7 testes, 65 asserções, nenhuma falha, erro ou teste ignorado.
- Verificação real de novas notícias entrando no Giro e no feed sem navegação, preservando o elemento da logo e do Giro.
- Verificação de comentários e curtidas atualizados com texto ainda digitado no formulário.
- Verificação de publicação chegando ao painel com título não salvo preservado no editor.
- Proteção contra incremento de leituras nas consultas em segundo plano e preservação das permissões.

Após a entrega, atualizar uma vez a aba já aberta carrega os novos arquivos. A partir daí as áreas dinâmicas passam a atualizar sozinhas. Não houve deploy no Render.
