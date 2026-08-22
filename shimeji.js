let pets = [];
let batterySaver = false;
let isIdle = false;
let soundVolume = 50;
let soundEnabled = true;

// Static backup of character configurations
const CHARACTERS = {
  maxie: { id: "maxie", name: "MAXie", displayName: "MAXie", personality: "Friendly", theme: "aurora" },
  mimi: { id: "mimi", name: "Mimi", displayName: "Mimi", personality: "Playful", theme: "candy" },
  kuro: { id: "kuro", name: "Kuro", displayName: "Kuro", personality: "Lazy", theme: "mono" },
  luna: { id: "luna", name: "Luna", displayName: "Luna", personality: "Curious", theme: "aurora" },
  nova: { id: "nova", name: "Nova", displayName: "Nova", personality: "Energetic", theme: "candy" }
};

class PetInstance {
  constructor(id, state) {
    this.id = id;
    this.config = CHARACTERS[id] || CHARACTERS.maxie;
    this.state = state || {};
    this.size = Number(state.size) || 100;
    this.speed = Number(state.speed) || 1.0;
    this.opacity = Number(state.opacity) || 1.0;
    this.hasSprites = false;

    // Create DOM element
    this.el = document.createElement('div');
    this.el.className = `pet char-${id} state-idle`;
    this.el.style.setProperty('--pet-size', `${this.size}px`);
    this.el.style.opacity = this.opacity;

    // Custom sprite element
    this.spriteEl = document.createElement('div');
    this.spriteEl.className = 'sprite-image';
    this.el.appendChild(this.spriteEl);

    // Programmatic elements (Ears, Face, Eyes, Mouth, Legs)
    this.bodyEl = document.createElement('div');
    this.bodyEl.className = 'body';

    const earL = document.createElement('div');
    earL.className = 'ear left';
    const earR = document.createElement('div');
    earR.className = 'ear right';

    const shadow = document.createElement('div');
    shadow.className = 'shadow';

    const face = document.createElement('div');
    face.className = 'face';
    const eyeL = document.createElement('div');
    eyeL.className = 'eye left';
    const eyeR = document.createElement('div');
    eyeR.className = 'eye right';
    const mouth = document.createElement('div');
    mouth.className = 'mouth';
    const blushL = document.createElement('div');
    blushL.className = 'blush left';
    const blushR = document.createElement('div');
    blushR.className = 'blush right';
    face.append(eyeL, eyeR, mouth, blushL, blushR);

    const armL = document.createElement('div');
    armL.className = 'arm left';
    const armR = document.createElement('div');
    armR.className = 'arm right';

    const legL = document.createElement('div');
    legL.className = 'leg left';
    const legR = document.createElement('div');
    legR.className = 'leg right';

    this.bodyEl.append(earL, earR, face, armL, armR, legL, legR);
    this.el.append(this.bodyEl, shadow);

    // Reaction badge
    this.propEl = document.createElement('div');
    this.propEl.className = 'reaction-prop';
    this.el.appendChild(this.propEl);

    // Speech bubble
    this.bubbleEl = document.createElement('div');
    this.bubbleEl.className = 'speech-bubble';
    this.bubbleEl.style.display = 'none';
    this.el.appendChild(this.bubbleEl);

    const container = document.getElementById('shimejiContainer') || document.getElementById('inAppShimejiContainer');
    if (container) {
      container.appendChild(this.el);
    }

    // Set Up Engines
    const startX = Math.random() * (window.innerWidth - this.size);
    const startY = window.innerHeight - this.size;

    this.physics = new window.PetPhysics({ x: startX, y: startY });
    this.physics.setFloor(window.innerHeight - this.size);
    this.physics.setSpeed(this.speed);
    this.physics.gravity = 0.65;
    this.physics.damping = 0.85;
    this.physics.bounce = 0.28;

    this.brain = new window.PetBrain();
    this.brain.hydrate({
      needs: { energy: 85, fun: 80, hunger: 20 },
      personality: { friendship: state.friendship || 5, xp: state.xp || 750 }
    });

    this.currentAnimation = 'idle';
    this.dragging = false;
    this.lastTouch = { x: 0, y: 0 };
    this.touchStartTime = 0;
    this.lastDragPos = { x: startX, y: startY, t: Date.now() };
    this.dragVel = { x: 0, y: 0 };
    this.behaviorTimer = null;
    this.bubbleTimer = null;
    this.nextInteractionTime = Date.now() + 10000;

    this.setupTouchInteractions();
    this.checkCustomSprites();
    this.scheduleNextBehavior();
  }

