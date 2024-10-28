# lib/tasks/seed_thnk_products.rake

namespace :db do
  desc 'Seeds thnk_products and thnk_variants tables from CSV file, generates QR codes'

  task seed_thnk_products: :environment do
    require 'csv'
    require 'open-uri'
    require 'securerandom'

    # Path to your CSV file
    csv_file_path = Rails.root.join('db', 'data', 'products_export_1.csv')

    unless File.exist?(csv_file_path)
      puts "CSV file not found at #{csv_file_path}. Please ensure the file exists."
      exit
    end

    # Counter for tracking progress
    row_count = 0

    # Start timing the import process
    start_time = Time.now
    puts "Starting CSV import at #{start_time.strftime('%Y-%m-%d %H:%M:%S')}"

    # Helper methods to parse data
    def parse_boolean(value)
      return false if value.nil?
      value.to_s.strip.downcase == 'true'
    end

    def parse_decimal(value)
      return nil if value.blank?
      BigDecimal(value)
    rescue ArgumentError
      nil
    end

    def parse_integer(value)
      return nil if value.blank?
      value.to_i
    rescue ArgumentError
      nil
    end

    # Read the CSV and process each row
    CSV.foreach(csv_file_path, headers: true) do |row|
      row_count += 1
      puts "Processing row #{row_count}" if row_count % 100 == 0

      handle = row['Handle'].to_s.strip.presence || "default-handle-#{SecureRandom.hex(4)}"

      # Find or initialize the ThnkProduct
      thnk_product = ThnkProduct.find_or_initialize_by(handle: handle)

      # If it's a new product, assign attributes
      if thnk_product.new_record?
        thnk_product.uuid ||= SecureRandom.uuid
        thnk_product.title = row['Title'].to_s.strip.presence
        thnk_product.body = row['Body (HTML)'].to_s.strip.presence
        thnk_product.vendor = row['Vendor'].to_s.strip.presence
        thnk_product.product_category = row['Product Category'].to_s.strip.presence
        thnk_product.product_type = row['Type'].to_s.strip.presence
        thnk_product.tags = row['Tags'].to_s.strip.presence
        thnk_product.published = parse_boolean(row['Published'])
        thnk_product.status = row['Status'].to_s.strip.presence || 'draft'

        if thnk_product.save
          puts "Created new product: #{thnk_product.handle}"
        else
          Rails.logger.error("Failed to create product with handle '#{handle}': #{thnk_product.errors.full_messages.join(', ')}")
          next
        end
      end

      # Extract variant_sku and ensure it's present
      variant_sku = row['Variant SKU'].to_s.strip.upcase.presence
      if variant_sku.blank?
        Rails.logger.warn("Row #{row_count}: Variant SKU is missing. Skipping variant.")
        next
      end

      # Check if the variant already exists
      thnk_variant = ThnkVariant.find_by(variant_sku: variant_sku)
      if thnk_variant
        puts "Row #{row_count}: Variant SKU '#{variant_sku}' already exists. Skipping creation."
      else
        # Create a new ThnkVariant associated with the ThnkProduct
        thnk_variant = ThnkVariant.new(
          thnk_product: thnk_product,
          variant_sku: variant_sku,
          variant_grams: parse_decimal(row['Variant Grams']),
          variant_inventory_tracker: row['Variant Inventory Tracker'].to_s.strip.presence,
          variant_inventory_policy: row['Variant Inventory Policy'].to_s.strip.presence || 'deny',
          variant_fulfillment_service: row['Variant Fulfillment Service'].to_s.strip.presence,
          variant_price: parse_decimal(row['Variant Price']),
          variant_compare_at_price: parse_decimal(row['Variant Compare At Price']),
          variant_requires_shipping: parse_boolean(row['Variant Requires Shipping']),
          variant_taxable: parse_boolean(row['Variant Taxable']),
          variant_barcode: row['Variant Barcode'].to_s.strip.presence,
          image_src: row['Image Src'].to_s.strip.presence,
          image_position: parse_integer(row['Image Position']),
          image_alt_text: row['Image Alt Text'].to_s.strip.presence,
          gift_card: parse_boolean(row['Gift Card']),
          seo_title: row['SEO Title'].to_s.strip.presence,
          seo_description: row['SEO Description'].to_s.strip.presence,
          variant_image: row['Variant Image'].to_s.strip.presence,
          variant_weight_unit: row['Variant Weight Unit'].to_s.strip.presence,
          variant_tax_code: row['Variant Tax Code'].to_s.strip.presence,
          cost_per_item: parse_decimal(row['Cost per item']),
          included_us: parse_boolean(row['Included / United States']),
          price_us: parse_decimal(row['Price / United States']),
          compare_at_price_us: parse_decimal(row['Compare At Price / United States']),
          included_international: parse_boolean(row['Included / International']),
          price_international: parse_decimal(row['Price / International']),
          compare_at_price_international: parse_decimal(row['Compare At Price / International']),
          product_collection: row['Product Collection'].to_s.strip.presence
        )

        if thnk_variant.save
          puts "Created new variant SKU: #{thnk_variant.variant_sku}"

          # Generate and attach QR code
          begin
            # Fetch the product's price for annotation
            # Assuming 'variant_price' holds the current price
            price = thnk_variant.variant_price.to_f

            # Generate QR code image with price annotation
            qr_image = QrCodeGenerator.generate(thnk_product.uuid, price)

            # Attach the QR code image to the product
            thnk_product.qr_code_image.attach(
              io: StringIO.new(qr_image.to_blob),
              filename: "qr_code_#{thnk_product.handle}.png",
              content_type: 'image/png'
            )

            puts "Attached QR code to product: #{thnk_product.handle}"
          rescue => e
            Rails.logger.error("Failed to generate/attach QR code for product '#{thnk_product.handle}': #{e.message}")
          end
        else
          Rails.logger.error("Failed to create variant SKU '#{variant_sku}': #{thnk_variant.errors.full_messages.join(', ')}")
          next
        end
      end

      # Handle image attachments if present for variants
      image_urls = []
      image_urls << thnk_variant.image_src if thnk_variant.image_src.present?
      image_urls << thnk_variant.variant_image if thnk_variant.variant_image.present?

      image_urls.each do |image_url|
        begin
          # Enqueue the ImageAttachmentJob
          ImageAttachmentJob.perform_later('ThnkVariant', thnk_variant.id, image_url)
          puts "Enqueued ImageAttachmentJob for variant SKU: #{thnk_variant.variant_sku}, Image URL: #{image_url}"
        rescue => e
          Rails.logger.error("Failed to enqueue ImageAttachmentJob for SKU '#{thnk_variant.variant_sku}': #{e.message}")
        end
      end
    end

    end_time = Time.now
    duration = end_time - start_time
    puts "Seeding thnk_products and thnk_variants complete at #{end_time.strftime('%Y-%m-%d %H:%M:%S')} (Duration: #{duration.round(2)} seconds)"
  end
end
