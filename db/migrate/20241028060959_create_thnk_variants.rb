class CreateThnkVariants < ActiveRecord::Migration[7.2]
  def change
    create_table :thnk_variants do |t|
      t.references :thnk_product, null: false, foreign_key: true, type: :uuid
      t.string :variant_sku
      t.decimal :variant_grams
      t.string :variant_inventory_tracker
      t.string :variant_inventory_policy
      t.string :variant_fulfillment_service
      t.decimal :variant_price
      t.decimal :variant_compare_at_price
      t.boolean :variant_requires_shipping
      t.boolean :variant_taxable
      t.string :variant_barcode
      t.string :image_src
      t.integer :image_position
      t.string :image_alt_text
      t.boolean :gift_card
      t.string :seo_title
      t.string :seo_description
      t.string :variant_image
      t.string :variant_weight_unit
      t.string :variant_tax_code
      t.decimal :cost_per_item
      t.boolean :included_us
      t.decimal :price_us
      t.decimal :compare_at_price_us
      t.boolean :included_international
      t.decimal :price_international
      t.decimal :compare_at_price_international
      t.string :product_collection

      t.timestamps
    end
  end
end
