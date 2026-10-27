// Tabs
document.querySelectorAll("nav button").forEach((btn) => {
  btn.addEventListener("click", () => {
    document.querySelectorAll("nav button, .tab").forEach((el) => el.classList.remove("active"));
    btn.classList.add("active");
    document.getElementById(btn.dataset.tab).classList.add("active");
  });
});

// Every <form data-api="..."> posts its fields as JSON and prints the reply
// into the next <pre class="out">. data-out picks one field to show alone.
function formToJson(form) {
  const body = {};
  for (const el of form.elements) {
    if (!el.name) continue;
    if (el.type === "checkbox") body[el.name] = el.checked;
    else if (el.type === "number") {
      if (el.value !== "") body[el.name] = Number(el.value);
    } else body[el.name] = el.value;
  }
  return body;
}

function outputFor(form) {
  let el = form.nextElementSibling;
  while (el && !el.classList.contains("out")) el = el.nextElementSibling;
  return el;
}

document.querySelectorAll("form[data-api]").forEach((form) => {
  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    const out = outputFor(form);
    out.classList.remove("error");
    try {
      const res = await fetch(form.dataset.api, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formToJson(form)),
      });
      const data = await res.json();
      if (!res.ok) {
        const detail = Array.isArray(data.detail)
          ? data.detail.map((d) => d.msg).join("; ")
          : data.detail;
        throw new Error(detail || res.statusText);
      }
      const field = form.dataset.out;
      out.textContent = field ? data[field] : JSON.stringify(data, null, 2);
    } catch (err) {
      out.classList.add("error");
      out.textContent = err.message;
    }
  });
});

// Show which environment and version is serving the page.
fetch("/api/info")
  .then((r) => r.json())
  .then((i) => (document.getElementById("env").textContent = `${i.environment} · ${i.version}`))
  .catch(() => {});
