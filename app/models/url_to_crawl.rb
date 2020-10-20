class UrlToCrawl < ApplicationRecord

  enum status: [ :not_crawled, :crawled ]

  # Validations -------------------------------------------------------
  validates :url, presence: true
  validates :status, inclusion: { in: statuses.keys }

end
