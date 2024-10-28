# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


---

## Add to thnk_product migrations 

```ruby
    add_index :thnk_products, :handle, unique: true
    add_index :thnk_products, :variant_sku, unique: true
    add_index :thnk_products, :variant_barcode, unique: true
    add_index :thnk_products, :type
    add_index :thnk_products, :status
```

