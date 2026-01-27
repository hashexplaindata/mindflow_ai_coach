class BinauralGenerator {
  constructor() {
    this.audioContext = null;
    this.leftOscillator = null;
    this.rightOscillator = null;
    this.leftPanner = null;
    this.rightPanner = null;
    this.gainNode = null;
    this.isPlaying = false;
    this.carrierFrequency = 500;
  }

  init() {
    if (!this.audioContext) {
      this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
    }
    return this.audioContext.state === 'running' || this.audioContext.resume();
  }

  start(beatFrequency, volume = 0.3) {
    if (this.isPlaying) {
      this.stop();
    }

    this.init();

    const leftFreq = this.carrierFrequency - (beatFrequency / 2);
    const rightFreq = this.carrierFrequency + (beatFrequency / 2);

    this.gainNode = this.audioContext.createGain();
    this.gainNode.gain.value = 0;
    this.gainNode.connect(this.audioContext.destination);

    this.leftPanner = this.audioContext.createStereoPanner();
    this.leftPanner.pan.value = -1;
    this.leftPanner.connect(this.gainNode);

    this.rightPanner = this.audioContext.createStereoPanner();
    this.rightPanner.pan.value = 1;
    this.rightPanner.connect(this.gainNode);

    this.leftOscillator = this.audioContext.createOscillator();
    this.leftOscillator.type = 'sine';
    this.leftOscillator.frequency.value = leftFreq;
    this.leftOscillator.connect(this.leftPanner);

    this.rightOscillator = this.audioContext.createOscillator();
    this.rightOscillator.type = 'sine';
    this.rightOscillator.frequency.value = rightFreq;
    this.rightOscillator.connect(this.rightPanner);

    this.leftOscillator.start();
    this.rightOscillator.start();

    this.fadeIn(1000, volume);

    this.isPlaying = true;
  }

  stop() {
    if (!this.isPlaying) return;

    this.fadeOut(500, () => {
      if (this.leftOscillator) {
        try { this.leftOscillator.stop(); } catch (e) {}
        this.leftOscillator.disconnect();
        this.leftOscillator = null;
      }

      if (this.rightOscillator) {
        try { this.rightOscillator.stop(); } catch (e) {}
        this.rightOscillator.disconnect();
        this.rightOscillator = null;
      }

      if (this.leftPanner) {
        this.leftPanner.disconnect();
        this.leftPanner = null;
      }

      if (this.rightPanner) {
        this.rightPanner.disconnect();
        this.rightPanner = null;
      }

      if (this.gainNode) {
        this.gainNode.disconnect();
        this.gainNode = null;
      }

      this.isPlaying = false;
    });
  }

  setVolume(volume) {
    if (this.gainNode && this.isPlaying) {
      const clampedVolume = Math.max(0, Math.min(1, volume));
      this.gainNode.gain.setTargetAtTime(clampedVolume, this.audioContext.currentTime, 0.1);
    }
  }

  fadeIn(durationMs, targetVolume = 0.3) {
    if (this.gainNode && this.audioContext) {
      const now = this.audioContext.currentTime;
      this.gainNode.gain.setValueAtTime(0, now);
      this.gainNode.gain.linearRampToValueAtTime(targetVolume, now + (durationMs / 1000));
    }
  }

  fadeOut(durationMs, callback) {
    if (this.gainNode && this.audioContext) {
      const now = this.audioContext.currentTime;
      const currentVolume = this.gainNode.gain.value;
      this.gainNode.gain.setValueAtTime(currentVolume, now);
      this.gainNode.gain.linearRampToValueAtTime(0, now + (durationMs / 1000));

      if (callback) {
        setTimeout(callback, durationMs);
      }
    } else if (callback) {
      callback();
    }
  }

  pause() {
    if (this.audioContext && this.audioContext.state === 'running') {
      this.audioContext.suspend();
    }
  }

  resume() {
    if (this.audioContext && this.audioContext.state === 'suspended') {
      this.audioContext.resume();
    }
  }

  getIsPlaying() {
    return this.isPlaying;
  }

  dispose() {
    if (this.isPlaying) {
      if (this.leftOscillator) {
        try { this.leftOscillator.stop(); } catch (e) {}
        this.leftOscillator.disconnect();
      }
      if (this.rightOscillator) {
        try { this.rightOscillator.stop(); } catch (e) {}
        this.rightOscillator.disconnect();
      }
      if (this.leftPanner) this.leftPanner.disconnect();
      if (this.rightPanner) this.rightPanner.disconnect();
      if (this.gainNode) this.gainNode.disconnect();
    }

    if (this.audioContext) {
      this.audioContext.close();
      this.audioContext = null;
    }

    this.leftOscillator = null;
    this.rightOscillator = null;
    this.leftPanner = null;
    this.rightPanner = null;
    this.gainNode = null;
    this.isPlaying = false;
  }
}

window.binauralGenerator = new BinauralGenerator();
