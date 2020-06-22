vtexjs.checkout.getOrderForm().done(function (orderForm) {
  var item = {
    id: skuJson_0.skus[0].sku,
    quantity: 1,
    seller: "1",
  };
  vtexjs.checkout.addToCart([item]).done(function (orderForm) {
    alert("Item adicionado!");
    console.log(orderForm);
  });
});
