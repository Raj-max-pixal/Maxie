const el = (id) => document.getElementById(id);
let root = null;
const addActivity = (title, detail = "") => { const item = document.createElement("li"); item.innerHTML = `<strong>${title}</strong>${detail}`; el("timeline").prepend(item); };
const setState = (value) => { el("agentState").textContent = value; };

el("chooseProject").addEventListener("click", async () => {
  root = await window.maxie.project.chooseFolder();
  if (!root) return;
  el("projectPath").value = root;
  el("analyze").disabled = false;
  addActivity("Project selected", root);
});

el("analyze").addEventListener("click", async () => {
  setState("Inspecting"); el("analyze").disabled = true; addActivity("Orchestrator started", "Read-only project inspection");
  try { renderAnalysis(await window.maxie.project.analyze(root)); } catch (error) { addActivity("Inspection failed", error.message); el("output").textContent = error.message; setState("Needs attention"); }
  finally { el("analyze").disabled = false; }
});

function renderAnalysis(data) {
  el("empty").hidden = true; el("workspace").hidden = false;
  el("projectName").textContent = data.name; el("framework").textContent = `${data.framework} · ${data.language}`;
  el("gitState").textContent = data.git.available ? `${data.git.changed} changed` : "Not a Git repo";
  el("securityState").textContent = data.secrets.length ? `${data.secrets.length} review` : "Protected";
  el("securityState").className = data.secrets.length ? "danger" : "safe"; setState("Plan ready");
  el("plan").replaceChildren(...data.plan.map((step) => { const node = document.createElement("li"); node.textContent = step; return node; }));
  el("commands").replaceChildren(...data.commands.map((command) => { const button = document.createElement("button"); button.textContent = `Run ${command.label}`; button.onclick = () => runCheck(command); return button; }));
  if (!data.commands.length) el("commands").textContent = "No known safe verification command found.";
  el("secrets").replaceChildren(...(data.secrets.length ? data.secrets.map((finding) => { const node = document.createElement("div"); node.className = "finding"; node.innerHTML = `<strong>⚠ ${finding.type}</strong><p>${finding.file}</p><p>${finding.risk}</p>`; return node; }) : [message("✓ No supported secret patterns found in scanned source files.", "safe")]));
  addActivity("Project detected", `${data.framework}; ${data.commands.length} approved checks available`);
  addActivity("Security Agent completed", data.secrets.length ? `${data.secrets.length} item(s) need review` : "No supported secret pattern found");
}

async function runCheck(command) {
  setState("Verifying"); addActivity("Approval received", command.label); el("output").textContent = `Running ${command.label}…`;
  const result = await window.maxie.project.runSafeCheck(root, command.id);
  el("output").textContent = `${result.ok ? "✓ Passed" : "✕ Failed"} · ${result.label} · ${(result.durationMs / 1000).toFixed(1)}s\n\n${result.output || "No output returned."}`;
  setState(result.ok ? "Verified" : "Needs attention"); addActivity(result.ok ? "Verification passed" : "Verification failed", command.label);
}
function message(text, className) { const node = document.createElement("p"); node.textContent = text; node.className = className; return node; }
