require "vips"
class EditorialImage
  SIZES = [ 240, 640, 1000, 1200 ].freeze
  def self.bytes(attachment, size)
    width = Integer(size, exception: false)
    return [ attachment.download, attachment.content_type ] unless SIZES.include?(width)
    if attachment.blob.service_name == "database"
      # Keep legacy originals intact without writing new binary variants to PostgreSQL.
      image = Vips::Image.thumbnail_buffer(attachment.download, width, height: width, size: :down)
      return [ image.webpsave_buffer(Q: 82, strip: true), "image/webp" ]
    end
    variant = attachment.variant(resize_to_limit: [ width, width ], format: :webp, saver: { quality: 82, strip: true }).processed
    [ variant.download, "image/webp" ]
  end
end
