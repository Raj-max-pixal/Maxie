// ═══════════════ TEXT TO SPEECH SYNTHESIZER ═══════════════

(function() {
  let capacitorPlugin = null;
  let isSpeakingState = false;

  window.TtsSynthesis = {
    /**
     * Check if TTS synthesis is supported
     */
    isSupported() {
      if (window.Capacitor?.Plugins?.Voice) return true;
      return Boolean(window.speechSynthesis);
    },

    /**
     * Initialize listeners
     */
    init() {
      if (window.Capacitor?.Plugins?.Voice) {
        capacitorPlugin = window.Capacitor.Plugins.Voice;
        capacitorPlugin.addListener("ttsStateChange", (data) => {
          if (!data) return;
          console.log("[TtsSynthesis Native State]:", data.state);
          if (data.state === "speaking") {
            isSpeakingState = true;
            if (window.companionEngine) {
              window.companionEngine.handleEvent("SPEAKING_START");
            }
          } else if (data.state === "done" || data.state === "error") {
            isSpeakingState = false;
            if (window.companionEngine) {
              window.companionEngine.handleEvent("SPEAKING_END");
            }
          }
        });
      }
    },

    /**
     * Speak text using SpeechSynthesis / Native TTS
     */
    speak(text, options = {}) {
      if (!this.isSupported()) return;

      const rate = options.rate !== undefined ? options.rate : 1.0;
      const pitch = options.pitch !== undefined ? options.pitch : 1.15;
      const volume = options.volume !== undefined ? options.volume : 0.5;
      const lang = options.language || "en-US";

      // Stop any current speaking
      this.stop();

      // Clean emojis
      const cleanText = text.replace(/[\uE000-\uF8FF]|\uD83C[\uDF00-\uDFFF]|\uD83D[\uDC00-\uDDFF]/g, "");

      if (capacitorPlugin) {
        isSpeakingState = true;
        capacitorPlugin.speak({
          text: cleanText,
          rate: rate,
          pitch: pitch,
          volume: volume,
          language: lang
        }).catch(err => {
          console.error("[TtsSynthesis Native] Speak failed:", err);
          isSpeakingState = false;
        });
        return;
      }

      if (!window.speechSynthesis) return;

      const utterance = new SpeechSynthesisUtterance(cleanText);
      utterance.rate = rate;
      utterance.pitch = pitch;
      utterance.volume = volume;

      if (lang.startsWith("ta")) {
        utterance.lang = "ta-IN";
      } else {
        utterance.lang = "en-US";
      }

      // Select voice
      const voices = window.speechSynthesis.getVoices();
      let preferred = null;
      if (lang.startsWith("ta")) {
        preferred = voices.find(v => v.lang.startsWith("ta"));
      } else {
        preferred = voices.find(v => v.lang.startsWith("en") && v.name.toLowerCase().includes("google"));
      }
      if (preferred) {
        utterance.voice = preferred;
      }

      utterance.onstart = () => {
        isSpeakingState = true;
        if (window.companionEngine) {
          window.companionEngine.handleEvent("SPEAKING_START");
        }
      };

      utterance.onend = () => {
        isSpeakingState = false;
        if (window.companionEngine) {
          window.companionEngine.handleEvent("SPEAKING_END");
        }
      };

      utterance.onerror = () => {
        isSpeakingState = false;
        if (window.companionEngine) {
          window.companionEngine.handleEvent("SPEAKING_END");
        }
      };

      window.speechSynthesis.speak(utterance);
    },

    /**
     * Stop and cancel speaking
     */
    stop() {
      isSpeakingState = false;
      if (capacitorPlugin) {
        capacitorPlugin.stopSpeaking().catch(err => console.error(err));
        if (window.companionEngine) {
          window.companionEngine.handleEvent("SPEAKING_END");
        }
        return;
      }

      if (window.speechSynthesis) {
        window.speechSynthesis.cancel();
        if (window.companionEngine) {
          window.companionEngine.handleEvent("SPEAKING_END");
        }
      }
    },

    /**
     * Pause speaking
     */
    pause() {
      if (window.speechSynthesis) {
        window.speechSynthesis.pause();
      }
    },

    /**
     * Resume speaking
     */
    resume() {
      if (window.speechSynthesis) {
        window.speechSynthesis.resume();
      }
    },

    isSpeaking() {
      return isSpeakingState;
    },

    /**
     * Get list of system voices
     */
    async getVoices() {
      if (capacitorPlugin) {
        try {
          const res = await capacitorPlugin.getVoices();
          return res.voices || [];
        } catch (e) {
          return [];
        }
      }

      if (window.speechSynthesis) {
        return window.speechSynthesis.getVoices().map(v => ({
          name: v.name,
          lang: v.lang
        }));
      }
      return [];
    }
  };

  // Initialize immediately
  window.TtsSynthesis.init();
})();
