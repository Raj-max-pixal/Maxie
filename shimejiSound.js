class ShimejiSound {
  constructor() {
    this.ctx = null;
    this.enabled = true;
    this.volume = 0.5; // 0.0 to 1.0
  }

  init() {
    if (!this.ctx && (window.AudioContext || window.webkitAudioContext)) {
      this.ctx = new (window.AudioContext || window.webkitAudioContext)();
    }
    if (this.ctx && this.ctx.state === 'suspended') {
      this.ctx.resume();
    }
  }

  play(name) {
    if (!this.enabled || this.volume <= 0) return;
    try {
      this.init();
      if (!this.ctx) return;

      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.connect(gain);
      gain.connect(this.ctx.destination);

      const now = this.ctx.currentTime;
      gain.gain.setValueAtTime(0, now);

      if (name === 'tap') {
        // Soft bubble pop
        osc.type = 'sine';
        osc.frequency.setValueAtTime(600, now);
        osc.frequency.exponentialRampToValueAtTime(150, now + 0.08);
        gain.gain.linearRampToValueAtTime(this.volume * 0.4, now + 0.01);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.08);
        osc.start(now);
        osc.stop(now + 0.09);
      } else if (name === 'jump') {
        // Cute upward slide
        osc.type = 'triangle';
        osc.frequency.setValueAtTime(300, now);
        osc.frequency.exponentialRampToValueAtTime(800, now + 0.15);
        gain.gain.linearRampToValueAtTime(this.volume * 0.3, now + 0.02);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.15);
        osc.start(now);
        osc.stop(now + 0.16);
      } else if (name === 'land') {
        // Soft low pitch landing thud
        osc.type = 'sine';
        osc.frequency.setValueAtTime(180, now);
        osc.frequency.linearRampToValueAtTime(80, now + 0.12);
        gain.gain.linearRampToValueAtTime(this.volume * 0.5, now + 0.01);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.12);
        osc.start(now);
        osc.stop(now + 0.13);
      } else if (name === 'happy') {
        // Cute high scale arpeggio: C5 -> E5 -> G5 -> C6
        osc.type = 'sine';
        const freqs = [523.25, 659.25, 783.99, 1046.50]; // C5, E5, G5, C6
        const step = 0.05;
        gain.gain.setValueAtTime(0, now);
        
        freqs.forEach((freq, idx) => {
          const t = now + idx * step;
          osc.frequency.setValueAtTime(freq, t);
          gain.gain.linearRampToValueAtTime(this.volume * 0.25, t + 0.01);
          gain.gain.setValueAtTime(this.volume * 0.25, t + step - 0.01);
          gain.gain.linearRampToValueAtTime(0, t + step);
        });
        
        osc.start(now);
        osc.stop(now + freqs.length * step + 0.02);
      }
    } catch (e) {
      console.warn("Failed to play sound synth:", e);
    }
  }
}

window.ShimejiSound = new ShimejiSound();
