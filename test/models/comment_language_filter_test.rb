require "test_helper"
class CommentLanguageFilterTest < ActiveSupport::TestCase
  test "filters explicit language without matching harmless portions of words" do
    assert_equal "Tecnologia, esporte e cultura. Uma disputa incrível!", CommentLanguageFilter.call("Tecnologia, esporte e cultura. Uma disputa incrível!")
    assert_equal "[termo removido] e [termo removido]!", CommentLanguageFilter.call("IDIOTA e p0rra!")
    assert_equal "[trecho removido].", CommentLanguageFilter.call("Manda nudes.")
    assert_equal "Olá", CommentLanguageFilter.call("<img src=x onerror=alert(1)>Olá")
    assert_equal "[termo removido]", CommentLanguageFilter.call("p.o.r.r.a")
  end
end

class ExtendedCommentLanguageFilterTest < ActiveSupport::TestCase
  test "filters disguised offensive terms in names and comments automatically" do
    [ "b*u*r*r*o", "i d i o t a", "IDIOOOTA", "m3rda", "cuzão", "p\u200borra", "vtnc" ].each do |word|
      assert_equal "[termo removido]", CommentLanguageFilter.call(word), word
    end
    assert_equal "Escola Dom Marcelo Pinto de Carvalho: cultura, tecnologia e reciclagem do lixo.", CommentLanguageFilter.call("Escola Dom Marcelo Pinto de Carvalho: cultura, tecnologia e reciclagem do lixo.")
  end
end
