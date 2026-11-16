require "vips"
class PhotoOptimizer
  class InvalidImage < StandardError; end
  def self.call(upload)
    raise InvalidImage, "Selecione JPEG, PNG ou WebP de até 10 MB." unless upload.respond_to?(:tempfile) && upload.size.between?(1, 10.megabytes)
    mime = Marcel::MimeType.for(upload.tempfile, name: upload.original_filename)
    raise InvalidImage, "Formato de imagem não permitido." unless mime.in?(Article::COVER_CONTENT_TYPES)
    source = upload.tempfile.path
    # Read dimensions before decoding pixels to reject decompression bombs.
    header = Vips::Image.new_from_file(source, access: :sequential)
    raise InvalidImage, "A imagem deve ter até 40 megapixels e 16000 px por lado." if header.width * header.height > 40_000_000 || [ header.width, header.height ].max > 16000
    image = Vips::Image.thumbnail(source, 1200, height: 1200, size: :down)
    buffer = image.webpsave_buffer(Q: 82, strip: true)
    { fingerprint: Digest::SHA256.hexdigest(buffer), bytes: buffer, original_bytes: upload.size, optimized_bytes: buffer.bytesize, width: image.width, height: image.height }
  rescue Vips::Error
    raise InvalidImage, "Não foi possível decodificar esta imagem. Selecione um arquivo válido."
  end
end
