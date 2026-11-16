class CommentLanguageFilter
  RULES = YAML.safe_load_file(Rails.root.join("config/comment_filter.yml")).freeze
  LEET = { "0" => "o", "1" => "i", "3" => "e", "4" => "a", "5" => "s", "7" => "t", "@" => "a", "$" => "s" }.freeze
  def self.normalize(value)
    I18n.transliterate(value, locale: :en).downcase.gsub(/[013457@$]/, LEET)
  end
  WORDS = RULES.fetch("words").map { |word| normalize(word).gsub(/[^a-z]/, "") }.freeze
  COLLAPSED_WORDS = WORDS.map { |word| word.squeeze }.freeze
  SPELLED = Regexp.union(WORDS.select { |word| word.size >= 4 }.map do |word|
    Regexp.new("(?<![[:alnum:]])" + word.chars.map { |letter| Regexp.escape(letter) }.join("[\\s._*\\-]+") + "(?![[:alnum:]])", Regexp::IGNORECASE)
  end)
  def self.call(value)
    text = ActionController::Base.helpers.strip_tags(value.to_s).gsub(/[\u200b-\u200d\u2060\ufeff]/, "")
    RULES.fetch("phrases").each do |phrase|
      expression = Regexp.new("(?<![[:alnum:]])" + phrase.split.map { |word| Regexp.escape(word) }.join("\\s+") + "(?![[:alnum:]])", Regexp::IGNORECASE)
      text = text.gsub(expression, "[trecho removido]")
    end
    text = text.gsub(SPELLED, "[termo removido]")
    text.gsub(/[[:alnum:]@$]+(?:[._*'-][[:alnum:]@$]+)*/) do |word|
      compact = normalize(word).gsub(/[^a-z]/, "")
      WORDS.include?(compact) || COLLAPSED_WORDS.include?(compact.squeeze) ? "[termo removido]" : word
    end.strip
  end
end
