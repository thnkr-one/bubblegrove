class ThnkProduct < ApplicationRecord
  # Associations
  has_many :thnk_variants, dependent: :destroy
  has_many_attached :images
  has_one_attached :qr_code_image

  # Validations
  validates :uuid, presence: true, uniqueness: true
  validates :handle, presence: true, uniqueness: true
  validates :title, presence: true

  # Callback to set UUID before validation
  before_validation :set_uuid, on: :create

  # Callback to enqueue QR code generation
  after_commit :enqueue_qr_code_generation, on: :create

  # Method to generate QR code using QrCodeGenerator service
  def generate_and_attach_qr_code
    return if qr_code_image.attached?

    # The QR code will contain the UUID
    qr_content = self.uuid

    begin
      qr_image = QrCodeGenerator.generate(
        qr_content,
        size: 4,
        size_px: 300,
        overlay_text: "$#{variant_price.to_f.round(2)}", # Ensure variant_price is defined
        font_size: 24,
        text_color: "black",
        logo_path: Rails.root.join('app', 'assets', 'images', 'logo.png').to_s
      )

      qr_code_image.attach(
        io: StringIO.new(qr_image.to_blob),
        filename: "qr_code_#{handle}.png",
        content_type: 'image/png'
      )
    rescue => e
      Rails.logger.error "Failed to generate/attach QR code for product '#{handle}': #{e.message}"
    end
  end

  private

    def set_uuid
      self.uuid ||= SecureRandom.uuid
    end

    def enqueue_qr_code_generation
      QrCodeGenerationJob.perform_later(self.id)
    end
end
