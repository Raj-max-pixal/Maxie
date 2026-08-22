package com.maxie.mobile;

import android.Manifest;
import android.content.Intent;
import android.os.Bundle;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import android.speech.tts.TextToSpeech;
import android.speech.tts.UtteranceProgressListener;
import android.util.Log;

import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.annotation.Permission;
import com.getcapacitor.annotation.PermissionCallback;
import com.getcapacitor.PermissionState;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

@CapacitorPlugin(
    name = "Voice",
    permissions = {
        @Permission(
            alias = "microphone",
            strings = { Manifest.permission.RECORD_AUDIO }
        )
    }
)
public class VoicePlugin extends Plugin implements TextToSpeech.OnInitListener {
    private static final String TAG = "VoicePlugin";
    private SpeechRecognizer speechRecognizer;
    private TextToSpeech tts;
    private boolean ttsInitialized = false;
    private Intent recognizerIntent;
    private PluginCall activeSpeechCall;

    @Override
    public void load() {
        super.load();
        
        // Initialize SpeechRecognizer on UI Thread
        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    if (SpeechRecognizer.isRecognitionAvailable(getContext())) {
                        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(getContext());
                        setupRecognizerListener();
                        
                        recognizerIntent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
                        recognizerIntent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
                        recognizerIntent.putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true);
                        recognizerIntent.putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 5);
                    }
                } catch (Exception e) {
                    Log.e(TAG, "Error initializing SpeechRecognizer", e);
                }
            }
        });

        // Initialize TextToSpeech
        try {
            tts = new TextToSpeech(getContext(), this);
        } catch (Exception e) {
            Log.e(TAG, "Error initializing TextToSpeech", e);
        }
    }

    @Override
    public void onInit(int status) {
        if (status == TextToSpeech.SUCCESS) {
            ttsInitialized = true;
            tts.setLanguage(Locale.US);
            tts.setOnUtteranceProgressListener(new UtteranceProgressListener() {
                @Override
                public void onStart(String utteranceId) {
                    JSObject data = new JSObject();
                    data.put("state", "speaking");
                    notifyListeners("ttsStateChange", data);
                }

                @Override
                public void onDone(String utteranceId) {
                    JSObject data = new JSObject();
                    data.put("state", "done");
                    notifyListeners("ttsStateChange", data);
                }

                @Override
                public void onError(String utteranceId) {
                    JSObject data = new JSObject();
                    data.put("state", "error");
                    notifyListeners("ttsStateChange", data);
                }
            });
        } else {
            Log.e(TAG, "Failed to initialize TextToSpeech status: " + status);
        }
    }

    private void setupRecognizerListener() {
        if (speechRecognizer == null) return;
        speechRecognizer.setRecognitionListener(new RecognitionListener() {
            @Override
            public void onReadyForSpeech(Bundle params) {
                JSObject data = new JSObject();
                data.put("state", "ready");
                notifyListeners("sttStateChange", data);
            }

            @Override
            public void onBeginningOfSpeech() {
                JSObject data = new JSObject();
                data.put("state", "listening");
                notifyListeners("sttStateChange", data);
            }

            @Override
            public void onRmsChanged(float rmsdB) {}

            @Override
            public void onBufferReceived(byte[] buffer) {}

            @Override
            public void onEndOfSpeech() {
                JSObject data = new JSObject();
                data.put("state", "processing");
                notifyListeners("sttStateChange", data);
            }

            @Override
            public void onError(int error) {
                String errorMsg = getErrorMessage(error);
                Log.w(TAG, "Speech recognition error: " + errorMsg);
                
                JSObject data = new JSObject();
                data.put("state", "error");
                data.put("error", errorMsg);
                notifyListeners("sttStateChange", data);

                if (activeSpeechCall != null) {
                    activeSpeechCall.reject(errorMsg);
                    activeSpeechCall = null;
                }
            }

            @Override
            public void onResults(Bundle results) {
                ArrayList<String> matches = results.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
                String transcript = "";
                if (matches != null && !matches.isEmpty()) {
                    transcript = matches.get(0);
                }

                JSObject data = new JSObject();
                data.put("state", "done");
                data.put("text", transcript);
                notifyListeners("sttStateChange", data);

                if (activeSpeechCall != null) {
                    JSObject ret = new JSObject();
                    ret.put("text", transcript);
                    activeSpeechCall.resolve(ret);
                    activeSpeechCall = null;
                }
            }

            @Override
            public void onPartialResults(Bundle partialResults) {
                ArrayList<String> matches = partialResults.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
                if (matches != null && !matches.isEmpty()) {
                    JSObject data = new JSObject();
                    data.put("text", matches.get(0));
                    notifyListeners("sttPartialResult", data);
                }
            }

            @Override
            public void onEvent(int eventType, Bundle params) {}
        });
    }

    private String getErrorMessage(int errorCode) {
        switch (errorCode) {
            case SpeechRecognizer.ERROR_AUDIO: return "Audio recording error";
            case SpeechRecognizer.ERROR_CLIENT: return "Client-side error";
            case SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS: return "Insufficient permissions";
            case SpeechRecognizer.ERROR_NETWORK: return "Network error";
            case SpeechRecognizer.ERROR_NETWORK_TIMEOUT: return "Network timeout";
            case SpeechRecognizer.ERROR_NO_MATCH: return "No match found";
            case SpeechRecognizer.ERROR_RECOGNIZER_BUSY: return "Speech recognizer is busy";
            case SpeechRecognizer.ERROR_SERVER: return "Server error";
            case SpeechRecognizer.ERROR_SPEECH_TIMEOUT: return "No speech input timeout";
            default: return "Unknown speech recognition error";
        }
    }

    @PluginMethod
    public void isSpeechRecognitionAvailable(PluginCall call) {
        JSObject ret = new JSObject();
        boolean available = SpeechRecognizer.isRecognitionAvailable(getContext());
        ret.put("available", available);
        call.resolve(ret);
    }

    @PluginMethod
    public void startListening(PluginCall call) {
        if (getPermissionState("microphone") != PermissionState.GRANTED) {
            activeSpeechCall = call;
            requestPermissionForAlias("microphone", call, "microphoneCallback");
        } else {
            startListeningInternal(call);
        }
    }

    @PermissionCallback
    private void microphoneCallback(PluginCall call) {
        if (getPermissionState("microphone") == PermissionState.GRANTED) {
            startListeningInternal(call);
        } else {
            call.reject("Microphone permission denied");
        }
    }

    private void startListeningInternal(final PluginCall call) {
        if (speechRecognizer == null) {
            call.reject("Speech recognition is not available");
            return;
        }

        activeSpeechCall = call;
        final String language = call.getString("language", "en-US");

        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    speechRecognizer.cancel();
                    Intent intent = new Intent(recognizerIntent);
                    intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, language);
                    speechRecognizer.startListening(intent);
                } catch (Exception e) {
                    call.reject("Failed to start listening: " + e.getMessage());
                }
            }
        });
    }

    @PluginMethod
    public void stopListening(PluginCall call) {
        if (speechRecognizer == null) {
            call.reject("Speech recognition is not available");
            return;
        }

        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    speechRecognizer.stopListening();
                    call.resolve();
                } catch (Exception e) {
                    call.reject("Failed to stop listening: " + e.getMessage());
                }
            }
        });
    }

    @PluginMethod
    public void cancelListening(PluginCall call) {
        if (speechRecognizer == null) {
            call.reject("Speech recognition is not available");
            return;
        }

        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    speechRecognizer.cancel();
                    activeSpeechCall = null;
                    call.resolve();
                } catch (Exception e) {
                    call.reject("Failed to cancel listening: " + e.getMessage());
                }
            }
        });
    }

    @PluginMethod
    public void getSupportedLanguages(PluginCall call) {
        JSObject ret = new JSObject();
        JSArray list = new JSArray();
        list.put("en-US");
        list.put("ta-IN"); // Tamil
        ret.put("languages", list);
        call.resolve(ret);
    }

    @PluginMethod
    public void isTTSAvailable(PluginCall call) {
        JSObject ret = new JSObject();
        ret.put("available", ttsInitialized);
        call.resolve(ret);
    }

    @PluginMethod
    public void speak(PluginCall call) {
        if (!ttsInitialized || tts == null) {
            call.reject("Text-to-Speech is not initialized or supported");
            return;
        }

        final String text = call.getString("text", "");
        final float rate = call.getFloat("rate", 1.0f);
        final float pitch = call.getFloat("pitch", 1.0f);
        final float volume = call.getFloat("volume", 1.0f);
        final String language = call.getString("language", "en-US");

        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    tts.setSpeechRate(rate);
                    tts.setPitch(pitch);
                    
                    if (language.startsWith("ta")) {
                        tts.setLanguage(new Locale("ta", "IN"));
                    } else {
                        tts.setLanguage(Locale.US);
                    }

                    Bundle params = new Bundle();
                    params.putFloat(TextToSpeech.Engine.KEY_PARAM_VOLUME, volume);

                    int result = tts.speak(text, TextToSpeech.QUEUE_FLUSH, params, "maxie_utterance");
                    if (result == TextToSpeech.SUCCESS) {
                        call.resolve();
                    } else {
                        call.reject("Failed to speak text, status code: " + result);
                    }
                } catch (Exception e) {
                    call.reject("Failed to speak: " + e.getMessage());
                }
            }
        });
    }

    @PluginMethod
    public void stopSpeaking(PluginCall call) {
        if (tts == null) {
            call.reject("Text-to-Speech is not available");
            return;
        }

        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    tts.stop();
                    call.resolve();
                } catch (Exception e) {
                    call.reject("Failed to stop speaking: " + e.getMessage());
                }
            }
        });
    }

    @PluginMethod
    public void getVoices(PluginCall call) {
        JSObject ret = new JSObject();
        JSArray array = new JSArray();
        
        // Return dynamic list of supported locales
        JSObject enVoice = new JSObject();
        enVoice.put("name", "English (US)");
        enVoice.put("lang", "en-US");
        array.put(enVoice);

        JSObject taVoice = new JSObject();
        taVoice.put("name", "Tamil (India)");
        taVoice.put("lang", "ta-IN");
        array.put(taVoice);

        ret.put("voices", array);
        call.resolve(ret);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (speechRecognizer != null) {
            speechRecognizer.destroy();
        }
        if (tts != null) {
            tts.stop();
            tts.shutdown();
        }
    }
}