  async checkCustomSprites() {
    const exists = await this.checkAsset(`assets/pets/${this.id}/idle.gif`);
    if (exists) {
      this.hasSprites = true;
      this.el.classList.add('has-sprite');
      this.updateSprite();
    }
  }

  checkAsset(url) {
    return new Promise((resolve) => {
      const img = new Image();
      img.onload = () => resolve(true);
      img.onerror = () => resolve(false);
      img.src = url;
    });
  }

  updateSprite() {
    if (!this.hasSprites) return;
    this.spriteEl.style.backgroundImage = `url("assets/pets/${this.id}/${this.currentAnimation}.gif")`;
  }

  setAnimation(name) {
    if (this.currentAnimation === name) return;
    this.currentAnimation = name;
    
    // Clear animation classes
    const list = ['idle', 'walk', 'run', 'jump', 'fall', 'land', 'sit', 'sleep', 'wake', 'dance', 'happy', 'sad', 'angry', 'surprised', 'love', 'hungry', 'bored', 'excited', 'eat', 'listen', 'think', 'wave', 'drag', 'throw'];
    list.forEach(key => this.el.classList.remove(`state-${key}`));
    
    this.el.classList.add(`state-${name}`);
    this.updateSprite();
  }

  say(text) {
    if (!text) return;
    this.bubbleEl.textContent = text;
    this.bubbleEl.style.display = 'block';
    clearTimeout(this.bubbleTimer);
    this.bubbleTimer = setTimeout(() => {
      this.bubbleEl.style.display = 'none';
    }, 3800);
  }

  setupTouchInteractions() {
    const handleStart = (e) => {
      const touch = e.touches ? e.touches[0] : e;
      this.dragging = true;
      this.physics.velocity = { x: 0, y: 0 };
      this.setAnimation('drag');
      this.lastTouch = { x: touch.clientX, y: touch.clientY };
      this.touchStartTime = Date.now();
      this.lastDragPos = { x: this.physics.position.x, y: this.physics.position.y, t: Date.now() };
      this.dragVel = { x: 0, y: 0 };
      
      window.ShimejiSound.play('tap');
      e.preventDefault();
    };

    const handleMove = (e) => {
      if (!this.dragging) return;
      const touch = e.touches ? e.touches[0] : e;
      const dx = touch.clientX - this.lastTouch.x;
      const dy = touch.clientY - this.lastTouch.y;

      this.physics.position.x += dx;
      this.physics.position.y += dy;

      // Keep inside screen
      this.physics.position.x = Math.max(0, Math.min(window.innerWidth - this.size, this.physics.position.x));
      this.physics.position.y = Math.max(0, Math.min(window.innerHeight - this.size, this.physics.position.y));

      const now = Date.now();
      const dt = now - this.lastDragPos.t;
      if (dt > 10) {
        this.dragVel.x = (this.physics.position.x - this.lastDragPos.x) / dt * 15;
        this.dragVel.y = (this.physics.position.y - this.lastDragPos.y) / dt * 15;
        this.lastDragPos = { x: this.physics.position.x, y: this.physics.position.y, t: now };
      }

      this.lastTouch = { x: touch.clientX, y: touch.clientY };
      e.preventDefault();
    };

    const handleEnd = (e) => {
      if (!this.dragging) return;
      this.dragging = false;

      const duration = Date.now() - this.touchStartTime;
      const speed = Math.hypot(this.dragVel.x, this.dragVel.y);

      if (speed > 3) {
        // Throw pet!
        this.physics.velocity.x = this.dragVel.x;
        this.physics.velocity.y = this.dragVel.y;
        this.setAnimation('throw');
        window.ShimejiSound.play('jump');
      } else if (duration < 250) {
        // Simple tap reaction
        this.reactToTap();
      } else {
        this.setAnimation('fall');
      }
      this.scheduleNextBehavior();
    };

    this.el.addEventListener('touchstart', handleStart, { passive: false });
    this.el.addEventListener('touchmove', handleMove, { passive: false });
    this.el.addEventListener('touchend', handleEnd);

    // Double tap listener
    let lastTap = 0;
    this.el.addEventListener('touchend', (e) => {
      const now = Date.now();
      if (now - lastTap < 300) {
        this.triggerDoubleTap();
      }
      lastTap = now;
    });
  }

  reactToTap() {
    const reactions = ['happy', 'surprised', 'love', 'wave', 'jump', 'excited'];
    const selected = reactions[Math.floor(Math.random() * reactions.length)];
    this.setAnimation(selected);
    window.ShimejiSound.play('happy');
    
    // XP gain for interaction
    if (typeof AndroidShimeji !== 'undefined' && AndroidShimeji.saveState) {
      this.state.xp = (this.state.xp || 750) + 10;
      this.state.friendship = Math.floor(this.state.xp / 150) + 1;
      this.say("Thanks! Friendship +10 XP");
      saveGlobalState();
    }
  }

