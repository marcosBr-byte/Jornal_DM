require "test_helper"
class PortalRefinementTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @admin = User.create!(email: "refinement@example.test", password: "RefinementPassword123!", admin: true)
    ApplicationController::AUTH_RATE_LIMIT_STORE.clear
  end
  test "portal switches stay in the header and editorial blocks are removed" do
    get root_path
    assert_response :success
    assert_select "header nav a.news-nav-link[href=?]", fect_path, text: /FECT/
    assert_select ".editorial-section,.newsroom-bottom", count: 0
    assert_select ".brand-card", count: 0
    assert_select ".brand-logo img[src$='.png']"
    assert_select ".category-tab svg", count: Article.category_names("dm").size + 1
    assert_select "header .admin-person svg", count: 1
    assert_select ".masthead-brand strong", text: "Jornal DM"
    get fect_path
    assert_select "header nav a.news-nav-link[href=?]", root_path, text: /Jornal DM/
    assert_select ".editorial-section,.newsroom-bottom", count: 0
  end
  test "login success failure and validation messages are Portuguese" do
    post user_session_path, params: { user: { email: @admin.email, password: "incorrect-password" } }
    assert_response :unprocessable_entity
    assert_includes response.body, "Usuário ou senha inválidos"
    post user_session_path, params: { user: { email: @admin.email, password: "RefinementPassword123!" } }
    follow_redirect!
    assert_response :success
    assert_includes response.body, "Acesso realizado com sucesso."
    assert_select ".dashboard-metric-icon svg", count: 4
    assert_select "aside a[href=?]", admin_photos_path, count: 0
    assert_select "aside a[href=?]", admin_settings_path, count: 0
    assert_select "aside nav a svg", count: 8
    get admin_root_path
    assert_response :success
    post admin_articles_path, params: { article: { title: "", author: "", body: "", category: "Educação" } }
    assert_response :unprocessable_entity
    assert_includes response.body, "Título não pode ficar em branco"
    assert_not_includes response.body, "translation missing"
    assert_not_includes response.body, "can't be blank"
    delete destroy_user_session_path
    follow_redirect!
    assert_includes response.body, "Você saiu do sistema com segurança."
  end
end
