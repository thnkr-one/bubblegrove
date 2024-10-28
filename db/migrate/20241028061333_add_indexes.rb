class AddIndexes < ActiveRecord::Migration[7.2]
  def change
    add_index :thnk_variants, :variant_sku, unique: true

  end
end
