const fs = require("fs");
const path = require("path");
const { app } = require("electron");

function createStore(fileName) {
  const dir = path.join(app.getPath("userData"), "storage");
  const filePath = path.join(dir, fileName);

  function ensureDir() {
    fs.mkdirSync(dir, { recursive: true });
  }

  function read(defaultValue) {
    ensureDir();
    if (!fs.existsSync(filePath)) {
      write(defaultValue);
      return defaultValue;
    }

    try {
      const parsed = JSON.parse(fs.readFileSync(filePath, "utf8"));
      return deepMerge(defaultValue, parsed);
    } catch {
      return defaultValue;
    }
  }

  function write(value) {
    ensureDir();
    fs.writeFileSync(filePath, JSON.stringify(value, null, 2), "utf8");
  }

  return { filePath, read, write };
}

function deepMerge(base, update) {
  if (!update || typeof update !== "object") return base;
  const output = Array.isArray(base) ? [...base] : { ...base };
  for (const [key, value] of Object.entries(update)) {
    if (value && typeof value === "object" && !Array.isArray(value)) {
      output[key] = deepMerge(base?.[key] || {}, value);
    } else {
      output[key] = value;
    }
  }
  return output;
}

module.exports = { createStore };
