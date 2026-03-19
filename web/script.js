(function () {
  var root = document.documentElement;
  var body = document.body;
  var key = "einismen-theme";
  var buttons = Array.prototype.slice.call(document.querySelectorAll("[data-theme-button]"));
  var menus = Array.prototype.slice.call(document.querySelectorAll("[data-menu]"));
  var allowed = ["sand", "paper", "stone", "night", "ash", "clay", "mist", "ember"];
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

  function renderMenus(items) {
    menus.forEach(function (menu) {
      var current = menu.getAttribute("data-current");
      menu.innerHTML = "";
      items.forEach(function (item) {
        var link = document.createElement("a");
        link.href = item.href;
        link.textContent = item.label;
        if (item.href === current) {
          link.className = "active";
        }
        menu.appendChild(link);
      });
    });
  }

  if (menus.length) {
    fetch("menu.json?v=20260319-2")
      .then(function (response) {
        if (!response.ok) {
          throw new Error("menu fetch failed");
        }
        return response.json();
      })
      .then(function (data) {
        if (data && Array.isArray(data.items)) {
          renderMenus(data.items);
        }
      })
      .catch(function () {});
  }
})();
