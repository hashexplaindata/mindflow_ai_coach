/**
 * ADVANCED HYPNOTIC AUDIO ENGINE WITH LO-FI CHILLHOP AESTHETICS
 * 
 * Combines therapeutic binaural beats with warm, tape-like Lo-Fi processing
 * inspired by Majineo's meditation music.
 * 
 * Lo-Fi Characteristics:
 * - Frequency Response: Low-Pass Filter @ 10kHz + 200-500Hz warmth boost
 * - BPM: 70-90 BPM rhythm layer (relaxed heartbeat tempo)
 * - Pitch Modulation: Wow & Flutter (tape warping simulation)
 * - Timbre: Harmonic saturation for analog warmth
 * - Texture: Vinyl crackle + pink noise for continuous ambience
 * - Dynamics: Side-chain compression (melody ducks on kick drum hits)
 * 
 * Reference: https://www.youtube.com/watch?v=vIsEwfTYB2Q
 */

class HypnoticAudioEngine {
  constructor() {
    this.audioContext = null;
    this.masterGain = null;

    // Binaural beat components
    this.oscillators = [];
    this.gainNodes = [];
    this.panners = [];

    // Lo-Fi processing chain
    this.lowPassFilter = null;
    this.warmthFilter = null;
    this.saturator = null;
    this.compressor = null;

    // Lo-Fi texture generators
    this.vinylCrackle = null;
    this.pinkNoise = null;
    this.rhythmLayer = null;

    // Wow & Flutter (pitch modulation)
    this.wowLFO = null;
    this.flutterLFO = null;

    this.isPlaying = false;
    this.safetyTimer = null;
    this.currentFrequency = 0;
    this.currentVolume = 0;
    this.currentBPM = 80; // Default relaxed tempo

    // Carrier frequencies
    this.leftCarrier = 200;
    this.rightCarrier = 200;

    this.init();
  }

  init() {
    try {
      this.audioContext = new (window.AudioContext || window.webkitAudioContext)();

      // Create master gain
      this.masterGain = this.audioContext.createGain();
      this.masterGain.gain.value = 1.0;

      // Lo-Fi Processing Chain Setup
      this.setupLoFiChain();

      console.log('🎵 Lo-Fi Hypnotic Audio Engine initialized');
    } catch (error) {
      console.error('Failed to initialize audio context:', error);
    }
  }

  /**
   * Creates the Lo-Fi processing chain
   */
  setupLoFiChain() {
    // 1. Low-Pass Filter (cuts frequencies above 10kHz for "muffled" sound)
    this.lowPassFilter = this.audioContext.createBiquadFilter();
    this.lowPassFilter.type = 'lowpass';
    this.lowPassFilter.frequency.value = 10000; // 10kHz cutoff
    this.lowPassFilter.Q.value = 0.7; // Gentle slope

    // 2. Warmth Boost (200-500Hz peaking for analog warmth)
    this.warmthFilter = this.audioContext.createBiquadFilter();
    this.warmthFilter.type = 'peaking';
    this.warmthFilter.frequency.value = 350; // Center of low-mids
    this.warmthFilter.Q.value = 1.5;
    this.warmthFilter.gain.value = 4; // +4dB boost for warmth

    // 3. Harmonic Saturation (waveshaper for analog-style distortion)
    this.saturator = this.audioContext.createWaveShaper();
    this.saturator.curve = this.createSaturationCurve();
    this.saturator.oversample = '4x'; // Reduce aliasing

    // 4. Compressor (side-chain style for rhythmic pumping)
    this.compressor = this.audioContext.createDynamicsCompressor();
    this.compressor.threshold.value = -24; // Engage at -24dB
    this.compressor.knee.value = 30; // Soft knee
    this.compressor.ratio.value = 12; // Heavy compression
    this.compressor.attack.value = 0.003; // Fast attack
    this.compressor.release.value = 0.25; // 250ms release (pumping effect)

    // Chain: saturator → warmth → lowpass → compressor → master
    this.saturator.connect(this.warmthFilter);
    this.warmthFilter.connect(this.lowPassFilter);
    this.lowPassFilter.connect(this.compressor);
    this.compressor.connect(this.masterGain);
    this.masterGain.connect(this.audioContext.destination);
  }

