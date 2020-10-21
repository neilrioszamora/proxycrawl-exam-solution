class AddResponseColumnsToUrlToCrawls < ActiveRecord::Migration[6.0]
  def change
    add_column :url_to_crawls, :response_status_code, :string
    add_column :url_to_crawls, :response_original_status, :string
    add_column :url_to_crawls, :response_pc_status, :string
    add_column :url_to_crawls, :last_crawled_at, :datetime
  end
end
