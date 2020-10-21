class CreateAmazonProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :amazon_products do |t|
      t.integer :url_to_crawl_id
      
      t.string :url, uniq: true
      t.string :title
      t.string :price
      t.text   :description
      t.text   :image_url

      t.timestamps
    end
  end
end
