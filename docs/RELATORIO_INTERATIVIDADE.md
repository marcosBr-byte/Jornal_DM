# Jornal DM e FECT — relatório de implementação

> Histórico da primeira entrega. Consulte [Atualização editorial](ATUALIZACAO_VISUAL.md) para as novas regras de comentários, sessão, identidade fixa e layout.

Data: 16/11/2026. Alterações no projeto Rails existente; nenhuma publicação no Render foi realizada nesta execução.

## Funcionalidades implementadas

- Ambiente `/fect` com página própria, identidade em rosa/roxo e conteúdo separado do Jornal DM.
- Notícias, pesquisa, categorias, ordenação, paginação, notícias relacionadas e destaques por ambiente.
- URLs com identificador e título; os endereços numéricos antigos continuam aceitos.
- Campo de data/hora de publicação, incluindo agendamento: notícias futuras ficam fora das consultas públicas até o horário selecionado.
- Curtidas sem conta, com botão de coração, contador atualizado por JavaScript, retirada da curtida e estado preservado na navegação. Identidade gerada pelo servidor, cookie criptografado HttpOnly, digest HMAC, índice único e limitação de requisições por IP. Limpar cookies pode gerar outra identidade; o limite de requisições reduz abuso, sem pretensão de impedir toda automação distribuída.
- Comentários com nome opcional, identificação anônima, validação, limite de envios, campo antispam e exibição somente após aprovação. Conteúdo escapado na saída, inclusive no painel.
- Moderação com estados, aprovação, rejeição, exclusão e contagem de denúncias.
- Painel compartilhado com filtros e autorização no servidor para administrador geral, editor DM e editor FECT. Somente o administrador geral cria usuários e altera permissões; o último administrador geral não pode perder esse acesso.
- Categorias próprias, criação e exclusão protegida de categorias em uso. Categorias originais preservadas. O seletor do editor acompanha o ambiente escolhido.
- Eventos com nome, descrição, data/hora de Fortaleza, local, categoria e imagem; criação, edição e exclusão no painel; consulta pública de próximos eventos e eventos anteriores.
- Fotografias recebidas, revisão, aprovação, rejeição, publicação e exclusão. Publicação exige aprovação anterior. Legenda, álbum e vínculos opcionais com notícia e evento do mesmo ambiente.
- Galerias por ambiente, filtros por álbum, paginação, imagens ampliadas em diálogo e fotografias associadas às notícias.
- Páginas `/enviar-fotos` e `/fect/enviar-fotos`, câmera por ação do usuário, seleção múltipla, prévias locais, remoção, identificação opcional, confirmação de autorização, progresso e retorno de sucesso/erro. Até oito arquivos de 10 MB por envio.
- QR Code local para cada endereço de envio e possibilidade de fechar os recebimentos de cada ambiente nas configurações.
- Configuração da logo original por ambiente em `/admin/settings`, com upload e aplicação no cabeçalho e rodapé. O brasão da escola continua preservado.
- Tema claro/escuro, preferência persistente, preferência inicial do sistema, acompanhamento de mudanças do sistema enquanto não existe escolha manual, contraste e respeito a movimento reduzido.
- Menu móvel expansível, compartilhamento nativo/cópia do link e WhatsApp.
- Metadados individuais, Open Graph, dados estruturados NewsArticle, sitemap e regras de indexação administrativa.

## Recursos antigos preservados

Rails, Tailwind, PostgreSQL, Devise/Argon2, recuperação de senha, integrações OAuth existentes, proteção CSRF, política CSP, bloqueio de tentativas de autenticação, controle de concorrência da edição, página Nossa Escola, Agenda DM, Giro DM, editor Trix, notícias, destaques, capas antigas e configuração do Render.

As notícias anteriores receberam `environment=dm` por padrão, sem duplicação. Nenhuma migração aplicada apagou tabelas ou dados existentes. A tabela de arquivos antigos continua disponível para leitura das capas anteriores.

## Imagens e armazenamento

O processador usa libvips, já previsto no Dockerfile e na integração existente de processamento. Ele verifica tamanho, assinatura/formato real e decodificação, rejeita imagens acima de 40 megapixels ou 16.000 pixels por lado, corrige a orientação no thumbnail, limita o lado maior a 1.200 pixels e gera WebP com qualidade 82 e metadados removidos. SHA-256 do resultado evita repetir fotografias idênticas no mesmo ambiente.

Versões de 240, 640, 1.000 e 1.200 pixels são aceitas pelos endpoints protegidos de imagens. As galerias/cards têm seleção responsiva, dimensões definidas e carregamento tardio; a manchete tem prioridade. As versões são geradas sob demanda. Os tamanhos original e otimizado das novas fotografias são calculados dos bytes processados e exibidos no painel. Capas novas também guardam esses metadados.

