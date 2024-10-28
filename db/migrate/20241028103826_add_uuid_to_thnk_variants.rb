class AddUuidToThnkVariants < ActiveRecord::Migration[7.2]
  def change
    add_column :thnk_variants, :uuid, :uuid
  end
end
