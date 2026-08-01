const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("maxie", {
  state: {
    get: () => ipcRenderer.invoke("state:get"),
    set: (partial) => ipcRenderer.invoke("state:set", partial),
    onChanged: (callback) => ipcRenderer.on("state:changed", (_event, state) => callback(state))
  },
  pet: {
    getDisplays: () => ipcRenderer.invoke("pet:get-displays"),
    getBounds: () => ipcRenderer.invoke("pet:get-bounds"),
    setBounds: (bounds) => ipcRenderer.invoke("pet:set-bounds", bounds),
    setClickThrough: (enabled) => ipcRenderer.invoke("pet:set-click-through", enabled),
    hide: () => ipcRenderer.invoke("pet:hide"),
    show: () => ipcRenderer.invoke("pet:show"),
    command: (command) => ipcRenderer.invoke("pet:command", command),
    photo: () => ipcRenderer.invoke("pet:photo"),
    onCommand: (callback) => ipcRenderer.on("pet:command", (_event, command) => callback(command))
  },
  settings: {
    open: () => ipcRenderer.invoke("settings:open")
  },
  system: {
    getSnapshot: () => ipcRenderer.invoke("system:get-snapshot"),
    getActiveApp: () => ipcRenderer.invoke("system:get-active-app"),
    getMediaApp: () => ipcRenderer.invoke("system:get-media-app"),
    getStartup: () => ipcRenderer.invoke("system:get-startup"),
    setStartup: (enabled) => ipcRenderer.invoke("system:set-startup", enabled)
  },
  ai: {
    chat: (messages) => ipcRenderer.invoke("ai:chat", messages)
  },
  notify: (payload) => ipcRenderer.invoke("notify", payload),
  project: {
    openFolder: () => ipcRenderer.invoke("project:open-folder")
  }
});
