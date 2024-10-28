# app/controllers/scanner_controller.rb
class ScannerController < ApplicationController
  def lookup
    uuid = params[:uuid]
    @product = ThnkComProduct.find_by(id: uuid)

    if @product
      render json: {
        type: 'product',
        data: {
          handle: @product.handle,
          title: @product.title,
          image_src: @product.image_src,
          variant_image: @product.variant_image,
          body: @product.body,
          vendor: @product.vendor,
          product_category: @product.product_category,
          tags: @product.tags,
          published: @product.published,
          option_one_name: @product.option_one_name,
          variant_sku: @product.variant_sku,
          variant_price: @product.variant_price,
          variant_barcode: @product.variant_barcode
        }
      }
    else
      render json: { error: 'Product not found' }, status: :not_found
    end
  end
end
