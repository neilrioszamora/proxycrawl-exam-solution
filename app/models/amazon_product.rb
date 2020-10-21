class AmazonProduct < ApplicationRecord

  # Relationships -----------------------------------------------------
  belongs_to :url_to_crawl, optional: true
end