  /**
   * Creates saturation curve for analog warmth
   */
  createSaturationCurve() {
    const samples = 4096;
    const curve = new Float32Array(samples);
    const deg = Math.PI / 180;

    for (let i = 0; i < samples; i++) {
      const x = (i * 2) / samples - 1;
      // Soft-clipping algorithm for tape-like saturation
      curve[i] = (3 + 0.2) * x * 20 * deg / (Math.PI + 0.2 * Math.abs(x));
    }

    return curve;
  }

  /**
   * Starts a hypnotic session with Lo-Fi aesthetics
   */
  startSession(beatFrequency, volume, durationMs, bpm = 80) {
    if (!this.audioContext) {
      console.error('Audio context not initialized');
      return;
    }

    if (this.audioContext.state === 'suspended') {
      this.audioContext.resume();
    }

    this.stop();
    this.currentFrequency = beatFrequency;
    this.currentVolume = volume;
    this.currentBPM = Math.max(70, Math.min(bpm, 90)); // Clamp to 70-90 BPM

    // Create binaural beat with Lo-Fi processing
    this.createLoFiBinauralBeat(beatFrequency, volume);

    // Add vinyl crackle texture
    this.createVinylCrackle(volume * 0.08);

    // Add pink noise  ambience
    this.createPinkNoise(volume * 0.12);

    // Add subtle rhythm layer (Lo-Fi hip hop feel)
    this.createRhythmLayer(this.currentBPM, volume * 0.15);

    // Apply Wow & Flutter (tape warping)
    this.applyWowAndFlutter();

    this.isPlaying = true;
    console.log(`🧘 Lo-Fi session: ${beatFrequency} Hz at ${this.currentBPM} BPM`);
  }

  /**
   * Creates binaural beat routed through Lo-Fi chain
   */
  createLoFiBinauralBeat(beatFrequency, volume) {
    // Left ear (panned left)
    const leftOsc = this.audioContext.createOscillator();
    const leftGain = this.audioContext.createGain();
    const leftPanner = this.audioContext.createStereoPanner();

    leftOsc.frequency.value = this.leftCarrier;
    leftOsc.type = 'sine';
    leftGain.gain.value = volume * 0.8; // Slightly reduced for warmth
    leftPanner.pan.value = -0.8; // Not fully panned for Lo-Fi width

    leftOsc.connect(leftGain);
    leftGain.connect(leftPanner);
    leftPanner.connect(this.saturator); // Route through Lo-Fi chain
    leftOsc.start();

    this.oscillators.push(leftOsc);
    this.gainNodes.push(leftGain);
    this.panners.push(leftPanner);

    // Right ear (panned right, offset for binaural effect)
    const rightOsc = this.audioContext.createOscillator();
    const rightGain = this.audioContext.createGain();
    const rightPanner = this.audioContext.createStereoPanner();

    rightOsc.frequency.value = this.leftCarrier + beatFrequency;
    rightOsc.type = 'sine';
    rightGain.gain.value = volume * 0.8;
    rightPanner.pan.value = 0.8;

    rightOsc.connect(rightGain);
    rightGain.connect(rightPanner);
    rightPanner.connect(this.saturator); // Route through Lo-Fi chain
    rightOsc.start();

    this.oscillators.push(rightOsc);
    this.gainNodes.push(rightGain);
    this.panners.push(rightPanner);
  }

