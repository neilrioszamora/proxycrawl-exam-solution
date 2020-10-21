class AddErrorColumnsToUrlToCrawls < ActiveRecord::Migration[6.0]
  def change
    add_column :url_to_crawls, :last_crawl_error_message, :text
    add_column :url_to_crawls, :last_crawl_error_backtrace, :text
    add_column :url_to_crawls, :last_crawl_errored_at, :datetime
  end
end
