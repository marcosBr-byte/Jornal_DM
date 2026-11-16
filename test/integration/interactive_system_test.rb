require "test_helper"
require "vips"

class InteractiveSystemTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @admin = User.create!(email: "interactive-admin@example.test", password: "SecureEditorial123!", admin: true)
    @editor = User.create!(email: "fect-editor@example.test", password: "SecureEditorial123!", editor_environment: "fect")
    @dm = @admin.articles.create!(title: "Notícia Jornal DM", author: "Equipe", category: "Educação", body: "Conteúdo DM", status: :published)
    @fect = @admin.articles.create!(title: "Notícia FECT", author: "Equipe", category: "Educação", body: "Conteúdo FECT", environment: "fect", status: :published)
    ApplicationController::AUTH_RATE_LIMIT_STORE.clear
  end
  teardown { ApplicationController::AUTH_RATE_LIMIT_STORE.clear }

  test "public routes and search never mix environments" do
    get root_path
    assert_select "h3", text: @fect.title, count: 0
    get fect_path
    assert_response :success
    assert_select "h3", text: @fect.title
    assert_select "h3", text: @dm.title, count: 0
    get fect_articles_path, params: { q: "FECT" }
    assert_response :success
    assert_select "h3", text: @fect.title
    get article_path(@fect)
    assert_response :not_found
    get fect_article_path(@dm)
    assert_response :not_found
    get fect_article_path(@fect)
    assert_response :success
    assert_select "meta[property='og:site_name'][content='FECT']"
    assert_select "a[href=?]", fect_article_path(@fect), minimum: 0
  end

  test "signed cookie toggles one like and ignores submitted visitor identity" do
    2.times do |i|
      post "#{article_path(@dm)}/curtir", params: { visitor_digest: "forged" }, as: :json
      assert_response :success
      assert_equal i == 0, response.parsed_body["liked"]
      assert_equal i == 0 ? 1 : 0, @dm.likes.count
    end
    post "#{fect_article_path(@dm)}/curtir", as: :json
    assert_response :not_found
    assert_equal 0, @fect.likes.count
  end

  test "comments appear immediately after filtering and remain removable by authorized editors" do
    post "#{article_path(@dm)}/comentarios", params: { comment: { body: '<script>alert("XSS")</script> Você é um idiota. Manda nudes.', status: "pending" } }
    assert_response :redirect
    comment = @dm.comments.last
    assert comment.approved?
    assert_equal "Leitor anônimo", comment.display_name
    assert_not_includes comment.body, "idiota"
    assert_not_includes comment.body.downcase, "manda nudes"
    get article_path(@dm)
    assert_select "strong", text: "Leitor anônimo"
    assert_select "script", text: 'alert("XSS")', count: 0
    sign_in @editor
    patch admin_comment_path(comment), params: { comment: { status: "rejected" } }
    assert_response :not_found
    sign_out @editor
    post "#{article_path(@dm)}/comentarios/#{comment.id}/denunciar"
    assert_equal 1, comment.reload.reports_count
    post "#{article_path(@dm)}/comentarios/#{comment.id}/denunciar"
    assert_equal 1, comment.reload.reports_count
    sign_in @admin
    patch admin_comment_path(comment), params: { comment: { status: "rejected" } }
    assert_response :redirect
    assert comment.reload.rejected?
    sign_out @admin
    get article_path(@dm)
    assert_select "strong", text: "Leitor anônimo", count: 0
  end

  test "editors cannot read change or publish the other environment" do
    sign_in @editor
    get admin_root_path
    assert_response :success
    get edit_admin_article_path(@dm)
    assert_response :not_found
    assert_no_difference "Article.count" do
      post admin_articles_path, params: { article: { title: "Invasão", environment: "dm", body: "Texto", author: "Equipe", category: "Educação" }, intent: "publish" }
    end
    assert_response :not_found
    get admin_articles_path, params: { environment: "dm" }
    assert_response :success
    assert_not_includes response.body, @dm.title
    post admin_articles_path, params: { article: { title: "Publicação FECT", body: "Texto", author: "Equipe", category: "Educação" }, intent: "publish" }
    assert_response :redirect
    assert_equal "fect", Article.order(:id).last.environment
    patch admin_article_path(@fect), params: { article: { environment: "dm" } }
    assert_response :not_found
    assert_equal "fect", @fect.reload.environment
    get admin_users_path
    assert_response :forbidden
  end

  test "administrative pages preserve authenticated session and logout revokes it" do
    post user_session_path, params: { user: { email: @admin.email, password: "SecureEditorial123!" } }
    assert_response :redirect
    [ admin_root_path, admin_articles_path, admin_comments_path, admin_events_path, admin_photos_path, admin_categories_path, admin_likes_path, admin_users_path, admin_settings_path ].each do |path|
      get path
      assert_response :success, path
    end
    delete destroy_user_session_path
    get admin_comments_path
    assert_redirected_to new_user_session_path
  end

  test "photo submission validates optimizes protects moderates and publishes" do
    source = Vips::Image.black(1800, 1300).new_from_image([ 90, 130, 170 ])
    Tempfile.create([ "image", ".png" ]) do |file|
      source.pngsave(file.path)
      upload = Rack::Test::UploadedFile.new(file.path, "image/png")
      assert_difference "PhotoSubmission.count", 1 do
        post "/fect/enviar-fotos", params: { images: [ upload ], consent: "1" }
      end
      photo = PhotoSubmission.last
      assert photo.pending?
      assert_no_difference "PhotoSubmission.count" do
        post "/fect/enviar-fotos", params: { images: [ Rack::Test::UploadedFile.new(file.path, "image/png") ], consent: "1" }
      end
      assert_response :redirect
      assert_equal "fect", photo.environment
      assert_equal 1200, photo.width
      assert_operator photo.height, :<=, 1200
      assert_equal photo.image.byte_size, photo.optimized_bytes
      assert_equal "image/webp", photo.image.content_type
      assert_equal File.size(file.path), photo.original_bytes
      get "/fect/fotografias/#{photo.id}"
      assert_response :not_found
      sign_in @admin
      patch admin_photo_path(photo), params: { photo_submission: { article_id: @dm.id } }
      assert_response :redirect
      assert_nil photo.reload.article_id
      patch admin_photo_path(photo), params: { photo_submission: { status: "published" } }
      assert photo.reload.pending?
      patch admin_photo_path(photo), params: { photo_submission: { status: "approved", caption: "Uma descoberta", album: "FECT" } }
      assert photo.reload.approved?
      patch admin_photo_path(photo), params: { photo_submission: { status: "published" } }
      assert photo.reload.published?
      sign_out @admin
      get "/fect/fotografias/#{photo.id}"
      assert_response :success
      assert_equal "image/webp", response.media_type
      get "/fotografias/#{photo.id}"
      assert_response :not_found
      get "/fect/galeria"
      assert_response :success
      assert_select "figcaption", text: /Uma descoberta/
      photo.image.purge
    end
  end

  test "invalid photo and missing consent create no records or files" do
    Tempfile.create([ "fake", ".jpg" ]) do |file|
      file.write("not an image"); file.flush
      assert_no_difference [ "PhotoSubmission.count", "ActiveStorage::Blob.count" ] do
        post "/enviar-fotos", params: { images: [ Rack::Test::UploadedFile.new(file.path, "image/jpeg") ], consent: "1" }
      end
      assert_response :unprocessable_entity
      post "/enviar-fotos", params: { images: [ Rack::Test::UploadedFile.new(file.path, "image/jpeg") ] }
      assert_response :unprocessable_entity
    end
  end

  test "events remain in their environment and can be edited" do
    sign_in @editor
    post admin_events_path, params: { event: { title: "Experimentos", starts_at: 2.days.from_now, location: "Escola", environment: "fect" } }
    assert_response :redirect
    event = Event.last
    assert_equal "fect", event.environment
    get edit_admin_event_path(event)
    assert_response :success
    sign_out @editor
    get fect_agenda_path
    assert_response :success
    assert_select "h2", text: "Experimentos"
    get agenda_path
    assert_select "h2", text: "Experimentos", count: 0
  end

  test "settings can revoke uploads and editors cannot edit another setting" do
    setting = SiteSetting.create!(environment: "dm", uploads_enabled: false)
    get "/enviar-fotos"
    assert_response :service_unavailable
    sign_in @editor
    patch admin_setting_path(setting), params: { site_setting: { uploads_enabled: true } }
    assert_response :not_found
    assert_not setting.reload.uploads_enabled?
  end

  test "sitemap and QR code endpoints render" do
    get "/sitemap.xml"
    assert_response :success
    assert_includes response.body, fect_article_url(@fect)
    get "/fect/envio-qr"
    assert_response :success
    assert_equal "image/png", response.media_type
    assert response.body.b.start_with?("\x89PNG".b)
  end
  test "new covers are decoded optimized and display responsive variants" do
    sign_in @admin
    Tempfile.create([ "cover", ".png" ]) do |file|
      Vips::Image.black(1500, 1000).new_from_image([ 50, 90, 150 ]).pngsave(file.path)
      post admin_articles_path, params: { article: { title: "Capa otimizada", body: "Texto", author: "Redação", category: "Cultura", cover: Rack::Test::UploadedFile.new(file.path, "image/png") }, intent: "publish" }
      assert_response :redirect
      article = Article.order(:id).last
      assert_equal "image/webp", article.cover.content_type
      assert_equal File.size(file.path), article.cover.metadata["original_bytes"]
      get cover_article_path(article, size: 640)
      assert_response :success
      image = Vips::Image.new_from_buffer(response.body.b, "")
      assert_equal 640, image.width
      @fect.cover.attach(article.cover.blob)
      get cover_fect_article_path(@fect, size: 640)
      assert_response :success
      get cover_article_path(@fect)
      assert_response :not_found
      get fect_article_path(@fect)
      assert_response :success
      @fect.cover.detach
      article.cover.purge
    end
  end

  test "future publications are visible only to editors until scheduled time" do
    @dm.update!(published_at: 1.day.from_now)
    get article_path(@dm)
    assert_response :not_found
    get root_path
    assert_select "h3", text: @dm.title, count: 0
    sign_in @admin
    get edit_admin_article_path(@dm)
    assert_response :success
    travel 2.days do
      sign_out @admin
      get article_path(@dm)
      assert_response :success
    end
  end
  test "only general administrators create users and the final administrator is preserved" do
    sign_in @editor
    assert_no_difference "User.count" do
      post admin_users_path, params: { user: { email: "forbidden@example.test", password: "NewPassword123!", editor_environment: "dm", admin: true } }
    end
    assert_response :forbidden
    sign_out @editor
    sign_in @admin
    assert_difference "User.count", 1 do
      post admin_users_path, params: { user: { email: "new-editor@example.test", password: "NewPassword123!", editor_environment: "fect", admin: true } }
    end
    assert_response :redirect
    created = User.find_by!(email: "new-editor@example.test")
    assert_not created.admin?
    assert_equal [ "fect" ], created.allowed_environments
    User.where.not(id: @admin.id).update_all(admin: false)
    patch admin_user_path(@admin), params: { user: { admin: "0", editor_environment: "dm" } }
    assert_response :redirect
    assert @admin.reload.admin?
  end

  test "official logo is fixed and cannot be changed through settings" do
    sign_in @admin
    setting = SiteSetting.create!(environment: "dm")
    Tempfile.create([ "logo-check", ".png" ]) do |file|
      Vips::Image.black(500, 500).new_from_image([ 60, 20, 90 ]).pngsave(file.path)
      assert_no_difference "ActiveStorage::Blob.count" do
        patch admin_setting_path(setting), params: { site_setting: { logo: Rack::Test::UploadedFile.new(file.path, "image/png") } }
      end
      assert_response :redirect
      assert_not setting.reload.logo.attached?
      get admin_settings_path
      assert_select "input[type=file]", count: 0
      get root_path
      assert_select "header img[alt='Logo Jornal DM']"
      get "/logo"
      assert_response :success
      assert_equal "image/png", response.media_type
    end
  end
end
