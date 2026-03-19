(function () {
  var root = document.documentElement;
  var key = "einismen-theme";
  var select = document.querySelector("[data-theme-select]");
  var allowed = ["sand", "paper", "stone", "night"];
  var storage = null;

  try {
    storage = window.localStorage;
  } catch (error) {
    storage = null;
  }

  function applyTheme(theme) {
    var next = allowed.indexOf(theme) >= 0 ? theme : "sand";
    root.setAttribute("data-theme", next);
    if (select) {
      select.value = next;
    }
  }

  var saved = storage ? storage.getItem(key) || "sand" : "sand";
  applyTheme(saved);

  if (select) {
    select.addEventListener("change", function (event) {
      var theme = event.target.value;
      if (storage) {
        storage.setItem(key, theme);
      }
      applyTheme(theme);
    });
  }
})();
