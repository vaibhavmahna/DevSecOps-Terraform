const $ = (sel, root = document) => root.querySelector(sel);
const $$ = (sel, root = document) => [...root.querySelectorAll(sel)];

// --- helpers -------------------------------------------------------------------

async function api(path, body) {
  const res = await fetch(path, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    const detail = Array.isArray(data.detail) ? data.detail.map((d) => d.msg).join("; ") : data.detail;
    throw new Error(detail || `Request failed (${res.status})`);
  }
  return data;
}

function debounce(fn, ms = 250) {
  let t;
  return (...args) => { clearTimeout(t); t = setTimeout(() => fn(...args), ms); };
}

function el(tag, attrs = {}, ...children) {
  const node = document.createElement(tag);
  for (const [k, v] of Object.entries(attrs)) {
    if (k === "class") node.className = v;
    else node.setAttribute(k, v);
  }
  for (const c of children) node.append(c);
  return node;
}

function showError(id, err) {
  const box = $(id);
  box.textContent = err ? err.message : "";
  box.hidden = !err;
}

let toastTimer;
function toast(msg) {
  const t = $("#toast");
  t.textContent = msg;
  t.hidden = false;
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => (t.hidden = true), 1600);
}

// Every Copy button copies the .value next to it.
document.addEventListener("click", async (e) => {
  const btn = e.target.closest(".copy");
  if (!btn) return;
  const value = btn.parentElement.querySelector(".value");
  const text = value.textContent;
  if (!text) return;
  try {
    await navigator.clipboard.writeText(text);
    toast("Copied to clipboard");
  } catch {
    const range = document.createRange();
    range.selectNodeContents(value);
    getSelection().removeAllRanges();
    getSelection().addRange(range);
    toast("Press Ctrl+C to copy");
  }
});

// --- navigation ----------------------------------------------------------------

function openTab(name) {
  if (!document.getElementById(name)) name = "password";
  $$(".tool").forEach((b) => b.classList.toggle("active", b.dataset.tab === name));
  $$(".panel").forEach((p) => p.classList.toggle("active", p.id === name));
}
$$(".tool").forEach((b) =>
  b.addEventListener("click", () => {
    history.replaceState(null, "", `#${b.dataset.tab}`);
    openTab(b.dataset.tab);
  })
);
openTab(location.hash.slice(1));

// --- environment badge -----------------------------------------------------------

fetch("/api/info")
  .then((r) => r.json())
  .then((info) => {
    $("#env").dataset.env = info.environment;
    $("#env-name").textContent = info.environment;
    $("#env-ver").textContent = info.version;
    if (info.key_vault?.connected) {
      $("#kv").dataset.state = "on";
      $("#kv-state").textContent = info.key_vault.fingerprint;
    }
    if (info.telemetry) $("#telemetry").textContent = " · traced by Application Insights";
  })
  .catch(() => {});

// --- passwords & tokens ----------------------------------------------------------

const POOLS = { upper: 26, lower: 26, digits: 10, symbols: 22 };

function strength(length, opts) {
  const pool = Object.keys(POOLS).reduce((n, k) => n + (opts[k] ? POOLS[k] : 0), 0);
  const bits = Math.round(length * Math.log2(pool || 1));
  const levels = [
    [50, "Weak", "var(--error)"],
    [80, "Fair", "var(--warn)"],
    [110, "Strong", "var(--accent)"],
    [Infinity, "Very strong", "var(--accent)"],
  ];
  const [, label, color] = levels.find(([max]) => bits < max);
  return { bits, label, color };
}

