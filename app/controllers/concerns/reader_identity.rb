module ReaderIdentity
  private
  def reader_digest
    token = cookies.encrypted[:reader_token]
    unless token.present?
      token = SecureRandom.hex(32)
      cookies.encrypted[:reader_token] = { value: token, expires: 1.year.from_now, httponly: true, same_site: :lax, secure: Rails.env.production? }
    end
    OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, token)
  end
end
