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
        accept: "application/vnd.vtex.ds.v10+json",
        "content-type": "application/json",
      },
      data: JSON.stringify(datos),
      type: "POST",
      url: "/api/dataentities/CL/documents",
      success: function (data) {
        $("").text("Email inscripto con suceso!");
      },
      error: function (error) {
        $("").text(error);
      },
    });
  });
});
