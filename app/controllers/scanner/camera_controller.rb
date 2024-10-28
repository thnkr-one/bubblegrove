# app/controllers/scanner/camera_controller.rb
class Scanner::CameraController < ApplicationController
  include ActionController::Live

  def index
    # This action renders the camera interface view
  end

  def scan
    uuid = validate_and_extract_uuid(params[:qr_data])
    return render_error('Invalid QR code format', :bad_request) unless uuid

    product = find_product(uuid)
    return render_error('Product not found', :not_found) unless product

    # Log the scan for analytics
    log_scan_event(product)

    render json: {
      success: true,
      product: product_response(product)
    }
  rescue => e
    Rails.logger.error("Scan error: #{e.message}")
    render_error('Scanner error occurred', :internal_server_error)
  end

  private

    def validate_and_extract_uuid(qr_data)
      # Verify UUID format
      uuid_regex = /\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i
      return qr_data if qr_data.match?(uuid_regex)
      nil
    end

    def find_product(uuid)
      ThnkComProduct.find_by(id: uuid)
    end

    def log_scan_event(product)
      Rails.logger.info(
        {
          event: 'product_scan',
          product_id: product.id,
          timestamp: Time.current,
          user_agent: request.user_agent,
          ip: request.remote_ip
        }.to_json
      )
    end

    def product_response(product)
      {
        id: product.id,
        title: product.title,
        description: product.body,
        images: {
          primary: product.image_src,
          variant: product.variant_image
        },
        variant: {
          sku: product.variant_sku,
          price: product.variant_price,
          inventory_policy: product.variant_inventory_policy,
          barcode: product.variant_barcode
        },
        metadata: {
          vendor: product.vendor,
          category: product.product_category,
          tags: product.tags,
          collection: product.product_collection
        }
      }
    end

    def render_error(message, status)
      render json: {
        success: false,
        error: message
      }, status: status
    end
end
