$(function () {
  $(".btn-buscar").val("");
  $(".ui-autocomplete").appendTo(".busca");

  $(".box-1 form button").click(function (elem) {
    elem.preventDefault();

    let datos = {};
    datos.isNewsletterOptIn = true;
    datos.email = $(".box-1 form input").val();

    $.ajax({
      headers: {
        Accept: "application/json; charset=utf-8",
        "Content-Type": "application/json; charset=utf-8",
      },
      data: JSON.stringify(datos),
      type: "PATCH",
      url: "//api.vtexcrm.com.br/tiendatest1/dataentities/CL/documents",
      success: function (data) {
        $("").text("Email inscripto con suceso!");
      },
      error: function (error) {
        $("").text(error);
      },
    });
  });
});
