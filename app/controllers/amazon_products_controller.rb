class AmazonProductsController < ActionController::API

  def index
    @amazon_products = AmazonProduct.all
    render json: @amazon_products.to_json( :except => [:url_to_crawl_id] )
  end

  def create
    @amazon_product = AmazonProduct.create!(amazon_product_params)
    render json: @amazon_product.to_json( :except => [:url_to_crawl_id] ), status: 201
  end

  def show
    @amazon_product = AmazonProduct.find(params[:id])
    render json: @amazon_product.to_json( :except => [:url_to_crawl_id] )
  end

  def update
    @amazon_product = AmazonProduct.find(params[:id])
    @amazon_product.update!(amazon_product_params)
    render json: @amazon_product.to_json( :except => [:url_to_crawl_id] ), status: 202
  end

  def destroy
    @amazon_product = AmazonProduct.find(params[:id])
    @amazon_product.destroy
  end

  private

    def amazon_product_params
      params.require(:amazon_product).permit(:url, :title, :price, :description, :image_url)
    end
end