async function genPassword() {
  const opts = {
    length: Number($("#pw-length").value),
    upper: $("#pw-upper").checked,
    lower: $("#pw-lower").checked,
    digits: $("#pw-digits").checked,
    symbols: $("#pw-symbols").checked,
  };
  const value = $("#r-password .value");
  try {
    const data = await api("/api/password", opts);
    value.textContent = data.password;
    const s = strength(opts.length, opts);
    const bar = $("#pw-meter i");
    bar.style.width = `${Math.min(100, (s.bits / 128) * 100)}%`;
    bar.style.background = s.color;
    $("#pw-meter .meter-label").textContent = `${s.label} · ~${s.bits} bits of entropy`;
  } catch (err) {
    value.textContent = "";
    $("#pw-meter .meter-label").textContent = err.message;
  }
}

$("#pw-length").addEventListener("input", (e) => ($("#pw-length-out").textContent = e.target.value));
$("#pw-length").addEventListener("change", genPassword);
$$("#f-password input[type=checkbox]").forEach((c) => c.addEventListener("change", genPassword));
$("#f-password").addEventListener("submit", (e) => { e.preventDefault(); genPassword(); });

async function genToken() {
  const format = $("input[name=tk-format]:checked").value;
  try {
    const data = await api("/api/token", { bytes: Number($("#tk-bytes").value), format });
    $("#r-token .value").textContent = data.token;
  } catch (err) {
    $("#r-token .value").textContent = err.message;
  }
}
$("#f-token").addEventListener("submit", (e) => { e.preventDefault(); genToken(); });
$("#tk-bytes").addEventListener("change", genToken);
$$("input[name=tk-format]").forEach((r) => r.addEventListener("change", genToken));

// --- hash & base64 ---------------------------------------------------------------

const runHashes = debounce(async () => {
  const text = $("#h-text").value;
  await Promise.all(
    $$("#r-hashes [data-alg]").map(async (row) => {
      const out = $(".value", row);
      try {
        out.textContent = (await api("/api/hash", { text, algorithm: row.dataset.alg })).hash;
      } catch (err) {
        out.textContent = err.message;
      }
    })
  );
});
$("#h-text").addEventListener("input", runHashes);

const runBase64 = debounce(async () => {
  const out = $("#r-b64 .value");
  try {
    const data = await api("/api/base64", {
      text: $("#b64-in").value,
      mode: $("input[name=b64-mode]:checked").value,
      urlsafe: $("#b64-urlsafe").checked,
    });
    out.textContent = data.result;
    out.style.color = "";
  } catch (err) {
    out.textContent = err.message;
    out.style.color = "var(--error)";
  }
});
$("#b64-in").addEventListener("input", runBase64);
$("#b64-urlsafe").addEventListener("change", runBase64);
$$("input[name=b64-mode]").forEach((r) =>
  r.addEventListener("change", () => {
    // Flip the last output into the input so encode -> decode round-trips.
    const out = $("#r-b64 .value").textContent;
    if (out && !$("#r-b64 .value").style.color) $("#b64-in").value = out;
    runBase64();
  })
);

// --- CIDR ------------------------------------------------------------------------

const ipToInt = (ip) => ip.split(".").reduce((n, o) => n * 256 + Number(o), 0);
const intToIp = (n) => [24, 16, 8, 0].map((s) => Math.floor(n / 2 ** s) % 256).join(".");

function fillSplitOptions(prefix, keep) {
  const select = $("#c-split");
  select.replaceChildren(el("option", { value: "" }, "no split"));
  for (let p = prefix + 1; p <= Math.min(32, prefix + 8); p++) {
    const count = 2 ** (p - prefix);
    select.append(el("option", { value: String(p) }, `/${p} · ${count} subnets`));
  }
  if (keep && keep > prefix && keep <= prefix + 8) select.value = String(keep);
}