  /**
   * Creates vinyl crackle texture (continuous noise floor)
   */
  createVinylCrackle(volume) {
    const bufferSize = 4096;
    this.vinylCrackle = this.audioContext.createScriptProcessor(bufferSize, 1, 1);
    const gainNode = this.audioContext.createGain();

    gainNode.gain.value = volume;

    this.vinylCrackle.onaudioprocess = function (e) {
      const output = e.outputBuffer.getChannelData(0);
      for (let i = 0; i < bufferSize; i++) {
        // Poisson-distributed noise for vinyl crackle
        const rand = Math.random();
        if (rand > 0.995) {
          output[i] = (Math.random() * 2 - 1) * 0.4; // Sharp crackles
        } else {
          output[i] = (Math.random() * 2 - 1) * 0.05; // Gentle hiss
        }
      }
    };

    this.vinylCrackle.connect(gainNode);
    gainNode.connect(this.masterGain); // Bypass Lo-Fi chain for crackle
    this.gainNodes.push(gainNode);
  }

  /**
   * Creates pink noise layer (fills stereo field)
   */
  createPinkNoise(volume) {
    const bufferSize = 4096;
    this.pinkNoise = this.audioContext.createScriptProcessor(bufferSize, 1, 1);
    const gainNode = this.audioContext.createGain();

    let b0, b1, b2, b3, b4, b5, b6;
    b0 = b1 = b2 = b3 = b4 = b5 = b6 = 0.0;

    this.pinkNoise.onaudioprocess = function (e) {
      const output = e.outputBuffer.getChannelData(0);
      for (let i = 0; i < bufferSize; i++) {
        const white = Math.random() * 2 - 1;
        b0 = 0.99886 * b0 + white * 0.0555179;
        b1 = 0.99332 * b1 + white * 0.0750759;
        b2 = 0.96900 * b2 + white * 0.1538520;
        b3 = 0.86650 * b3 + white * 0.3104856;
        b4 = 0.55000 * b4 + white * 0.5329522;
        b5 = -0.7616 * b5 - white * 0.0168980;
        output[i] = b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362;
        output[i] *= 0.11;
        b6 = white * 0.115926;
      }
    };

    gainNode.gain.value = volume;
    this.pinkNoise.connect(gainNode);
    gainNode.connect(this.saturator); // Route through Lo-Fi chain
    this.gainNodes.push(gainNode);
  }

  /**
   * Creates unquantized rhythm layer (70-90 BPM Lo-Fi hip hop feel)
   */
  createRhythmLayer(bpm, volume) {
    const beatInterval = (60 / bpm) * 1000; // ms per beat
    const gainNode = this.audioContext.createGain();
    gainNode.gain.value = volume;
    gainNode.connect(this.compressor); // Triggers side-chain pumping

    const kickOsc = this.audioContext.createOscillator();
    const kickGain = this.audioContext.createGain();
    const kickFilter = this.audioContext.createBiquadFilter();

    kickOsc.type = 'sine';
    kickOsc.frequency.value = 60; // Deep kick
    kickFilter.type = 'lowpass';
    kickFilter.frequency.value = 120;

    kickOsc.connect(kickFilter);
    kickFilter.connect(kickGain);
    kickGain.connect(gainNode);
    kickOsc.start();

    // Trigger kick drum with unquantized timing (swing feel)
    const triggerKick = () => {
      if (!this.isPlaying) return;

      const now = this.audioContext.currentTime;
      const swing = (Math.random() - 0.5) * 0.03; // ±30ms deviation (drunken feel)

      // Kick envelope
      kickGain.gain.cancelScheduledValues(now);
      kickGain.gain.setValueAtTime(volume * 1.2, now);
      kickGain.gain.exponentialRampToValueAtTime(0.001, now + 0.3);

      setTimeout(() => triggerKick(), beatInterval + (swing * 1000));
    };

    triggerKick();
    this.oscillators.push(kickOsc);
  }

