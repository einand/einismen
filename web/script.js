(function () {
  var root = document.documentElement;
  var body = document.body;
  var key = "einismen-theme";
  var menus = Array.prototype.slice.call(document.querySelectorAll("[data-menu]"));
  var themeContainers = Array.prototype.slice.call(document.querySelectorAll("[data-theme-buttons]"));
  var brandMarks = Array.prototype.slice.call(document.querySelectorAll("[data-brand-mark]"));
  var brandTitles = Array.prototype.slice.call(document.querySelectorAll("[data-brand-title]"));
  var themedImages = Array.prototype.slice.call(document.querySelectorAll(".image-break img[src$='.svg']"));
  var buttons = [];
  var allowed = [];
  var storage = null;

  try {
    storage = window.localStorage;
  } catch (error) {
    storage = null;
  }

  function refreshThemeButtons(next) {
    buttons = Array.prototype.slice.call(document.querySelectorAll("[data-theme-button]"));
    buttons.forEach(function (button) {
      var active = button.getAttribute("data-theme-button") === next;
      button.setAttribute("aria-pressed", active ? "true" : "false");
    });
  }

  function applyTheme(theme) {
    var next = allowed.indexOf(theme) >= 0 ? theme : "sand";
    root.setAttribute("data-theme", next);
    if (body) {
      body.setAttribute("data-theme", next);
    }
    refreshThemeButtons(next);
  }

  function bindThemeButtons() {
    buttons = Array.prototype.slice.call(document.querySelectorAll("[data-theme-button]"));
    buttons.forEach(function (button) {
      button.addEventListener("click", function () {
        var theme = button.getAttribute("data-theme-button") || "sand";
        if (storage) {
          storage.setItem(key, theme);
        }
        applyTheme(theme);
      });
    });
  }

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

  function renderThemes(themes) {
    allowed = themes.map(function (theme) {
      return theme.id;
    });

    themeContainers.forEach(function (container) {
      container.innerHTML = "";
      themes.forEach(function (theme) {
        var button = document.createElement("button");
        button.className = "theme-button";
        button.type = "button";
        button.textContent = theme.label;
        button.setAttribute("data-theme-button", theme.id);
        button.setAttribute("aria-pressed", "false");
        container.appendChild(button);
      });
    });

    bindThemeButtons();
    var saved = storage ? storage.getItem(key) || "sand" : "sand";
    applyTheme(saved);
  }

  function renderBrand(brand) {
    brandMarks.forEach(function (node) {
      node.textContent = brand.mark;
    });
    brandTitles.forEach(function (node) {
      node.textContent = brand.title;
    });
  }

  function inlineThemedImages() {
    themedImages.forEach(function (image) {
      var src = image.getAttribute("src");
      if (!src) {
        return;
      }
      fetch(src)
        .then(function (response) {
          if (!response.ok) {
            throw new Error("svg fetch failed");
          }
          return response.text();
        })
        .then(function (svgText) {
          var wrapper = document.createElement("div");
          wrapper.innerHTML = svgText.trim();
          var svg = wrapper.querySelector("svg");
          if (!svg) {
            return;
          }
          svg.setAttribute("role", "img");
          svg.setAttribute("aria-label", image.getAttribute("alt") || "");
          image.replaceWith(svg);
        })
        .catch(function () {});
    });
  }

  inlineThemedImages();

  fetch("site.json?v=20260319-5")
      .then(function (response) {
        if (!response.ok) {
          throw new Error("site fetch failed");
        }
        return response.json();
      })
      .then(function (data) {
        if (data && data.brand) {
          renderBrand(data.brand);
        }
        if (data && Array.isArray(data.menu)) {
          renderMenus(data.menu);
        }
        if (data && Array.isArray(data.themes)) {
          renderThemes(data.themes);
          return;
        }
        allowed = ["sand"];
        applyTheme("sand");
      })
      .catch(function () {
        allowed = ["sand"];
        applyTheme("sand");
      });
})();
