class UrlToCrawl < ApplicationRecord

  enum status: [ :uncrawled, :crawled, :scraped, :errored, :done]

  # Relationships -----------------------------------------------------
  has_many :amazon_products

  # Validations -------------------------------------------------------
  validates :url, presence: true
  validates :status, inclusion: { in: statuses.keys }

  include UrlToCrawl::Processor
end
