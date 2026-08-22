const os = require("os");
const dns = require("dns").promises;
const { execFile } = require("child_process");

async function getSystemSnapshot() {
  const battery = await getBattery();
  const online = await getInternetStatus();
  return {
    battery,
    online,
    cpuUsage: getCpuUsage(),
    memory: {
      total: os.totalmem(),
      free: os.freemem()
    },
    platform: process.platform
  };
}

function getCpuUsage() {
  const cpus = os.cpus();
  if (!cpus.length) return 0;
  const totals = cpus.map((cpu) => Object.values(cpu.times).reduce((sum, value) => sum + value, 0));
  const idle = cpus.map((cpu) => cpu.times.idle);
  const total = totals.reduce((sum, value) => sum + value, 0);
  const idleTotal = idle.reduce((sum, value) => sum + value, 0);
  if (!total) return 0;
  return Math.round(100 - (idleTotal / total) * 100);
}

async function getInternetStatus() {
  try {
    await Promise.race([
      dns.lookup("example.com"),
      new Promise((_, reject) => setTimeout(() => reject(new Error("network timeout")), 1800))
    ]);
    return true;
  } catch {
    return false;
  }
}

async function getBattery() {
  if (process.platform !== "win32") return { supported: false, percent: null, charging: null };
  const script = `
$battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue | Select-Object -First 1
if ($null -eq $battery) {
  [pscustomobject]@{ supported = $false; percent = $null; charging = $null } | ConvertTo-Json -Compress
} else {
  [pscustomobject]@{
    supported = $true
    percent = [int]$battery.EstimatedChargeRemaining
    charging = @('6','7','8','9') -contains ([string]$battery.BatteryStatus)
  } | ConvertTo-Json -Compress
}
`;
  return new Promise((resolve) => {
    execFile("powershell.exe", ["-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", script], { timeout: 2500 }, (error, stdout) => {
      if (error) return resolve({ supported: false, percent: null, charging: null });
      try {
        resolve(JSON.parse(stdout));
      } catch {
        resolve({ supported: false, percent: null, charging: null });
      }
    });
  });
}

module.exports = { getSystemSnapshot };