  /**
   * Applies Wow & Flutter (tape pitch modulation)
   */
  applyWowAndFlutter() {
    // Wow: Slow pitch drift (0.5-2 Hz)
    this.wowLFO = this.audioContext.createOscillator();
    const wowGain = this.audioContext.createGain();

    this.wowLFO.frequency.value = 0.8; // 0.8 Hz drift
    this.wowLFO.type = 'sine';
    wowGain.gain.value = 1.5; // ±1.5 Hz wobble

    this.wowLFO.connect(wowGain);

    // Apply to binaural oscillators
    if (this.oscillators.length >= 2) {
      wowGain.connect(this.oscillators[0].detune); // Left ear
      wowGain.connect(this.oscillators[1].detune); // Right ear
    }

    this.wowLFO.start();

    // Flutter: Fast pitch instability (5-10 Hz)
    this.flutterLFO = this.audioContext.createOscillator();
    const flutterGain = this.audioContext.createGain();

    this.flutterLFO.frequency.value = 7; // 7 Hz flutter
    this.flutterLFO.type = 'triangle';
    flutterGain.gain.value = 0.3; // ±0.3 Hz flutter

    this.flutterLFO.connect(flutterGain);

    if (this.oscillators.length >= 2) {
      flutterGain.connect(this.oscillators[0].detune);
      flutterGain.connect(this.oscillators[1].detune);
    }

    this.flutterLFO.start();
  }

  /**
   * Smoothly transition to new frequency (maintains Lo-Fi processing)
   */
  transitionToFrequency(newFrequency, transitionDurationMs) {
    if (!this.isPlaying || this.oscillators.length < 2) return;

    const transitionTime = this.audioContext.currentTime + (transitionDurationMs / 1000);
    const rightOsc = this.oscillators[1];

    rightOsc.frequency.linearRampToValueAtTime(
      this.leftCarrier + newFrequency,
      transitionTime
    );

    this.currentFrequency = newFrequency;
    console.log(`🎵 Transitioning to ${newFrequency} Hz (Lo-Fi)`);
  }

  setVolume(newVolume) {
    const rampTime = this.audioContext.currentTime + 0.5;

    this.gainNodes.forEach(gainNode => {
      gainNode.gain.linearRampToValueAtTime(newVolume * 0.8, rampTime);
    });

    this.currentVolume = newVolume;
  }

  enableSafetyTimer(maxMinutes) {
    this.clearSafetyTimer();
    const maxDuration = maxMinutes * 60 * 1000;

    this.safetyTimer = setTimeout(() => {
      console.warn('⚠️ Safety timer triggered - fading Lo-Fi session...');
      this.safetyFadeOut();
    }, maxDuration);

    console.log(`🛡️ Safety timer: ${maxMinutes} minutes`);
  }

  safetyFadeOut() {
    const fadeDuration = 30;
    const fadeSteps = 30;
    const stepInterval = 1000;
    let currentStep = 0;

    const fadeInterval = setInterval(() => {
      const volume = (fadeSteps - currentStep) / fadeSteps * this.currentVolume;
      this.setVolume(volume);

      currentStep++;
      if (currentStep >= fadeSteps) {
        clearInterval(fadeInterval);
        this.stop();
        console.log('✅ Lo-Fi session ended safely');
      }
    }, stepInterval);
  }

  clearSafetyTimer() {
    if (this.safetyTimer) {
      clearTimeout(this.safetyTimer);
      this.safetyTimer = null;
    }
  }

  stop() {
    this.clearSafetyTimer();

    this.oscillators.forEach(osc => {
      try {
        osc.stop();
      } catch (e) { }
    });

    if (this.vinylCrackle) this.vinylCrackle.disconnect();
    if (this.pinkNoise) this.pinkNoise.disconnect();
    if (this.wowLFO) this.wowLFO.stop();
    if (this.flutterLFO) this.flutterLFO.stop();

    this.oscillators = [];
    this.gainNodes = [];
    this.panners = [];
    this.isPlaying = false;
    this.currentFrequency = 0;

    console.log('🛑 Lo-Fi session stopped');
  }

  pause() {
    if (this.audioContext && this.audioContext.state === 'running') {
      this.audioContext.suspend();
      console.log('⏸️ Lo-Fi session paused');
    }
  }

  resume() {
    if (this.audioContext && this.audioContext.state === 'suspended') {
      this.audioContext.resume();
      console.log('▶️ Lo-Fi session resumed');
    }
  }

