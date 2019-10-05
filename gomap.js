// When locator icon in datatable is clicked, go to that spot on the map
$(document).on("click", ".go-map", function(e) {
  e.preventDefault();
  $el = $(this);
  var lat = $el.data("Lattitude");
  var lng = $el.data("longitude");
  var address = $el.data("address");
  $($("#nav a")[0]).tab("show");
  Shiny.onInputChange("goto", {
    lat: long,
    lng: long,
    address:String
  });
});