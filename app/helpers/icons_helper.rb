module IconsHelper
  CATEGORY_ICONS = { "Educação" => :book, "Tecnologia" => :chip, "Ciência" => :science, "Eventos" => :calendar, "Esportes" => :ball, "Cultura" => :palette, "Projetos" => :projects, "Entrevistas" => :microphone, "Comunidade" => :users, "Avisos" => :bell }.freeze
  def category_icon(category)
    ui_icon(CATEGORY_ICONS.fetch(category, :categories))
  end
  ICONS = {
    person: '<circle cx="12" cy="8" r="4"/><path d="M4 21v-2a7 7 0 0 1 16 0v2"/>',
    book: '<path d="M12 5v16M12 5C8 2 4 3 2 4v15c4-2 7-1 10 2 3-3 6-4 10-2V4c-2-1-6-2-10 1Z"/>',
    chip: '<rect x="6" y="6" width="12" height="12" rx="2"/><rect x="9" y="9" width="6" height="6"/><path d="M9 2v4M15 2v4M9 18v4M15 18v4M2 9h4M2 15h4M18 9h4M18 15h4"/>',
    science: '<path d="M9 3h6M10 3v6l-6 10a1.5 1.5 0 0 0 1 2h14a1.5 1.5 0 0 0 1-2L14 9V3M7 15h10"/><circle cx="12" cy="17" r=".5"/>',
    ball: '<circle cx="12" cy="12" r="9"/><path d="m12 7 5 4-2 6H9l-2-6ZM12 7V3M17 11l4-2M15 17l2 3M9 17l-2 3M7 11 3 9"/>',
    palette: '<path d="M12 3a9 9 0 1 0 0 18h1a2 2 0 0 0 1-4 2 2 0 0 1 1-4h3a3 3 0 0 0 3-3c0-4-4-7-9-7Z"/><circle cx="7" cy="10" r="1"/><circle cx="10" cy="7" r="1"/><circle cx="15" cy="7" r="1"/>',
    projects: '<path d="M9 18h6M10 21h4M8 14a6 6 0 1 1 8 0l-1 4H9Z"/>',
    microphone: '<rect x="9" y="2" width="6" height="12" rx="3"/><path d="M5 10a7 7 0 0 0 14 0M12 17v5M8 22h8"/>',
    bell: '<path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9ZM10 21h4"/>',
    dashboard: '<rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/>',
    plus: '<path d="M12 5v14M5 12h14"/>',
    news: '<rect x="4" y="3" width="16" height="18" rx="2"/><path d="M8 7h8M8 11h8M8 15h3M8 18h8"/>',
    star: '<path d="m12 3 2.8 5.8 6.4.9-4.6 4.5 1.1 6.4-5.7-3-5.7 3 1.1-6.4L2.8 9.7l6.4-.9Z"/>',
    categories: '<path d="m3 3 7 0 11 11-7 7L3 10Z"/><circle cx="7" cy="7" r="1"/>',
    eye: '<path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z"/><circle cx="12" cy="12" r="3"/>',
    heart: '<path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1.1-1.1a5.5 5.5 0 0 0-7.8 7.8L12 21l8.8-8.6a5.5 5.5 0 0 0 0-7.8Z"/>',
    comments: '<path d="M21 11.5a8.4 8.4 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.4 8.4 0 0 1-3.8-.9L3 21l1.9-5.7a8.4 8.4 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.4 8.4 0 0 1 3.8-.9h.5a8.5 8.5 0 0 1 8 8v.5Z"/>',
    calendar: '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M16 3v4M8 3v4M3 11h18"/>',
    camera: '<path d="M14.5 4h-5L7 7H3v13h18V7h-4Z"/><circle cx="12" cy="13" r="4"/>',
    users: '<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2M22 21v-2a4 4 0 0 0-3-3.9"/><circle cx="9" cy="7" r="4"/><path d="M16 3.1a4 4 0 0 1 0 7.8"/>',
    settings: '<circle cx="12" cy="12" r="3"/><path d="m10 2-.7 3-2 .9-2.7-1.1-2 3.4L5 10v3L2.6 15l2 3.4L7.3 17l2 .9.7 3h4l.7-3 2-.9 2.7 1.4 2-3.4L19 13v-3l2.4-1.8-2-3.4-2.7 1.1-2-.9L14 2Z"/>'
  }.freeze
  def ui_icon(name)
    tag.svg(ICONS.fetch(name.to_sym, ICONS[:news]).html_safe, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", "stroke-width": 1.7, "stroke-linecap": "round", "stroke-linejoin": "round", class: "ui-icon", aria: { hidden: true }, focusable: false)
  end
end
