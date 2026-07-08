// Council Archive — the per-document honour warning for Taxe & Ali.
//
// SINGLE SOURCE OF TRUTH for the notice that rides atop every archived
// document. Each *.dc.html in this directory loads it once, right after
// support.js:
//
//     <script src="./archive-notice.js" defer></script>
//
// The banner's markup, copy, and styling all live here — change them in one
// place and every document updates. To REMOVE the banners from every document
// later (they are a "for now" measure), blank this file to a no-op; the docs
// keep their harmless <script> include and nothing renders.
(function () {
  "use strict";

  function mount() {
    if (document.getElementById("arc-doc-notice")) return;
    if (!document.body) return;

    var bar = document.createElement("aside");
    bar.id = "arc-doc-notice";
    bar.setAttribute("role", "note");
    bar.style.cssText = [
      "position:sticky",
      "top:0",
      "z-index:9999",
      "box-sizing:border-box",
      "width:100%",
      "margin:0",
      "background:#1b3140",
      "color:#f3ead1",
      "border-bottom:3px solid #a8823f",
      "font-family:'Courier Prime',ui-monospace,monospace",
      "font-size:13px",
      "line-height:1.6",
      "letter-spacing:.3px",
      "padding:12px 20px",
      "text-align:center"
    ].join(";");
    bar.innerHTML =
      '<strong style="color:#e9d9a8;letter-spacing:2px">ARCHIVE DOCUMENT</strong>' +
      ' — <b>Taxe &amp; Ali</b>: on your honour, read no further. This paper may hold' +
      ' details of the <i>Council of Un</i> campaign you are not yet privy to.';

    document.body.insertBefore(bar, document.body.firstChild);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", mount);
  } else {
    mount();
  }
})();
