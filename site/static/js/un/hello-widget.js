// Stub widget proving the mount + config seam that future Un tools follow:
// find a [data-widget] element, import the shared config, gate any network
// use on apiBaseUrl, fall back to local-only.
import { config, isLocalOnly } from "/js/council-config.js";

const el = document.querySelector('[data-widget="hello"]');
if (el) {
  el.innerHTML = isLocalOnly()
    ? "table status: <strong>running local-only</strong> — no ship's log connected"
    : `table status: <strong>linked to ${config.apiBaseUrl}</strong>`;
}
