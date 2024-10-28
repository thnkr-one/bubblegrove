module Thnk
  class VariantsController < ApplicationController
    # GET /variants/:uuid/details
    # GET /variants/:uuid/details
    def details
      @variant = ThnkVariant.find_by(uuid: params[:uuid])

      if @variant
        @product = @variant.thnk_product
        log_scan(@variant)
        render :details
      else
        redirect_to root_path, alert: "Variant not found."
      end
    end

    private

      def log_scan(variant)
        Scan.create!(
          thnk_variant: variant,
          ip_address: request.remote_ip,
          user_agent: request.user_agent
        )
      rescue => e
        Rails.logger.error "Failed to log scan for variant '#{variant.variant_sku}': #{e.message}"
      end
  end
end