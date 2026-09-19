const fs = require("fs");
const path = require("path");
const { execFile, execFileSync } = require("child_process");

const IGNORED = new Set([".git", "node_modules", "dist", "build", ".dart_tool", ".next", "coverage"]);
const TEXT_EXTENSIONS = new Set([".js", ".cjs", ".mjs", ".ts", ".tsx", ".jsx", ".py", ".java", ".kt", ".dart", ".json", ".yaml", ".yml", ".env", ".properties", ".xml", ".gradle"]);
const SECRET_PATTERNS = [
  { name: "OpenAI-style API key", expression: /sk-[A-Za-z0-9_-]{20,}/ },
  { name: "GitHub personal token", expression: /gh[pousr]_[A-Za-z0-9_]{20,}/i },
  { name: "AWS access key", expression: /AKIA[0-9A-Z]{16}/ },
  { name: "Private key", expression: /-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----/ },
  { name: "Possible hard-coded credential", expression: /(?:api[_-]?key|secret|password|token)\s*[:=]\s*["'][^"'\s]{8,}/i }
];

function assertProjectRoot(root) {
  if (typeof root !== "string" || !path.isAbsolute(root) || !fs.existsSync(root) || !fs.statSync(root).isDirectory()) {
    throw new Error("Choose a valid local project folder first.");
  }
  return path.resolve(root);
}

function analyzeProject(root) {
  root = assertProjectRoot(root);
  const entries = safeReadDir(root);
  const files = entries.map((entry) => entry.name);
  const manifest = readJson(path.join(root, "package.json"));
  const framework = detectFramework(files, manifest);
  const git = gitStatus(root);
  const secrets = scanSecrets(root);
  return {
    root,
    name: path.basename(root),
    framework,
    language: detectLanguage(files),
    files: files.slice(0, 80),
    entryPoints: detectEntryPoints(files, manifest),
    commands: safeCommands(files, manifest),
    git,
    secrets,
    plan: createPlan(framework, secrets.length, git.changed),
    scannedAt: new Date().toISOString()
  };
}

function safeCommands(files, manifest) {
  const commands = [];
  if (manifest?.scripts) {
    for (const script of ["check", "lint", "test", "build"]) {
      if (typeof manifest.scripts[script] === "string") commands.push({ id: `npm:${script}`, label: `npm run ${script}` });
    }
  }
  if (files.includes("pubspec.yaml")) commands.push({ id: "flutter:analyze", label: "flutter analyze" });
  return commands;
}

function runSafeCommand(root, commandId) {
  root = assertProjectRoot(root);
  const command = analyzeProject(root).commands.find((item) => item.id === commandId);
  if (!command) throw new Error("That command is not in MAXie's approved project command list.");
  const [file, args] = commandId.startsWith("npm:")
    ? [process.platform === "win32" ? "npm.cmd" : "npm", ["run", commandId.slice(4)]]
    : [process.platform === "win32" ? "flutter.bat" : "flutter", ["analyze"]];
  return execute(file, args, root).then((result) => ({ ...result, label: command.label }));
}

function execute(file, args, cwd) {
  const startedAt = Date.now();
  return new Promise((resolve) => {
    execFile(file, args, { cwd, timeout: 120000, windowsHide: true, maxBuffer: 1024 * 1024 }, (error, stdout, stderr) => {
      resolve({
        exitCode: Number.isInteger(error?.code) ? error.code : 0,
        output: `${stdout || ""}${stderr ? `\n${stderr}` : ""}`.trim().slice(-12000),
        durationMs: Date.now() - startedAt,
        ok: !error
      });
    });
  });
}

function gitStatus(root) {
  try {
    const output = execFileSync("git", ["-C", root, "status", "--short"], { windowsHide: true, encoding: "utf8", timeout: 5000 });
    const changes = output.trim().split("\n").filter(Boolean);
    return { available: true, changed: changes.length, summary: changes.slice(0, 12) };
  } catch {
    return { available: false, changed: 0, summary: [] };
  }
}

function scanSecrets(root) {
  const findings = [];
  walk(root, (file) => {
    if (findings.length >= 20 || !TEXT_EXTENSIONS.has(path.extname(file).toLowerCase())) return;
    let text;
    try { text = fs.readFileSync(file, "utf8"); } catch { return; }
    for (const pattern of SECRET_PATTERNS) {
      if (pattern.expression.test(text)) {
        findings.push({ type: pattern.name, file: path.relative(root, file), risk: "Review before sharing or committing" });
        break;
      }
    }
  });
  return findings;
}

function walk(dir, visit) {
  for (const entry of safeReadDir(dir)) {
    if (entry.isDirectory()) {
      if (!IGNORED.has(entry.name)) walk(path.join(dir, entry.name), visit);
    } else if (entry.isFile()) visit(path.join(dir, entry.name));
  }
}

function safeReadDir(dir) { try { return fs.readdirSync(dir, { withFileTypes: true }); } catch { return []; } }
function readJson(file) { try { return JSON.parse(fs.readFileSync(file, "utf8")); } catch { return null; } }
function detectFramework(files, manifest) {
  if (files.includes("pubspec.yaml")) return "Flutter";
  if (files.includes("next.config.js") || files.includes("next.config.mjs") || manifest?.dependencies?.next) return "Next.js";
  if (manifest?.dependencies?.electron || manifest?.devDependencies?.electron) return "Electron";
  if (manifest?.dependencies?.react || manifest?.devDependencies?.react) return "React";
  if (files.includes("requirements.txt") || files.includes("pyproject.toml")) return "Python";
  return "Detected local project";
}
function detectLanguage(files) {
  if (files.includes("pubspec.yaml")) return "Dart";
  if (files.includes("package.json")) return "JavaScript / TypeScript";
  if (files.includes("requirements.txt") || files.includes("pyproject.toml")) return "Python";
  return "Mixed";
}
function detectEntryPoints(files, manifest) {
  return [manifest?.main, "main.js", "index.js", "index.html", "lib/main.dart", "src/main.ts", "src/main.tsx"]
    .filter((file) => file && (files.includes(file) || file === manifest?.main)).slice(0, 6);
}
function createPlan(framework, secretCount, changedFiles) {
  const plan = ["Inspect project structure and active Git changes", `Identify ${framework} entry points and approved checks`, "Run the user-approved verification command"];
  if (secretCount) plan.push("Review potential secrets before any commit or share");
  if (changedFiles) plan.push("Summarize uncommitted work before creating a checkpoint");
  plan.push("Report verified results and recommend the next safe step");
  return plan;
}

module.exports = { analyzeProject, runSafeCommand };
