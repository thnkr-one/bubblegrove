# app/models/thnk_variant.rb

class ThnkVariant < ApplicationRecord
  include Rails.application.routes.url_helpers
  belongs_to :thnk_product
  has_many_attached :images
  has_one_attached :qr_code_image

  before_create :assign_uuid
  after_create_commit :generate_and_attach_qr_code # Use after_create_commit

  private

    def assign_uuid
      self.uuid ||= SecureRandom.uuid
    end

    def generate_and_attach_qr_code
      # Ensure URL helpers are accessible


      # Construct the URL to encode
      data = variant_details_url(uuid: uuid, host: ENV['HOST'] || 'localhost:3000') # Replace 'localhost:3000' with your actual host

      # Generate QR code with overlay text (e.g., price)
      qr_image = QrCodeGenerator.generate(
        data,
        size: 4,
        size_px: 300,
        overlay_text: "$#{variant_price.to_f.round(2)}",
        font_size: 24,
        text_color: "black",
        logo_path: Rails.root.join('app', 'assets', 'images', 'logo.png').to_s # Ensure logo exists
      )

      # Attach the QR code image
      qr_code_image.attach(
        io: StringIO.new(qr_image.to_blob),
        filename: "qr_code_variant_#{variant_sku}.png",
        content_type: 'image/png'
      )
    rescue => e
      Rails.logger.error "Failed to generate/attach QR code for variant '#{variant_sku}': #{e.message}"
    end
end