  getIsPlaying() {
    return this.isPlaying;
  }

  dispose() {
    this.stop();
    if (this.audioContext) {
      this.audioContext.close();
      this.audioContext = null;
    }
    console.log('🗑️ Lo-Fi Audio engine disposed');
  }

  // ===========================================================================
  // AI MUSIC GENERATOR INTEGRATION - MULTI-LAYER FREQUENCIES
  // ===========================================================================

  /**
   * Creates a multi-layer frequency session with multiple binaural beats
   * @param {Array} frequencyLayers - Array of {frequency, volume, pan} objects
   * @param {Object} options - Session options {bpm, includeLoFi, includeRhythm}
   */
  createMultiLayerSession(frequencyLayers, options = {}) {
    if (!this.audioContext || this.audioContext.state === 'suspended') {
      this.audioContext?.resume();
    }

    this.stop();

    const { bpm = 80, includeLoFi = true, includeRhythm = true } = options;
    this.currentBPM = Math.max(60, Math.min(bpm, 100));

    // Create each frequency layer
    frequencyLayers.forEach((layer, index) => {
      this.createBinauralLayer(layer.frequency, layer.volume || 0.5, layer.pan || 0);
    });

    // Add Lo-Fi textures if enabled
    if (includeLoFi) {
      this.createVinylCrackle(0.06);
      this.createPinkNoise(0.08);
    }

    // Add rhythm layer
    if (includeRhythm) {
      this.createRhythmLayer(this.currentBPM, 0.12);
    }

    this.applyWowAndFlutter();
    this.isPlaying = true;

    console.log(`🎵 Multi-layer session: ${frequencyLayers.length} frequencies at ${this.currentBPM} BPM`);
  }

  /**
   * Creates a single binaural beat layer
   */
  createBinauralLayer(beatFrequency, volume, panPosition = 0) {
    const carrierFreq = 200 + (Math.random() * 50); // Slight variation for richness

    // Left oscillator
    const leftOsc = this.audioContext.createOscillator();
    const leftGain = this.audioContext.createGain();
    const leftPanner = this.audioContext.createStereoPanner();

    leftOsc.frequency.value = carrierFreq;
    leftOsc.type = 'sine';
    leftGain.gain.value = volume * 0.6;
    leftPanner.pan.value = Math.max(-1, panPosition - 0.4);

    leftOsc.connect(leftGain);
    leftGain.connect(leftPanner);
    leftPanner.connect(this.saturator);
    leftOsc.start();

    // Right oscillator (offset by beat frequency)
    const rightOsc = this.audioContext.createOscillator();
    const rightGain = this.audioContext.createGain();
    const rightPanner = this.audioContext.createStereoPanner();

    rightOsc.frequency.value = carrierFreq + beatFrequency;
    rightOsc.type = 'sine';
    rightGain.gain.value = volume * 0.6;
    rightPanner.pan.value = Math.min(1, panPosition + 0.4);

    rightOsc.connect(rightGain);
    rightGain.connect(rightPanner);
    rightPanner.connect(this.saturator);
    rightOsc.start();

    this.oscillators.push(leftOsc, rightOsc);
    this.gainNodes.push(leftGain, rightGain);
    this.panners.push(leftPanner, rightPanner);
  }

  // ===========================================================================
  // HARMONIC GENERATION (Majineo-style)
  // ===========================================================================