function renderCidr(d) {
  // Network vs host bits
  const bits = $("#c-bits");
  bits.replaceChildren(...Array.from({ length: 32 }, (_, i) => el("i", { class: i < d.prefix ? "n" : "" })));
  const legend = el("div", { class: "bits-legend" },
    el("span", {}, "Network bits ", el("b", {}, `/${d.prefix}`)),
    el("span", {}, "Host bits ", el("b", {}, String(32 - d.prefix))));
  bits.after(legend);
  $$(".bits-legend").slice(1).forEach((n) => n.remove());

  const rows = [
    ["Network", d.network], ["Netmask", d.netmask], ["Wildcard", d.wildcard],
    ["Broadcast", d.broadcast], ["First usable", d.first_usable], ["Last usable", d.last_usable],
    ["Total addresses", d.total_addresses.toLocaleString()], ["Usable hosts", d.usable_hosts.toLocaleString()],
    ["Range type", d.is_private ? "Private (RFC 1918)" : "Public"],
  ];
  $("#c-kv").replaceChildren(...rows.map(([k, v]) => el("div", {}, el("dt", {}, k), el("dd", {}, String(v)))));

  const azure = $("#c-azure");
  const icon = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3l8 4v5c0 4.5-3.4 8.3-8 9-4.6-.7-8-4.5-8-9V7z"/></svg>';
  if (d.azure_usable !== null) {
    const base = ipToInt(d.network);
    const reserved = [0, 1, 2, 3].map((o) => intToIp(base + o)).concat(d.broadcast);
    azure.innerHTML = icon;
    azure.append(el("div", {},
      el("p", {}, "As an Azure subnet: ", el("b", {}, d.azure_usable.toLocaleString()),
        " usable addresses, starting at ", el("b", {}, d.azure_first_usable), "."),
      el("div", { class: "reserved" }, ...reserved.map((ip, i) =>
        el("code", { title: ["network", "default gateway", "Azure DNS", "Azure DNS", "broadcast"][i] }, ip)))));
  } else {
    azure.innerHTML = icon;
    azure.append(el("p", {}, "Too small for an Azure subnet. Azure needs at least a /29 (8 addresses, 3 usable)."));
  }

  const subnets = $("#c-subnets");
  subnets.replaceChildren();
  if (d.subnets) {
    subnets.append(el("h3", {}, `${d.subnets.length} subnets`),
      el("div", { class: "subnets" }, ...d.subnets.map((s) => el("code", {}, s))));
  }
}

async function runCidr() {
  const split = $("#c-split").value;
  try {
    const d = await api("/api/cidr", { cidr: $("#c-cidr").value, split_prefix: split ? Number(split) : null });
    showError("#e-cidr", null);
    $("#r-cidr").hidden = false;
    fillSplitOptions(d.prefix, Number(split));
    renderCidr(d);
  } catch (err) {
    showError("#e-cidr", err);
    $("#r-cidr").hidden = true;
  }
}
$("#f-cidr").addEventListener("submit", (e) => { e.preventDefault(); runCidr(); });
$("#c-split").addEventListener("change", runCidr);
$("#c-cidr").addEventListener("change", () => { $("#c-split").value = ""; runCidr(); });

// --- cron ------------------------------------------------------------------------

const CRON_LABELS = ["minute", "hour", "day of month", "month", "day of week"];

async function runCron() {
  try {
    const d = await api("/api/cron", { expression: $("#cr-expr").value });
    showError("#e-cron", null);
    $("#r-cron").hidden = false;
    $("#cr-sentence").textContent = d.description;
    $("#cr-fields").replaceChildren(...d.expression.split(/\s+/).map((f, i) =>
      el("div", {}, el("code", {}, f), el("span", {}, CRON_LABELS[i]))));
    $("#cr-runs").replaceChildren(...d.next_runs.map((r) => el("li", {}, `${r} UTC`)));
  } catch (err) {
    showError("#e-cron", err);
    $("#r-cron").hidden = true;
  }
}
$("#f-cron").addEventListener("submit", (e) => { e.preventDefault(); runCron(); });
$$(".presets button").forEach((b) =>
  b.addEventListener("click", () => { $("#cr-expr").value = b.dataset.cron; runCron(); })
);

// --- first paint: every tool opens with a live example ---------------------------

genPassword();
genToken();
runHashes();
runBase64();
fillSplitOptions(16);
$("#c-split").value = "18";
runCidr();
runCron();
