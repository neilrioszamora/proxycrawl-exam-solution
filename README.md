# Neil R. Zamora's Proxy Crawl Test Solution

This app uses MySql database and 

- please check `$ EDITOR=nano rails credentials:edit`
- run the migration
- start the server

## Testing the API

### READ all

```
curl --header "Content-Type: application/json" \
  --request GET \
  http://localhost:3000/amazon_products
```

### READ specific product

```
curl --header "Content-Type: application/json" \
  --request GET \
  http://localhost:3000/amazon_products/:id
```

### CREATE

```
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"url":"my_url","title":"my_title"},"price":"my_price","description":"my_description","image_url":"my_image_url"' \
  http://localhost:3000/amazon_products
```

### UPDATE

```
curl --header "Content-Type: application/json" \
  --request PATCH \
  --data '{"url":"my_url","title":"my_title"},"price":"my_price","description":"my_description","image_url":"my_image_url"' \
  http://localhost:3000/amazon_products/:id
```

### DELETE

```
curl --header "Content-Type: application/json" \
  --request DELETE \
  http://localhost:3000/amazon_products/:id
```