  /**
   * Generates harmonics based on a fundamental frequency
   * Uses musical ratios for pleasant overtones
   */
  generateHarmonics(baseFrequency, harmonicRatios = [1, 1.5, 2, 2.5, 3], volume = 0.4) {
    const harmonicGains = [1.0, 0.6, 0.4, 0.25, 0.15]; // Decreasing volume for higher harmonics

    harmonicRatios.forEach((ratio, index) => {
      const freq = baseFrequency * ratio;
      const oscVolume = volume * (harmonicGains[index] || 0.1);

      const osc = this.audioContext.createOscillator();
      const gain = this.audioContext.createGain();
      const filter = this.audioContext.createBiquadFilter();

      // Soften higher harmonics
      osc.frequency.value = freq;
      osc.type = index === 0 ? 'sine' : 'triangle';
      gain.gain.value = oscVolume;

      filter.type = 'lowpass';
      filter.frequency.value = 2000 + (1000 / (index + 1));

      osc.connect(filter);
      filter.connect(gain);
      gain.connect(this.saturator);
      osc.start();

      this.oscillators.push(osc);
      this.gainNodes.push(gain);
    });

    console.log(`🎼 Generated ${harmonicRatios.length} harmonics from ${baseFrequency} Hz`);
  }

  // ===========================================================================
  // ENTRAINMENT SEQUENCES (Protocol playback)
  // ===========================================================================

  /**
   * Applies an entrainment sequence (frequency changes over time)
   * @param {Array} sequence - Array of {frequency, durationMs} objects
   * @param {Function} onStepChange - Callback when moving to next step
   */
  applyEntrainmentSequence(sequence, onStepChange = null) {
    if (!sequence || sequence.length === 0) return;

    let currentStepIndex = 0;
    let elapsedInStep = 0;

    const processStep = () => {
      if (currentStepIndex >= sequence.length) {
        console.log('✅ Entrainment sequence complete');
        return;
      }

      const step = sequence[currentStepIndex];

      // Transition to new frequency
      this.transitionToFrequency(step.frequency, 5000); // 5s transition

      if (onStepChange) {
        onStepChange(currentStepIndex, step);
      }

      console.log(`🔄 Entrainment step ${currentStepIndex + 1}/${sequence.length}: ${step.frequency} Hz`);

      // Schedule next step
      setTimeout(() => {
        currentStepIndex++;
        processStep();
      }, step.durationMs);
    };

    processStep();
  }

  // ===========================================================================
  // CHAKRA ALIGNMENT (Pure tones)
  // ===========================================================================

  /**
   * Creates chakra alignment session with specific frequencies
   * Root (256) → Sacral (288) → Solar Plexus (320) → Heart (341) → 
   * Throat (384) → Third Eye (448) → Crown (480)
   */
  createChakraAlignment(chakraSequence = null, durationPerChakraMs = 240000) {
    const defaultChakras = [
      { name: 'Root', frequency: 256, color: '#FF0000' },
      { name: 'Sacral', frequency: 288, color: '#FF8C00' },
      { name: 'Solar Plexus', frequency: 320, color: '#FFFF00' },
      { name: 'Heart', frequency: 341, color: '#00FF00' },
      { name: 'Throat', frequency: 384, color: '#00BFFF' },
      { name: 'Third Eye', frequency: 448, color: '#4B0082' },
      { name: 'Crown', frequency: 480, color: '#8B00FF' },
    ];

    const chakras = chakraSequence || defaultChakras;
    const sequence = chakras.map(c => ({
      frequency: c.frequency,
      durationMs: durationPerChakraMs,
      name: c.name,
    }));

    // Start with first chakra
    this.stop();
    this.createPureTone(chakras[0].frequency, 0.5);
    this.isPlaying = true;

    console.log(`🧘 Chakra alignment: ${chakras.length} chakras, ${durationPerChakraMs / 60000} min each`);

    // Apply sequence
    this.applyEntrainmentSequence(sequence, (index, step) => {
      this.createPureTone(step.frequency, 0.5);
      console.log(`✨ ${step.name} Chakra (${step.frequency} Hz)`);
    });
  }

  /**
   * Creates a pure tone (for chakra work - bypasses Lo-Fi chain)
   */
  createPureTone(frequency, volume) {
    const osc = this.audioContext.createOscillator();
    const gain = this.audioContext.createGain();

    osc.frequency.value = frequency;
    osc.type = 'sine';
    gain.gain.value = volume;

    osc.connect(gain);
    gain.connect(this.masterGain); // Bypass Lo-Fi for purity
    osc.start();

    this.oscillators.push(osc);
    this.gainNodes.push(gain);
  }

