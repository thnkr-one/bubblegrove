module Thnk
  class ProductsController < ApplicationController
    before_action :set_product, only: [:show, :details]

    def index
      @query = params[:query]
      @products = ThnkProduct.includes(:thnk_variants).all.order(:title)
      if @query.present?
        @products = @products.where('title ILIKE ?', "%#{@query}%")
      end
      @products = @products.page(params[:page]).per(10)
      @categories = @products.pluck(:product_category).compact.uniq

    end

    # GET /products/:id
    def show
      # Optional: Redirect to index or handle as needed
      redirect_to thnk_products_path
    end

    def details
      variant = @product.thnk_variants.find_by(variant_sku: params[:variant_sku])
      respond_to do |format|
        format.html { render partial: 'product_details', locals: { product: @product, variant: variant } }
      end
    end

    def bulk_print
      @category = params[:category]
      @products = ThnkProduct.where(product_category: @category).includes(:thnk_variants)

      respond_to do |format|
        format.html # renders bulk_print.html.erb
        format.pdf do
          render pdf: "bulk_qrcodes_#{@category}",
                 layout: 'pdf.html', # Use a separate layout for PDFs
                 template: 'products/bulk_print.pdf.erb'
        end
      end
    end

    private

      def set_product
        @product = ThnkProduct.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        redirect_to thnk_products_path, alert: "Product not found."
      end
  end
end