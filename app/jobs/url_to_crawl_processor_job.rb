class UrlToCrawlProcessorJob < ApplicationJob
  queue_as :default

  def perform(*args)
    UrlToCrawl.process!
  end
end
