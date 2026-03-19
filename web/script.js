(function () {
  var root = document.documentElement;
  var key = "einismen-theme";
  var select = document.querySelector("[data-theme-select]");
  var allowed = ["sand", "paper", "stone", "night"];

  function applyTheme(theme) {
    var next = allowed.indexOf(theme) >= 0 ? theme : "sand";
    root.setAttribute("data-theme", next);
    if (select) {
      select.value = next;
    }
  }

  var saved = localStorage.getItem(key) || "sand";
  applyTheme(saved);

  if (select) {
    select.addEventListener("change", function (event) {
      var theme = event.target.value;
      localStorage.setItem(key, theme);
      applyTheme(theme);
    });
  }
})();