  // ===========================================================================
  // MELODIC PATTERN GENERATION (Majineo-style Lo-Fi)
  // ===========================================================================

  /**
   * Generates ambient melodic patterns using pentatonic scale
   * Creates that dreamy Majineo-style Lo-Fi feel
   */
  generateMelodicLayer(rootNote = 220, volume = 0.15) {
    // Pentatonic scale intervals (calming, no dissonance)
    const pentatonic = [0, 2, 4, 7, 9, 12, 14, 16]; // Semitones
    const noteFrequencies = pentatonic.map(semitone =>
      rootNote * Math.pow(2, semitone / 12)
    );

    // Create ambient pad
    const padOsc = this.audioContext.createOscillator();
    const padGain = this.audioContext.createGain();
    const padFilter = this.audioContext.createBiquadFilter();

    padOsc.type = 'triangle';
    padOsc.frequency.value = rootNote;
    padGain.gain.value = volume * 0.5;
    padFilter.type = 'lowpass';
    padFilter.frequency.value = 800;
    padFilter.Q.value = 2;

    padOsc.connect(padFilter);
    padFilter.connect(padGain);
    padGain.connect(this.saturator);
    padOsc.start();

    this.oscillators.push(padOsc);
    this.gainNodes.push(padGain);

    // Create arpeggio pattern with unquantized timing
    const arpOsc = this.audioContext.createOscillator();
    const arpGain = this.audioContext.createGain();
    const arpFilter = this.audioContext.createBiquadFilter();

    arpOsc.type = 'sine';
    arpOsc.frequency.value = noteFrequencies[0];
    arpGain.gain.value = 0;
    arpFilter.type = 'lowpass';
    arpFilter.frequency.value = 1200;

    arpOsc.connect(arpFilter);
    arpFilter.connect(arpGain);
    arpGain.connect(this.saturator);
    arpOsc.start();

    this.oscillators.push(arpOsc);
    this.gainNodes.push(arpGain);

    // Arpeggio playback (unquantized for Lo-Fi feel)
    let noteIndex = 0;
    const beatInterval = (60 / this.currentBPM) * 1000;

    const playArpNote = () => {
      if (!this.isPlaying) return;

      const swing = (Math.random() - 0.5) * 80; // ±40ms humanization
      const freq = noteFrequencies[noteIndex % noteFrequencies.length];
      const now = this.audioContext.currentTime;

      // Note envelope
      arpOsc.frequency.setValueAtTime(freq, now);
      arpGain.gain.cancelScheduledValues(now);
      arpGain.gain.setValueAtTime(0, now);
      arpGain.gain.linearRampToValueAtTime(volume, now + 0.05);
      arpGain.gain.exponentialRampToValueAtTime(0.001, now + 0.8);

      noteIndex++;

      // Random note selection (weighted towards consonant intervals)
      if (Math.random() > 0.7) {
        noteIndex = Math.floor(Math.random() * noteFrequencies.length);
      }

      setTimeout(playArpNote, beatInterval + swing);
    };

    // Start after a beat
    setTimeout(playArpNote, beatInterval);

    console.log(`🎹 Melodic layer: Pentatonic from ${rootNote} Hz at ${this.currentBPM} BPM`);
  }

  // ===========================================================================
  // SOLFEGGIO FREQUENCIES
  // ===========================================================================

  /**
   * Plays Solfeggio healing frequencies
   */
  playSolfeggioFrequency(frequencyName, volume = 0.5) {
    const solfeggio = {
      'ut': 396,   // Liberation from fear
      're': 417,   // Undoing situations
      'mi': 528,   // DNA repair, transformation
      'fa': 639,   // Connection, relationships
      'sol': 741,  // Awakening intuition
      'la': 852,   // Spiritual order
    };

    const freq = solfeggio[frequencyName.toLowerCase()] || 528;

    this.stop();
    this.createPureTone(freq, volume);
    this.createPinkNoise(volume * 0.1);
    this.isPlaying = true;

    console.log(`🎵 Solfeggio: ${frequencyName.toUpperCase()} (${freq} Hz)`);
  }

