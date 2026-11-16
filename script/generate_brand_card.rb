require "vips"
require "base64"
crest = Base64.strict_encode64(File.binread("app/assets/images/logo_escola.jpeg"))
svg = <<~SVG
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="420" height="500" viewBox="0 0 420 500">
<defs><linearGradient id="paper" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#18394f"/><stop offset="1" stop-color="#326982"/></linearGradient><clipPath id="clip"><rect x="35" y="25" width="350" height="440" rx="15"/></clipPath></defs>
<rect x="35" y="25" width="350" height="440" rx="15" fill="url(#paper)"/>
<g clip-path="url(#clip)" fill="none" stroke="#ffffff" stroke-opacity=".10"><circle cx="370" cy="220" r="140"/><circle cx="370" cy="220" r="175"/><circle cx="370" cy="220" r="210"/></g>
<text x="65" y="64" fill="#ffffff" font-family="sans-serif" font-size="12" font-weight="bold" letter-spacing="3">JORNAL DM</text><circle cx="315" cy="59" r="4" fill="#a7d8c8"/><text x="328" y="63" fill="#d2e7e9" font-family="sans-serif" font-size="8">ESCOLA</text>
<rect x="144" y="108" width="132" height="132" rx="18" fill="#f4f5f2"/><image x="152" y="116" width="116" height="116" xlink:href="data:image/jpeg;base64,#{crest}"/>
<text x="65" y="315" fill="#ffffff" font-family="sans-serif" font-size="35" font-weight="bold">Uma escola.</text><text x="65" y="359" fill="#ffffff" font-family="sans-serif" font-size="35" font-weight="bold">Mil histórias.</text><line x1="65" y1="389" x2="118" y2="389" stroke="#a4d0d9" stroke-width="3"/><text x="65" y="424" fill="#c5e1e9" font-family="sans-serif" font-size="9" letter-spacing="2">DESDE AQUI, PARA TODOS.</text></svg>
SVG
Vips::Image.svgload_buffer(svg).pngsave("app/assets/images/uma_escola_card.png")
