class CreateUrlToCrawls < ActiveRecord::Migration[6.0]
  def change
    create_table :url_to_crawls do |t|
      t.string  :url, nil: false
      t.integer :status, nil: false, default: 0

      t.timestamps
    end
  end
end
