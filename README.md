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

fly secrets set AWS_ACCESS_KEY_ID=tid_vMxdrwtnR_ugUHImSKrEQjYlGLRmeqoQdbvS_bAkmUdjSzWIPm
fly secrets set AWS_ENDPOINT_URL_S3=https://fly.storage.tigris.dev
fly secrets set AWS_REGION=auto
fly secrets set AWS_SECRET_ACCESS_KEY=tsec_6znL+6gmiPL2lwwgSyuzLHNGMU3CjDKf6crnnRL_qf4ejXDMhZb87PqKo4H-7yYbIBTMMv
fly secrets set BUCKET_NAME=bubblegrove
fly secrets set DATABASE_URL=postgres://bubblegrove:ZHiL3zpeXP3ADOu@bubblescan-db.flycast:5432/bubblegrove?sslmode=disable
fly secrets set DATABASE_USERNAME=postgres
fly secrets set DATABASE_PASSWORD=xI6UMY2T4zEa5HN
fly secrets set DATABASE_HOSTNAME=bubblescan-db.internal
fly secrets set Flycast=fdaa:a:1d97:0:1::28
fly secrets set DATABASE_PROXY_PORT=5432
fly secrets set DATABASE_POSTGRES_PORT=5433
fly secrets set DATABASE_CONNECTION_STRING=postgres://postgres:xI6UMY2T4zEa5HN@bubblescan-db.flycast:5432