  // ===========================================================================
  // SCHUMANN RESONANCE
  // ===========================================================================

  /**
   * Creates Schumann Resonance session for grounding
   * @param {number} harmonicIndex - Which Schumann harmonic (0-6)
   */
  playSchumannResonance(harmonicIndex = 0, volume = 0.6) {
    const schumannHarmonics = [7.83, 14, 20, 26, 33, 39, 45];
    const descriptions = [
      'Earth grounding, anti-stress',
      'Alertness, concentration',
      'Pineal stimulation',
      'Growth hormone release',
      'Higher consciousness',
      'Higher awareness',
      'Peak gamma binding',
    ];

    const freq = schumannHarmonics[harmonicIndex] || 7.83;

    this.stop();
    this.createLoFiBinauralBeat(freq, volume);
    this.createVinylCrackle(0.04);
    this.createPinkNoise(0.06);
    this.applyWowAndFlutter();
    this.isPlaying = true;

    console.log(`🌍 Schumann Resonance: ${freq} Hz - ${descriptions[harmonicIndex]}`);
  }

  // ===========================================================================
  // CHORD PROGRESSIONS (Lo-Fi hip hop style)
  // ===========================================================================

  /**
   * Plays Lo-Fi chord progression (Majineo-style)
   * Common progressions: ii-V-I, i-VI-III-VII
   */
  playLoFiChordProgression(progression = 'lofi', volume = 0.2) {
    const chordVoicings = {
      // Classic Lo-Fi minor progression (Am7 - Dm7 - G7 - Cmaj7)
      'lofi': [
        [220, 261.6, 329.6, 392],     // Am7
        [146.8, 174.6, 220, 261.6],   // Dm7
        [196, 246.9, 293.7, 349.2],   // G7
        [130.8, 164.8, 196, 246.9],   // Cmaj7
      ],
      // Jazz progression (Dm9 - G13 - Cmaj9)
      'jazz': [
        [146.8, 220, 261.6, 329.6, 392],
        [196, 246.9, 293.7, 370, 440],
        [130.8, 196, 246.9, 329.6, 392],
      ],
      // Ambient (Cmaj7 - Fmaj7)
      'ambient': [
        [130.8, 164.8, 196, 246.9],
        [174.6, 220, 261.6, 329.6],
      ],
    };

    const chords = chordVoicings[progression] || chordVoicings['lofi'];
    let chordIndex = 0;
    const beatInterval = (60 / this.currentBPM) * 4 * 1000; // 4 beats per chord

    const playChord = () => {
      if (!this.isPlaying) return;

      const chord = chords[chordIndex % chords.length];
      const now = this.audioContext.currentTime;

      chord.forEach((freq, i) => {
        const osc = this.audioContext.createOscillator();
        const gain = this.audioContext.createGain();

        osc.type = 'triangle';
        osc.frequency.value = freq;
        gain.gain.value = (volume / chord.length) * (1 - i * 0.15); // Lower for higher notes

        osc.connect(gain);
        gain.connect(this.saturator);

        // Soft attack, slow release
        gain.gain.setValueAtTime(0, now);
        gain.gain.linearRampToValueAtTime(gain.gain.value, now + 0.3);
        gain.gain.setValueAtTime(gain.gain.value, now + (beatInterval / 1000) - 0.5);
        gain.gain.exponentialRampToValueAtTime(0.001, now + (beatInterval / 1000));

        osc.start(now);
        osc.stop(now + (beatInterval / 1000) + 0.1);
      });

      chordIndex++;
      setTimeout(playChord, beatInterval);
    };

    playChord();
    console.log(`🎹 Lo-Fi chord progression: ${progression} style`);
  }
}

// Initialize global instance
window.hypnoticAudioEngine = new HypnoticAudioEngine();

console.log('✅ Lo-Fi Hypnotic Audio Engine loaded (Majineo-style) 🎧');
