# Ajustes de navegação, contraste e mensagens

Atualização de 16/11/2026, complementar a ATUALIZACAO_VISUAL.md.

- Troca entre Jornal DM e FECT no cabeçalho, inclusive no celular. Bloco de troca inferior e seções de editoria removidos; categorias e filtros de notícias preservados.
- Card da escola e logo continuam como PNGs com alpha real. A flutuação tem amplitude maior; respeita movimento reduzido.
- Bordas claras mais visíveis nos dois portais, formulários e painel. Indicadores e menus administrativos usam ícones SVG locais, sem nova dependência.
- Giro em ciclo infinito e sem pausa ao passar o mouse ou focar um link. O leitor mantém o botão de pausa e a preferência de movimento reduzido.
- Filtro de comentários automático ampliado para palavras ofensivas explícitas e algumas formas disfarçadas, com letras repetidas, números, separadores e caracteres invisíveis. Nomes e comentários antigos também são filtrados na apresentação. Não há avaliação prévia para novos comentários. O filtro é baseado em regras e não garante reconhecer toda ambiguidade ou disfarce possível; as denúncias continuam disponíveis. Termos comuns como Pinto, parte do nome da escola, não foram bloqueados isoladamente.
- Português brasileiro definido como idioma padrão. Traduções locais de autenticação, validação, datas, formatos numéricos, recuperação de senha, páginas de erro e mensagens de falta de permissão. Formulários também apresentam validação em português. Textos de depuração internos do Rails em desenvolvimento continuam sendo mensagens técnicas do framework.
- Sessão sem prazo de inatividade preservada: navegação e atualização não pedem novo login. Sair encerra a autenticação; o cookie de sessão acompanha o ciclo de vida do navegador. Não há logout por evento de fechamento de aba, que poderia interromper recargas e múltiplas abas. Nenhuma senha é guardada no JavaScript ou localStorage.

## Verificação

54 testes de aplicação, 450 asserções; 4 testes no navegador, 44 asserções. Nenhuma falha, erro ou teste ignorado. RuboCop: 32 arquivos sem infrações. Brakeman sem alertas. Zeitwerk e compilação de assets concluídos. Smoke test no servidor local confirmou navegação, tema, ausência de transbordamento móvel, login, sessão, saída e nenhum erro grave de JavaScript.

O servidor foi reiniciado em http://localhost:3000. Não foi feito deploy no Render nem alteração de serviços externos.
