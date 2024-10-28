class QrCodeGenerationJob < ApplicationJob
  queue_as :default

  def perform(thnk_product_id)
    thnk_product = ThnkProduct.find_by(id: thnk_product_id)
    return unless thnk_product

    thnk_product.generate_and_attach_qr_code
    thnk_product.save!
    Rails.logger.info "QR code generated and attached for ThnkProduct ID: #{thnk_product.id}"
    puts "QR code generated and attached for ThnkProduct ID: #{thnk_product.id}"
  end
end
