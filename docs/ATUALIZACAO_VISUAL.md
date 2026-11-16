# Atualização editorial do Jornal DM e FECT

Implementada em 16/11/2026, conforme o novo pedido. Este documento substitui as orientações anteriores sobre moderação prévia, expiração por inatividade e troca de logo.

## Layout e navegação

- Jornal DM: Início, Últimas notícias e Agenda.
- FECT: Início FECT e Notícias FECT. A ligação entre os portais permanece no bloco editorial ao final da página, sem acrescentar opções ao menu principal.
- Layout editorial compartilhado: notícias recentes, filtros, editorias, mais lidas e destaques. FECT usa uma paleta discreta de azul e verde, mantendo o foco na cobertura do evento.
- Tecnologia, Ciência, Esportes, Educação, Cultura, Projetos, Entrevistas, Comunidade, Eventos e Avisos estão disponíveis no editor e nos filtros. Categorias existentes foram preservadas. Seções por editoria exibem conteúdo quando houver notícias publicadas correspondentes; não foram criadas notícias fictícias.
- Cards com capa, editoria, data, tempo estimado de leitura, autor e acesso à notícia; leitura com botão Voltar às notícias.
- Tema com fundos, bordas, separadores, campos e textos adaptados; transição de 320 ms e aplicação inicial da preferência antes do carregamento visual, respeitando movimento reduzido.

## Artes

- `app/assets/images/jornal_dm_logo.png`: recorte em PNG transparente preparado com a ferramenta de edição de imagens a partir da referência enviada pelo usuário. A arte tem alpha real e foi integrada ao cabeçalho, rodapé, página inicial e favicon. O arquivo de saída é uma versão editada da referência, não uma extração determinística dos pixels do JPG.
- `app/assets/images/uma_escola_card.png`: card transparente com o brasão da escola e a frase Uma escola. Mil histórias. A fonte reproduzível está em `script/generate_brand_card.rb`.
- Card e logo flutuam em lados opostos do bloco principal. A animação é desativada quando o dispositivo solicita movimento reduzido.
- A identidade agora é fixa no projeto. O campo de troca de logo foi removido do painel e o controlador de configurações não aceita mais esse arquivo. Anexos históricos foram preservados no banco/armazenamento.

## Giro e destaques

O Giro usa títulos reais das notícias publicadas no ambiente correspondente, em movimento da direita para a esquerda. Há controle de pausa, pausa ao interagir e suporte a movimento reduzido.

O carrossel contém somente notícias marcadas como destaque no painel. Com duas ou mais notícias, avança automaticamente a cada 5.000 ms. Permite anterior/próximo, escolha direta, pausa e teclado. Pausa durante foco, interação com o ponteiro ou aba oculta; não avança automaticamente com movimento reduzido. Uma única notícia é apresentada sem controles desnecessários.

## Leituras reais

A migration `20261116095000_add_readership_and_instant_comments.rb` adiciona `articles.reads_count` e `article_readings`. A identificação usa o cookie criptografado de leitor e um digest HMAC, sem exigir cadastro. Registra uma leitura por notícia, navegador identificado e dia; atualizar a página no mesmo dia não aumenta o contador. O registro e o incremento acontecem na mesma transação, com índice único para concorrência.

O incremento não altera `lock_version`, evitando conflitos artificiais com o editor. O ranking usa somente artigos públicos do ambiente atual, com contadores maiores que zero. Os números representam leituras registradas, não pessoas verificadas; cookies apagados e tráfego automatizado podem alterar essa aproximação. Não foram atribuídos números retroativos ou fictícios. O painel mostra a soma de leituras e o contador de cada publicação.

## Comentários e filtro

Comentários novos são publicados imediatamente, sem avaliação prévia. Nome e texto passam por `CommentLanguageFilter`; a lista de termos e expressões está em `config/comment_filter.yml`. Palavras inteiras são substituídas por `[termo removido]`, expressões configuradas por `[trecho removido]`. Há normalização de maiúsculas, acentos e algumas substituições comuns de letras/números. Texto HTML é removido e a saída continua escapada.

A apresentação dos comentários antigos também aplica o filtro, sem apagar o conteúdo histórico armazenado. Decisões anteriores de ocultação/rejeição não foram revertidas automaticamente. Permanecem denúncia, exclusão, ocultação pela equipe, limite de envio, honeypot e proteção CSRF.

**Limite do filtro:** trata regras explícitas, não interpreta todo contexto. Não garante identificar toda ofensa disfarçada ou duplo sentido; pode exigir ajuste pela equipe. Não utiliza serviço externo de IA nem transmite comentários a terceiros.

## Administração e sessão

A expiração por inatividade do Devise foi retirada. A sessão permanece enquanto o navegador mantiver seu cookie de sessão e até o uso de Sair. Fechar uma aba isolada não equivale necessariamente a fechar a sessão do navegador; navegadores com restauração de sessão podem preservar cookies entre reaberturas. Não foram colocadas senhas ou tokens de autenticação no localStorage.

O envio do formulário apresenta a indicação Verificando suas credenciais durante a requisição real. A confirmação Acesso verificado é exibida uma vez após autenticação bem-sucedida. Proteções de senha, tentativas repetidas, CSRF, HttpOnly, SameSite e Secure em produção continuam ativas. As permissões por ambiente permanecem verificadas no servidor.

## Verificação

- Suíte da aplicação: 51 testes, 413 asserções, nenhuma falha/erro/skip.
- Testes em Chrome headless: 4 testes, 41 asserções, nenhuma falha/erro/skip. A verificação cobre também o avanço real do carrossel após cinco segundos.
- Verificações incluem carrossel de cinco segundos, pausa/manual, editorias, tema, PNGs carregados, ausência de transbordamento móvel, leituras diárias, manutenção de lock_version, publicação/filtragem dos comentários, logo fixa e sessão após três horas de inatividade.
- Carregamento Zeitwerk e compilação de assets concluídos; 48 arquivos verificados pelo RuboCop sem infrações; Brakeman sem alertas. Os novos PNGs, CSS e controladores estão no manifesto compilado.
- Smoke test no servidor de desenvolvimento: navegação dos dois portais, tema, tela móvel, login, navegação autenticada, atualização de página e saída. Nenhum erro grave de JavaScript foi registrado.
- Não houve implantação no Render, configuração de serviços pagos ou criação de conteúdo editorial fictício. As exigências anteriores de armazenamento externo persistente para novos uploads em produção continuam válidas.

As capturas ficam em `tmp/screenshots/jornal-desktop-light.png`, `jornal-desktop-dark.png`, `jornal-mobile-dark.png` e `local-fect-dark.png`.
