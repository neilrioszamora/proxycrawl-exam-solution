class UrlToCrawlsController < ApplicationController

  def index
    @url_to_crawl = UrlToCrawl.new
    @url_to_crawls = get_url_to_crawls
  end

  def create
    @url_to_crawl = UrlToCrawl.new(url_to_crawl_params)
    if @url_to_crawl.save
      redirect_to url_to_crawls_path
    else
      @url_to_crawls = get_url_to_crawls
      render 'index'
    end
  end

  private

    def url_to_crawl_params
      params.require(:url_to_crawl).permit(:url)
    end

    def get_url_to_crawls
      UrlToCrawl.order(created_at: :desc).all
    end
end