Medição executada com uma **amostra sintética de gradiente**, não uma fotografia enviada pelo usuário:

- Original PNG: 768.900 bytes, 1.800 × 1.300 pixels.
- Resultado WebP: 7.576 bytes, 1.200 × 867 pixels.
- Redução dessa amostra: 99,01%.

Esse resultado não é uma previsão de economia para fotografias reais. A arte da logo fornecida na conversa não foi processada, pois não apareceu como arquivo acessível. Nenhuma comparação visual de compressão de fotos reais do usuário foi realizada.

No desenvolvimento/teste, os novos arquivos ficam no serviço Disk do Active Storage. Em produção, novos envios públicos, capas, imagens de eventos e logos exigem `ACTIVE_STORAGE_SERVICE=amazon` ou `r2`. O armazenamento `database` anterior foi preservado para os arquivos existentes; não houve migração automática de seus binários. Derivações dessas capas antigas são processadas em memória, sem acrescentar versões binárias ao banco. Nenhum serviço pago foi contratado ou ativado.

## Configuração necessária no Render

1. Fazer backup antes de atualizar o ambiente publicado.
2. Publicar o código pelo fluxo já existente; `bin/render-start` continua executando `db:prepare` antes do servidor.
3. Manter o mesmo `SECRET_KEY_BASE` entre deploys, além de `DATABASE_URL`, `APP_HOST`/`RENDER_EXTERNAL_HOSTNAME` e configurações existentes de SMTP/OAuth.
4. Escolher armazenamento persistente externo antes de habilitar novos arquivos. S3 usa `ACTIVE_STORAGE_SERVICE=amazon`, `AWS_REGION`, `S3_BUCKET`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`. R2 usa `ACTIVE_STORAGE_SERVICE=r2`, `R2_ENDPOINT`, `R2_BUCKET`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`. Exemplos sem credenciais estão em `.env.example`.
5. Manter o bucket privado. As imagens são entregues pelos controladores Rails, que verificam publicação e/ou permissões; as rotas públicas padrão e direct uploads do Active Storage continuam desabilitadas.
6. Usar a imagem Docker atualizada: ela inclui libvips e `qrencode`, que gera o QR localmente.
7. Em Configurações e logo, enviar a arte original do Jornal DM e, quando disponível, a do FECT. Em Usuários e permissões, atribuir os ambientes dos editores.

Custo adicional contratado nesta execução: **R$ 0**. `qrencode` e as bibliotecas utilizadas são gratuitas. O custo de hospedagem e armazenamento depende do plano existente, do provedor escolhido e do consumo; não foi feito orçamento nem confirmação de elegibilidade a franquias gratuitas. O Disk atende ao desenvolvimento, mas não resolve persistência no Render gratuito. A escolha entre um plano com franquia gratuita de armazenamento externo e um serviço pago continua pendente de avaliação antes de ativação.

## NFC e QR Code

Gravar um endereço HTTPS na etiqueta:

- Jornal DM: `https://SEU_DOMINIO/enviar-fotos`.
- FECT: `https://SEU_DOMINIO/fect/enviar-fotos`.

O NFC apenas abre o link; o colaborador seleciona/tira fotos e confirma o envio. Não há senha administrativa nas etiquetas. Os QR Codes são gerados em `/envio-qr` e `/fect/envio-qr`; os endereços não são enviados a um gerador externo. Formulários têm CSRF, validação real dos arquivos, limites por IP e confirmação de envio. O identificador da etiqueta não é utilizado como credencial.

A configuração de recebimento permite fechar todos os envios de um ambiente. Não foram implementadas credenciais individuais ou revogação por etiqueta. Não foram gravadas etiquetas físicas, escaneados QR Codes em celular nem testadas câmera/permissões em iPhone ou Android físicos.

## Sessão administrativa

Autenticação existente Devise/Argon2 mantida. Cookie de sessão Rails com HttpOnly, SameSite=Lax e Secure em produção. Navegação interna e atualização preservam a sessão; Devise aplica expiração por 30 minutos de inatividade. A opção Sair continua encerrando a autenticação e invalidando o mecanismo remember-me conforme a configuração existente. As permissões são verificadas no servidor a cada acesso administrativo.

## Migrações aditivas

