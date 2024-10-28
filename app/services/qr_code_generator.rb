# app/services/qr_code_generator.rb

require 'rqrcode'
require 'mini_magick'

class QrCodeGenerator
  # Generates a QR code image with embedded data and optional customizations.
  #
  # @param data [String] The data to encode in the QR code (e.g., URL with UUID).
  # @param options [Hash] Optional settings like size, overlay text, etc.
  # @return [MiniMagick::Image] The generated QR code image.
  def self.generate(data, options = {})
    # Generate QR code data
    qrcode = RQRCode::QRCode.new(data, size: options[:size] || 4, level: :h)
    png = qrcode.as_png(
      size: options[:size_px] || 300,
      color: options[:qr_color] || "000000",
      file: nil,
      fill: options[:background_color] || "FFFFFF"
    )

    # Load QR code image with MiniMagick
    image = MiniMagick::Image.read(png.to_s)
    image.format "png"

    # Optional: Overlay logo
    if options[:logo_path] && File.exist?(options[:logo_path])
      logo = MiniMagick::Image.open(options[:logo_path])
      logo.resize "60x60" # Adjust size as needed

      # Calculate position to center the logo
      x = (image.width - logo.width) / 2
      y = (image.height - logo.height) / 2

      # Composite the logo onto the QR code
      image = image.composite(logo) do |c|
        c.compose "Over" # OverCompositeOp
        c.geometry "+#{x}+#{y}"
      end
    end

    # Optional: Overlay text (e.g., price)
    if options[:overlay_text].is_a?(String) && options[:overlay_text].present?
      # Create a label image for the text
      label = MiniMagick::Image.new("png", image.width, 50) do |f|
        f.background "transparent"
        f.size "#{image.width}x50"
        f.gravity "South"
        f.font Rails.root.join('app', 'assets', 'fonts', 'Arial.ttf').to_s # Ensure the font file exists
        f.pointsize options[:font_size] || 24
        f.fill options[:text_color] || "black"
        f.annotate "+0+10", options[:overlay_text]
      end

      # Merge the label onto the QR code
      image = image.composite(label) do |c|
        c.compose "Over"    # OverCompositeOp
        c.gravity "South"   # Position at the bottom center
      end
    end

    image
  rescue => e
    Rails.logger.error "QR Code Generation Failed: #{e.message}"
    raise e
  end
end
