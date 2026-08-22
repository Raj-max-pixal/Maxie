// ═══════════════ SPEECH RECOGNITION ═══════════════

(function() {
  let webRecognition = null;
  let isListening = false;
  let capacitorPlugin = null;

  window.SpeechRec = {
    /**
     * Check if speech recognition is supported
     */
    isSupported() {
      if (window.Capacitor?.Plugins?.Voice) return true;
      return Boolean(window.SpeechRecognition || window.webkitSpeechRecognition);
    },

    /**
     * Initialize recognition listener
     */
    init(onResult, onError, onEnd) {
      if (window.Capacitor?.Plugins?.Voice) {
        capacitorPlugin = window.Capacitor.Plugins.Voice;
        
        // Listen to partial results from native Android
        capacitorPlugin.addListener("sttPartialResult", (data) => {
          if (data && data.text && typeof onResult === "function") {
            onResult(data.text, true); // true = is partial
          }
        });

        // Listen to state changes from native Android
        capacitorPlugin.addListener("sttStateChange", (data) => {
          if (!data) return;
          console.log("[SpeechRec Native State]:", data.state);
          
          if (data.state === "listening") {
            isListening = true;
          } else if (data.state === "done") {
            isListening = false;
            if (data.text && typeof onResult === "function") {
              onResult(data.text, false); // false = final
            }
            if (typeof onEnd === "function") onEnd();
          } else if (data.state === "error") {
            isListening = false;
            if (typeof onError === "function") onError(data.error || "Native recognition error");
            if (typeof onEnd === "function") onEnd();
          }
        });
        return;
      }

      if (!this.isSupported()) return;

      const SpeechRecClass = window.SpeechRecognition || window.webkitSpeechRecognition;
      webRecognition = new SpeechRecClass();
      webRecognition.continuous = false;
      webRecognition.interimResults = true;
      webRecognition.lang = "en-US";

      webRecognition.onresult = (event) => {
        let interimTranscript = "";
        let finalTranscript = "";

        for (let i = event.resultIndex; i < event.results.length; ++i) {
          if (event.results[i].isFinal) {
            finalTranscript += event.results[i][0].transcript;
          } else {
            interimTranscript += event.results[i][0].transcript;
          }
        }

        if (finalTranscript && typeof onResult === "function") {
          onResult(finalTranscript, false); // final
        } else if (interimTranscript && typeof onResult === "function") {
          onResult(interimTranscript, true); // partial
        }
      };

      webRecognition.onerror = (event) => {
        console.error("[SpeechRec Web] Error:", event.error);
        if (typeof onError === "function") onError(event.error);
      };

      webRecognition.onend = () => {
        isListening = false;
        if (typeof onEnd === "function") onEnd();
      };
    },

    /**
     * Start speech capturing
     */
    start(lang = "en-US") {
      if (capacitorPlugin) {
        isListening = true;
        const formattedLang = lang.replace("_", "-");
        capacitorPlugin.startListening({ language: formattedLang }).catch(err => {
          console.error("[SpeechRec Native] Start failed:", err);
          isListening = false;
        });
        return;
      }

      if (!webRecognition || isListening) return;
      try {
        webRecognition.lang = lang;
        webRecognition.start();
        isListening = true;
      } catch (e) {
        console.error("[SpeechRec Web] Start failed:", e);
      }
    },

    /**
     * Stop speech capturing
     */
    stop() {
      if (capacitorPlugin) {
        capacitorPlugin.stopListening().catch(err => console.error(err));
        isListening = false;
        return;
      }

      if (!webRecognition || !isListening) return;
      try {
        webRecognition.stop();
        isListening = false;
      } catch (e) {
        console.error("[SpeechRec Web] Stop failed:", e);
      }
    },

    /**
     * Cancel speech capturing
     */
    cancel() {
      if (capacitorPlugin) {
        capacitorPlugin.cancelListening().catch(err => console.error(err));
        isListening = false;
        return;
      }

      if (!webRecognition) return;
      try {
        webRecognition.abort();
        isListening = false;
      } catch (e) {
        console.error("[SpeechRec Web] Abort failed:", e);
      }
    },

    isListening() {
      return isListening;
    }
  };
})();