  triggerDoubleTap() {
    this.setAnimation('dance');
    this.say("Let's dance!");
    window.ShimejiSound.play('happy');
  }

  scheduleNextBehavior() {
    clearTimeout(this.behaviorTimer);
    if (this.dragging) return;
    
    const delay = 3000 + Math.random() * 6000;
    this.behaviorTimer = setTimeout(() => {
      this.performBehavior();
      this.scheduleNextBehavior();
    }, delay);
  }

  performBehavior() {
    if (this.dragging || this.physics.position.y < this.physics.floorY) return;

    const res = this.brain.pickIdleBehavior();
    const anim = res.animation || 'idle';
    this.setAnimation(anim);
    if (res.line) this.say(res.line);

    // Choose movement target
    if (anim === 'walk' || anim === 'run') {
      const targetX = Math.random() * (window.innerWidth - this.size);
      this.physics.setTarget(targetX, this.physics.floorY);
    } else if (anim === 'jump') {
      this.physics.velocity.y = -10 - Math.random() * 8;
      window.ShimejiSound.play('jump');
    }
  }

  tick() {
    // Ground detection and floor update in case of resizing
    const currentFloor = window.innerHeight - this.size;
    this.physics.setFloor(currentFloor);

    if (this.dragging) {
      this.el.style.left = `${this.physics.position.x}px`;
      this.el.style.top = `${this.physics.position.y}px`;
      return;
    }

    // Physics Step
    // 1. Airborne gravity & trajectory
    if (this.physics.position.y < this.physics.floorY) {
      this.physics.velocity.y += this.physics.gravity;
      this.physics.position.x += this.physics.velocity.x;
      this.physics.position.y += this.physics.velocity.y;
      this.physics.velocity.x *= 0.98;

      // Wall bounds collision bounce
      if (this.physics.position.x <= 0) {
        this.physics.position.x = 0;
        this.physics.velocity.x = Math.abs(this.physics.velocity.x) * 0.5;
      } else if (this.physics.position.x >= window.innerWidth - this.size) {
        this.physics.position.x = window.innerWidth - this.size;
        this.physics.velocity.x = -Math.abs(this.physics.velocity.x) * 0.5;
      }

      // Land collision
      if (this.physics.position.y >= this.physics.floorY) {
        this.physics.position.y = this.physics.floorY;
        if (Math.abs(this.physics.velocity.y) > 2) {
          this.physics.velocity.y = -this.physics.velocity.y * this.physics.bounce;
          this.setAnimation('land');
          window.ShimejiSound.play('land');
        } else {
          this.physics.velocity.y = 0;
          this.physics.velocity.x = 0;
          this.setAnimation('idle');
        }
      } else {
        if (this.physics.velocity.y > 1) {
          this.setAnimation('fall');
        }
      }
    } else {
      // 2. Ground walking & target-seeking
      const beforeX = this.physics.position.x;
      const targetState = this.physics.step();
      
      const velocityX = targetState.x - beforeX;
      if (Math.abs(velocityX) > 0.05) {
        this.setAnimation(this.currentAnimation === 'run' ? 'run' : 'walk');
        // Mirror CSS facing direction
        this.el.style.transform = velocityX < 0 ? 'scaleX(-1)' : 'scaleX(1)';
      } else {
        if (this.currentAnimation === 'walk' || this.currentAnimation === 'run') {
          this.setAnimation('idle');
        }
      }
    }

    // Set DOM Styles
    this.el.style.left = `${this.physics.position.x}px`;
    this.el.style.top = `${this.physics.position.y}px`;

    // Handle Pet to Pet Interaction
    this.checkPetInteractions();
  }

  checkPetInteractions() {
    if (Date.now() < this.nextInteractionTime || pets.length < 2) return;
    
    // Find closest pet
    pets.forEach(other => {
      if (other === this || other.dragging) return;
      const dx = other.physics.position.x - this.physics.position.x;
      const dist = Math.abs(dx);
      if (dist < 120) {
        // Trigger interaction
        this.nextInteractionTime = Date.now() + 18000;
        other.nextInteractionTime = Date.now() + 18000;
        
        this.physics.velocity.x = 0;
        this.physics.setTarget(this.physics.position.x, this.physics.position.y);
        other.physics.velocity.x = 0;
        other.physics.setTarget(other.physics.position.x, other.physics.position.y);

        this.setAnimation('wave');
        other.setAnimation('dance');

        this.say(`Hi ${other.config.displayName}!`);
        setTimeout(() => {
          this.setAnimation('idle');
          other.setAnimation('idle');
        }, 3000);
      }
    });
  }