- `20261116090000_add_editorial_environments.rb`: ambientes de notícias/editores, curtidas, comentários, eventos e fotografias recebidas.
- `20261116091000_add_editorial_categories.rb`: categorias por ambiente, copiando os nomes já utilizados.
- `20261116092000_add_site_settings.rb`: identidade visual e abertura/fechamento dos recebimentos.
- `20261116093000_associate_editorial_photos.rb`: associação opcional de fotografias com notícia, com preservação das fotografias na exclusão da notícia.
- `20261116094000_add_photo_fingerprints_and_events.rb`: identificação de duplicadas e vínculo opcional com evento.

Foram aplicadas nos ambientes de desenvolvimento e teste usados nesta execução. Nenhuma atualização do Render foi feita.

## Verificações e correções

A suíte antiga passou inicialmente com 33 testes. A suíte ampliada cobre isolamento público e administrativo, edição/publicação, sessão/logout, curtidas, comentários/moderação/denúncias, imagens válidas e inválidas, compressão, aprovação obrigatória, galerias, eventos, configurações, sitemap, geração de QR, capas responsivas, agendamento, permissões de usuários e aplicação de uma logo sintética de teste.

Os testes com Chrome headless cobrem edição e publicação pelo Trix, curtidas sem navegação, persistência do estado, comentários, tema persistente, menu móvel, ausência de transbordamento nas telas verificadas e envio com prévia/remoção/retorno de sucesso. Foram verificadas larguras de 390 e 1.440 pixels; isso não equivale a homologação de todos os dispositivos.

Correções encontradas na verificação: consulta DISTINCT de álbuns com ordenação incompatível no PostgreSQL; retorno de sucesso consumido por redirecionamento do envio assíncrono; atributos de anexo convertidos indevidamente pelas strong parameters; consultas do sitemap após a introdução de URLs com título; e carregamento de novos assets diante do manifesto pré-compilado antigo. As verificações finais estão registradas abaixo.

## Limites e pendências

- **Logo enviada na conversa:** não estava disponível como arquivo no workspace. A tela para adicioná-la foi implementada e testada com imagem sintética, mas a arte original ainda precisa ser anexada em PNG/JPG/WebP para aplicação exata.
- Configurar e testar bucket privado S3/R2 e atualizar o Render. Integração real com serviços externos não foi exercitada nesta execução.
- Homologar NFC, QR Code e câmera em aparelhos físicos e verificar autorizações editoriais de imagens de estudantes antes da publicação.
- O editor mantém a base Trix, com subtítulos e sublinhado acrescentados. Fotografias aprovadas podem ser vinculadas à notícia e exibidas com legenda; inserção livre de imagens em qualquer posição do texto e ferramentas de alinhamento não foram implementadas.
- Álbuns são agrupamentos por nome das fotografias publicadas; não existe CRUD de um objeto Album independente com categoria/data/capa próprias.
- Não foi implementada conversão AVIF, importação/recompressão em massa dos arquivos antigos, nem revogação individual por etiqueta.
- Exclusão de fotografias remove o anexo correspondente. Não há rotina automática de varredura de todos os arquivos órfãos antigos.
- As listas públicas de comentários mostram até 100 comentários aprovados por notícia. Usuários, eventos e ranking de curtidas têm limite de 100 entradas no painel; não ganharam paginação própria.
- Não houve implantação, teste de carga ou auditoria legal de LGPD. As proteções implementadas não substituem a revisão das autorizações de publicação pela escola.

## Resultado final das verificações

- `PARALLEL_WORKERS=1 bin/rails test`: **47 testes, 363 asserções, nenhuma falha/erro/skip**.
- Chrome headless (`bin/rails test:system`, com executáveis locais do Chrome/ChromeDriver): **3 testes, 26 asserções, nenhuma falha/erro/skip**.
- `bin/rails zeitwerk:check`: carregamento completo aprovado.
- RuboCop nos controladores, modelos, helpers, serviços, rotas, novas migrações e novos testes: **45 arquivos, nenhuma infração**.
- Brakeman: **nenhum alerta de segurança** no relatório final (`tmp/brakeman-interactive.json`). O processo exibiu mensagens de tentativa de carregamento de extensões opcionais do concurrent-ruby, mas terminou com código zero e relatório gerado.
- `bin/rails assets:precompile`: concluído. O manifesto antigo foi substituído pelos assets atuais. Se houver novas edições durante desenvolvimento, execute `bin/rails assets:clobber` para que Rails volte a servir as fontes atualizadas, conforme o aviso normal de pré-compilação em development.
- Capturas de tela: `tmp/screenshots/fect-mobile.png` e `tmp/screenshots/fect-desktop.png`.

Não foram realizados testes físicos de NFC/câmera/QR, nem deploy, teste de bucket externo ou medição de qualidade de fotografias reais do usuário.

