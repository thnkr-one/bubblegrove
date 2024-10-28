class CreateThnkProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :thnk_products, id: :uuid do |t|
      t.uuid :uuid, default: 'gen_random_uuid()', null: false
      t.string :handle
      t.string :title
      t.text :body
      t.string :vendor
      t.string :product_category
      t.string :product_type
      t.string :tags
      t.boolean :published, default: false
      t.string :status, default: 'draft', null: false
      t.string :qr_code

      t.timestamps
    end
    add_index :thnk_products, :handle, unique: true
    add_index :thnk_products, :uuid, unique: true

  end
end
