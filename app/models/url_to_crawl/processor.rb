module UrlToCrawl::Processor
  extend ActiveSupport::Concern

  class_methods do

    def process!
      process_uncrawled!
      reprocess_errored!
      reprocess_done!
    end

    def process_uncrawled!
      UrlToCrawl.uncrawled.find_in_batches do |group|
        sleep(50)
        group.each do |url_to_crawl|
          url_to_crawl.process
        end
      end 
    end

    def reprocess_errored!
      UrlToCrawl.errored.find_in_batches do |group|
        sleep(50)
        group.each do |url_to_crawl|
          url_to_crawl.process
        end
      end 
    end

    def reprocess_done!
      UrlToCrawl.done.find_in_batches do |group|
        sleep(50)
        group.each do |url_to_crawl|
          url_to_crawl.process
        end
      end 
    end
  end

  def process
    response = crawl
    scrape(response)
    self.done!
  end

  private

    def crawl
      Rails.logger.info("crawling url #{url}...")
      response = proxycrawl_api.get(url)
      update!({
        response_status_code: response.status_code,
        response_original_status: response.original_status,
        response_pc_status: response.pc_status,
        last_crawled_at: Time.zone.now
      })
      self.crawled!
      response
    rescue => exception
      Rails.logger.info("error crawling url #{url}")
      update!({
        last_crawl_error_message: "CRAWL ERROR: #{exception.message}",
        last_crawl_error_backtrace: exception.backtrace,
        last_crawl_errored_at: Time.zone.now
      })
      self.errored!
      nil
    end

    def scrape(response)
      return unless crawled? 
      return unless response_success?(response)
      Rails.logger.info("scraping url #{url}...")
      html_doc(response).css('div[data-component-type="s-search-result"]').each do |item|
        product_path = item.at_css('h2 > a').attr('href')
        crawl_then_scrape_product_path(product_path)
      end
      self.scraped!
    end

    def response_success?(response)
      response.status_code == 200
    end

    def crawl_then_scrape_product_path(product_path)
      product_url = "https://amazon.com#{product_path}"
      Rails.logger.info("crawling product #{product_url}...")
      response = proxycrawl_api.get(product_url)
      scrape_product_response(product_url, response)
    rescue => exception
      Rails.logger.error("error crawling product #{product_url}")
      update!({
        last_crawl_error_message: "CRAWL PRODUCT (#{product_url}) ERROR: #{exception.message}",
        last_crawl_error_backtrace: exception.backtrace,
        last_crawl_errored_at: Time.zone.now
      })
      self.errored!
      nil
    end

    def scrape_product_response(product_url, response)
      product_id = product_id_from_url(response.url)
      Rails.logger.info("scraping product #{product_url}...")
      product_attrs = extract_product_info_from_response(response)
      upsert_amazon_product(
        product_id,
        product_attrs[:title],
        product_attrs[:price],
        product_attrs[:description],
        product_attrs[:image_url]
      )
    rescue => exception
      Rails.logger.error("error scraping product #{product_url}")
      update!({
        last_crawl_error_message: "SCRAPE PRODUCT (#{product_url}) ERROR: #{exception.message}",
        last_crawl_error_backtrace: exception.backtrace,
        last_crawl_errored_at: Time.zone.now
      })
      self.errored!
      nil
    end

    def extract_product_info_from_response(response)
      product_title = html_doc(response).at_css('h1').text.strip
      product_price = html_doc(response).at_css('.priceBlockBuyingPriceString').text.strip
      product_description = html_doc(response).at_css('#productOverview_feature_div').text.gsub(/\n+/, "\n").strip
      product_description = product_description.gsub(/function.*\}/m, '')&.strip
      product_image_url = html_doc(response).at_css('#main-image-container #landingImage').attr('src').strip
      {
        title: product_title,
        price: product_price,
        description: product_description,
        image_url: product_image_url
      }
    end

    def product_id_from_url(url)
      idx = url.rindex('/')
      url[0, idx]
    end

    def upsert_amazon_product(product_id, product_title, product_price, product_description, product_image_url)
      attrs = {
          url_to_crawl: self,
          url: product_id,
          title: product_title,
          price: product_price,
          description: product_description,
          image_url: product_image_url
        }
      if AmazonProduct.where(url: product_id).exists?
        Rails.logger.info("updating product #{product_id} on database")
        ap = AmazonProduct.where(url: product_id).take!
        ap.update!(attrs)
      else
        Rails.logger.info("creating product #{product_id} on database")
        AmazonProduct.create!(attrs)
      end
    end

    def html_doc(response)
      Nokogiri::HTML(response.body)
    end

    def proxycrawl_api
      require 'proxycrawl'
      @proxycrawl_api ||= ProxyCrawl::API.new(token: proxycrawl_token)
    end

    def proxycrawl_token
      Rails.application.credentials[:proxycrawl][:normal_token]
    end
end
