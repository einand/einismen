(function () {
  var root = document.documentElement;
  var body = document.body;
  var key = "einismen-theme";
  var buttons = Array.prototype.slice.call(document.querySelectorAll("[data-theme-button]"));
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
    if (body) {
      body.setAttribute("data-theme", next);
    }
    buttons.forEach(function (button) {
      var active = button.getAttribute("data-theme-button") === next;
      button.setAttribute("aria-pressed", active ? "true" : "false");
    });
  }

  var saved = storage ? storage.getItem(key) || "sand" : "sand";
  applyTheme(saved);

  buttons.forEach(function (button) {
    button.addEventListener("click", function () {
      var theme = button.getAttribute("data-theme-button") || "sand";
      if (storage) {
        storage.setItem(key, theme);
      }
      applyTheme(theme);
    });
  });
})();
