(function () {
  var root = document.documentElement;
  var btn = document.getElementById("themeToggle");
  if (!btn) return;

  function syncButton(theme) {
    var isDark = theme === "dark";
    btn.setAttribute("aria-pressed", String(isDark));
    btn.setAttribute("aria-label", isDark ? "Switch to light theme" : "Switch to dark theme");
  }

  function apply(theme) {
    root.dataset.theme = theme;
    try { localStorage.setItem("council-theme", theme); } catch (e) {}
    syncButton(theme);
  }

  function toggle() {
    var next = root.dataset.theme === "dark" ? "light" : "dark";
    if (document.startViewTransition) {
      document.startViewTransition(function () { apply(next); });
    } else {
      apply(next);
    }
  }

  syncButton(root.dataset.theme || "light");
  btn.addEventListener("click", toggle);
})();