## Arquivos de implementação alterados ou criados

- `.env.example`
- `Dockerfile`
- `app/assets/stylesheets/interactive.css`
- `app/controllers/admin/articles_controller.rb`
- `app/controllers/admin/base_controller.rb`
- `app/controllers/admin/categories_controller.rb`
- `app/controllers/admin/comments_controller.rb`
- `app/controllers/admin/dashboard_controller.rb`
- `app/controllers/admin/events_controller.rb`
- `app/controllers/admin/likes_controller.rb`
- `app/controllers/admin/photos_controller.rb`
- `app/controllers/admin/settings_controller.rb`
- `app/controllers/admin/users_controller.rb`
- `app/controllers/application_controller.rb`
- `app/controllers/articles_controller.rb`
- `app/controllers/covers_controller.rb`
- `app/controllers/event_images_controller.rb`
- `app/controllers/interactions_controller.rb`
- `app/controllers/logos_controller.rb`
- `app/controllers/pages_controller.rb`
- `app/controllers/photos_controller.rb`
- `app/controllers/qr_codes_controller.rb`
- `app/controllers/sitemaps_controller.rb`
- `app/helpers/application_helper.rb`
- `app/javascript/controllers/cover_preview_controller.js`
- `app/javascript/controllers/editorial_form_controller.js`
- `app/javascript/controllers/engagement_controller.js`
- `app/javascript/controllers/lightbox_controller.js`
- `app/javascript/controllers/navigation_controller.js`
- `app/javascript/controllers/photo_upload_controller.js`
- `app/javascript/controllers/theme_controller.js`
- `app/javascript/editor.js`
- `app/models/article.rb`
- `app/models/category.rb`
- `app/models/comment.rb`
- `app/models/concerns/editorial_environment.rb`
- `app/models/event.rb`
- `app/models/like.rb`
- `app/models/photo_submission.rb`
- `app/models/site_setting.rb`
- `app/models/user.rb`
- `app/services/editorial_image.rb`
- `app/services/photo_optimizer.rb`
- `app/views/admin/articles/_editor_toolbar.html.erb`
- `app/views/admin/articles/_fields.html.erb`
- `app/views/admin/articles/_form.html.erb`
- `app/views/admin/articles/index.html.erb`
- `app/views/admin/categories/index.html.erb`
- `app/views/admin/comments/index.html.erb`
- `app/views/admin/events/_form.html.erb`
- `app/views/admin/events/edit.html.erb`
- `app/views/admin/events/index.html.erb`
- `app/views/admin/events/new.html.erb`
- `app/views/admin/likes/index.html.erb`
- `app/views/admin/photos/index.html.erb`
- `app/views/admin/settings/index.html.erb`
- `app/views/admin/shared/_environment_filter.html.erb`
- `app/views/admin/shared/_nav.html.erb`
- `app/views/admin/shared/_sidebar.html.erb`
- `app/views/admin/users/index.html.erb`
- `app/views/articles/_card.html.erb`
- `app/views/articles/_content.html.erb`
- `app/views/articles/_engagement.html.erb`
- `app/views/articles/_image.html.erb`
- `app/views/articles/_list.html.erb`
- `app/views/articles/index.html.erb`
- `app/views/articles/show.html.erb`
- `app/views/layouts/application.html.erb`
- `app/views/pages/agenda.html.erb`
- `app/views/pages/fect.html.erb`
- `app/views/pages/home.html.erb`
- `app/views/photos/index.html.erb`
- `app/views/photos/new.html.erb`
- `app/views/shared/_footer.html.erb`
- `app/views/shared/_head.html.erb`
- `app/views/shared/_header.html.erb`
- `app/views/shared/_journal_logo.html.erb`
- `app/views/sitemaps/show.xml.builder`
- `config/initializers/content_security_policy.rb`
- `config/initializers/session_store.rb`
- `config/routes.rb`
- `config/storage.yml`
- `db/migrate/20261116090000_add_editorial_environments.rb`
- `db/migrate/20261116091000_add_editorial_categories.rb`
- `db/migrate/20261116092000_add_site_settings.rb`
- `db/migrate/20261116093000_associate_editorial_photos.rb`
- `db/migrate/20261116094000_add_photo_fingerprints_and_events.rb`
- `db/schema.rb`
- `docs/RELATORIO_INTERATIVIDADE.md`
- `public/robots.txt`
- `test/application_system_test_case.rb`
- `test/integration/interactive_system_test.rb`
- `test/system/interactions_test.rb`

Assets compilados de Tailwind e Propshaft foram regenerados para as novas telas e controladores.