  destroy() {
    clearTimeout(this.behaviorTimer);
    clearTimeout(this.bubbleTimer);
    this.el.remove();
  }
}

// Global state sync and initialization
function loadGlobalState() {
  let stateStr = "{}";
  if (typeof AndroidShimeji !== 'undefined' && AndroidShimeji.loadState) {
    stateStr = AndroidShimeji.loadState();
  } else {
    stateStr = localStorage.getItem('maxie-shimeji-overlay-state') || "{}";
  }

  try {
    const globalState = JSON.parse(stateStr);
    batterySaver = !!globalState.batterySaver;
    soundEnabled = globalState.soundEnabled !== false;
    soundVolume = Number(globalState.soundVolume) || 50;

    window.ShimejiSound.enabled = soundEnabled;
    window.ShimejiSound.volume = soundVolume / 100;

    // Despawn old pets
    pets.forEach(p => p.destroy());
    pets = [];

    // Spawn active pets
    const activeCompanions = globalState.activeCompanions || ['maxie'];
    activeCompanions.forEach(id => {
      const petState = globalState.pets ? globalState.pets.find(p => p.id === id) : {};
      pets.push(new PetInstance(id, {
        size: globalState.petSize || 100,
        speed: globalState.petSpeed || 1.0,
        opacity: globalState.petOpacity || 1.0,
        xp: petState ? petState.xp : 750,
        friendship: petState ? petState.friendship : 5
      }));
    });
  } catch (e) {
    console.error("Failed to parse global Shimeji state", e);
  }
}

function saveGlobalState() {
  const activeCompanions = pets.map(p => p.id);
  const petsState = pets.map(p => {
    return {
      id: p.id,
      xp: p.state.xp,
      friendship: p.state.friendship
    };
  });

  const stateObj = {
    batterySaver,
    soundEnabled,
    soundVolume,
    activeCompanions,
    pets: petsState
  };

  const jsonStr = JSON.stringify(stateObj);
  if (typeof AndroidShimeji !== 'undefined' && AndroidShimeji.saveState) {
    AndroidShimeji.saveState(jsonStr);
  } else {
    localStorage.setItem('maxie-shimeji-overlay-state', jsonStr);
  }
}

// Android Webview listener
window.onStateUpdated = function(stateJson) {
  if (stateJson) {
    let stateObj = typeof stateJson === 'string' ? JSON.parse(stateJson) : stateJson;
    batterySaver = !!stateObj.batterySaver;
    soundEnabled = stateObj.soundEnabled !== false;
    soundVolume = Number(stateObj.soundVolume) || 50;

    window.ShimejiSound.enabled = soundEnabled;
    window.ShimejiSound.volume = soundVolume / 100;

    // Check size updates
    pets.forEach(pet => {
      pet.size = Number(stateObj.petSize) || 100;
      pet.speed = Number(stateObj.petSpeed) || 1.0;
      pet.opacity = Number(stateObj.petOpacity) || 1.0;

      pet.el.style.setProperty('--pet-size', `${pet.size}px`);
      pet.el.style.opacity = pet.opacity;
      pet.physics.setSpeed(pet.speed);
    });
    
    saveGlobalState();
  }
};

// Send coordinates of pets to Java overlay service
function updateRegions() {
  if (typeof AndroidShimeji !== 'undefined' && AndroidShimeji.updatePetRegions) {
    const regions = pets.map(p => {
      return {
        x: Math.round(p.physics.position.x),
        y: Math.round(p.physics.position.y),
        width: p.size,
        height: p.size
      };
    });
    AndroidShimeji.updatePetRegions(JSON.stringify(regions));
  }
}

// Frame Throttled Loop
let lastFrameTime = 0;
function runLoop(timestamp) {
  requestAnimationFrame(runLoop);

  // Set framerate dynamically based on state
  const fps = batterySaver ? 12 : (isIdle ? 15 : 45);
  const frameInterval = 1000 / fps;
  const elapsed = timestamp - lastFrameTime;

  if (elapsed < frameInterval) return;
  lastFrameTime = timestamp - (elapsed % frameInterval);

  pets.forEach(pet => pet.tick());
  updateRegions();
}

// Detect User Inactivity to throttle animation rate
let idleTimer;
function resetIdle() {
  isIdle = false;
  clearTimeout(idleTimer);
  idleTimer = setTimeout(() => {
    isIdle = true;
  }, 20000); // 20 seconds of no touch interaction sets pet to idle rate
}

window.addEventListener('touchstart', resetIdle);
resetIdle();

// Boot
window.addEventListener('DOMContentLoaded', () => {
  loadGlobalState();
  requestAnimationFrame(runLoop);
});
