let inAppPets = [];
let inAppLoopId = null;
let lastInAppFrameTime = 0;
let inAppIdle = false;
let inAppIdleTimer = null;

class InAppPetInstance {
  constructor(id, petState) {
    this.id = id;
    this.config = CHARACTERS[id] || CHARACTERS.maxie;
    this.state = petState;
    this.size = Number(state.shimeji?.petSize) || 90; // slightly smaller in-app to fit phone viewport
    this.speed = Number(state.shimeji?.petSpeed) || 1.0;
    this.opacity = Number(state.shimeji?.petOpacity) || 1.0;
    this.hasSprites = false;

    // Create DOM element
    this.el = document.createElement('div');
    this.el.className = `pet char-${id} state-idle`;
    this.el.style.setProperty('--pet-size', `${this.size}px`);
    this.el.style.opacity = this.opacity;

    // Sprite image
    this.spriteEl = document.createElement('div');
    this.spriteEl.className = 'sprite-image';
    this.el.appendChild(this.spriteEl);

    // Custom CSS drawing body
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

    const container = document.getElementById('inAppShimejiContainer');
    if (container) {
      container.appendChild(this.el);
    }

    // Physics
    const containerHeight = container ? container.clientHeight : window.innerHeight;
    const groundFloor = containerHeight - this.size;

    this.physics = new window.PetPhysics({
      x: Math.random() * ((container ? container.clientWidth : window.innerWidth) - this.size),
      y: groundFloor
    });
    this.physics.setFloor(groundFloor);
    this.physics.setSpeed(this.speed);
    this.physics.gravity = 0.65;
    this.physics.damping = 0.85;
    this.physics.bounce = 0.28;

    // Brain
    this.brain = new window.PetBrain();
    this.brain.hydrate({
      needs: { energy: 85, fun: 80, hunger: 20 },
      personality: { friendship: state.friendship || 5, xp: state.xp || 750 }
    });

    this.currentAnimation = 'idle';
    this.dragging = false;
    this.lastTouch = { x: 0, y: 0 };
    this.touchStartTime = 0;
    this.lastDragPos = { x: this.physics.position.x, y: this.physics.position.y, t: Date.now() };
    this.dragVel = { x: 0, y: 0 };
    this.behaviorTimer = null;
    this.bubbleTimer = null;
    this.nextInteractionTime = Date.now() + 10000;

    this.setupTouch();
    this.checkSprites();
    this.scheduleBehavior();
  }

  async checkSprites() {
    const imgPath = `assets/pets/${this.id}/idle.gif`;
    const check = new Image();
    check.onload = () => {
      this.hasSprites = true;
      this.el.classList.add('has-sprite');
      this.updateSpriteSrc();
    };
    check.src = imgPath;
  }

  updateSpriteSrc() {
    if (!this.hasSprites) return;
    this.spriteEl.style.backgroundImage = `url("assets/pets/${this.id}/${this.currentAnimation}.gif")`;
  }

  setAnimation(name) {
    if (this.currentAnimation === name) return;
    this.currentAnimation = name;

    const list = ['idle', 'walk', 'run', 'jump', 'fall', 'land', 'sit', 'sleep', 'wake', 'dance', 'happy', 'sad', 'angry', 'surprised', 'love', 'hungry', 'bored', 'excited', 'eat', 'listen', 'think', 'wave', 'drag', 'throw'];
    list.forEach(key => this.el.classList.remove(`state-${key}`));

    this.el.classList.add(`state-${name}`);
    this.updateSpriteSrc();
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

  setupTouch() {
    const handleStart = (e) => {
      const touch = e.touches ? e.touches[0] : e;
      this.dragging = true;
      this.physics.velocity = { x: 0, y: 0 };
      this.setAnimation('drag');
      const rect = this.el.parentElement.getBoundingClientRect();
      this.lastTouch = { x: touch.clientX - rect.left, y: touch.clientY - rect.top };
      this.touchStartTime = Date.now();
      this.lastDragPos = { x: this.physics.position.x, y: this.physics.position.y, t: Date.now() };
      this.dragVel = { x: 0, y: 0 };

      window.ShimejiSound.play('tap');
      e.stopPropagation();
    };

    const handleMove = (e) => {
      if (!this.dragging) return;
      const touch = e.touches ? e.touches[0] : e;
      const rect = this.el.parentElement.getBoundingClientRect();
      const posX = touch.clientX - rect.left;
      const posY = touch.clientY - rect.top;
      
      const dx = posX - this.lastTouch.x;
      const dy = posY - this.lastTouch.y;

      this.physics.position.x += dx;
      this.physics.position.y += dy;

      const maxW = this.el.parentElement.clientWidth;
      const maxH = this.el.parentElement.clientHeight;

      this.physics.position.x = Math.max(0, Math.min(maxW - this.size, this.physics.position.x));
      this.physics.position.y = Math.max(0, Math.min(maxH - this.size, this.physics.position.y));

      const now = Date.now();
      const dt = now - this.lastDragPos.t;
      if (dt > 10) {
        this.dragVel.x = (this.physics.position.x - this.lastDragPos.x) / dt * 15;
        this.dragVel.y = (this.physics.position.y - this.lastDragPos.y) / dt * 15;
        this.lastDragPos = { x: this.physics.position.x, y: this.physics.position.y, t: now };
      }

      this.lastTouch = { x: posX, y: posY };
      e.preventDefault();
      e.stopPropagation();
    };

    const handleEnd = (e) => {
      if (!this.dragging) return;
      this.dragging = false;

      const duration = Date.now() - this.touchStartTime;
      const speed = Math.hypot(this.dragVel.x, this.dragVel.y);

      if (speed > 3) {
        this.physics.velocity.x = this.dragVel.x;
        this.physics.velocity.y = this.dragVel.y;
        this.setAnimation('throw');
        window.ShimejiSound.play('jump');
      } else if (duration < 250) {
        this.reactToTap();
      } else {
        this.setAnimation('fall');
      }
      this.scheduleBehavior();
      e.stopPropagation();
    };

    this.el.addEventListener('touchstart', handleStart, { passive: false });
    this.el.addEventListener('touchmove', handleMove, { passive: false });
    this.el.addEventListener('touchend', handleEnd);

    // Double tap
    let lastTap = 0;
    this.el.addEventListener('touchend', (e) => {
      const now = Date.now();
      if (now - lastTap < 300) {
        this.setAnimation('dance');
        this.say("Let's dance!");
        window.ShimejiSound.play('happy');
      }
      lastTap = now;
    });
  }

  reactToTap() {
    const anims = ['happy', 'surprised', 'love', 'wave', 'jump', 'excited'];
    const chosen = anims[Math.floor(Math.random() * anims.length)];
    this.setAnimation(chosen);
    window.ShimejiSound.play('happy');

    // Add XP to the main app state and render
    if (typeof addXp === 'function') {
      addXp(10);
      saveState();
      render();
      this.say("Friendship +10 XP!");
    }
  }

  scheduleBehavior() {
    clearTimeout(this.behaviorTimer);
    if (this.dragging) return;

    this.behaviorTimer = setTimeout(() => {
      this.performBehavior();
      this.scheduleBehavior();
    }, 4000 + Math.random() * 5000);
  }

  performBehavior() {
    if (this.dragging || this.physics.position.y < this.physics.floorY) return;

    const res = this.brain.pickIdleBehavior();
    const anim = res.animation || 'idle';
    this.setAnimation(anim);
    if (res.line) this.say(res.line);

    const maxW = this.el.parentElement ? this.el.parentElement.clientWidth : window.innerWidth;

    if (anim === 'walk' || anim === 'run') {
      const tx = Math.random() * (maxW - this.size);
      this.physics.setTarget(tx, this.physics.floorY);
    } else if (anim === 'jump') {
      this.physics.velocity.y = -9 - Math.random() * 7;
      window.ShimejiSound.play('jump');
    }
  }

  tick() {
    const parent = this.el.parentElement;
    if (!parent) return;

    const floor = parent.clientHeight - this.size;
    this.physics.setFloor(floor);

    if (this.dragging) {
      this.el.style.left = `${this.physics.position.x}px`;
      this.el.style.top = `${this.physics.position.y}px`;
      return;
    }

    if (this.physics.position.y < this.physics.floorY) {
      this.physics.velocity.y += this.physics.gravity;
      this.physics.position.x += this.physics.velocity.x;
      this.physics.position.y += this.physics.velocity.y;
      this.physics.velocity.x *= 0.98;

      const maxW = parent.clientWidth;
      if (this.physics.position.x <= 0) {
        this.physics.position.x = 0;
        this.physics.velocity.x = Math.abs(this.physics.velocity.x) * 0.5;
      } else if (this.physics.position.x >= maxW - this.size) {
        this.physics.position.x = maxW - this.size;
        this.physics.velocity.x = -Math.abs(this.physics.velocity.x) * 0.5;
      }

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
      const beforeX = this.physics.position.x;
      const targetState = this.physics.step();

      const velX = targetState.x - beforeX;
      if (Math.abs(velX) > 0.05) {
        this.setAnimation(this.currentAnimation === 'run' ? 'run' : 'walk');
        this.el.style.transform = velX < 0 ? 'scaleX(-1)' : 'scaleX(1)';
      } else {
        if (this.currentAnimation === 'walk' || this.currentAnimation === 'run') {
          this.setAnimation('idle');
        }
      }
    }

    this.el.style.left = `${this.physics.position.x}px`;
    this.el.style.top = `${this.physics.position.y}px`;

    // Pet to Pet interaction inside app
    this.checkInAppInteractions();
  }

  checkInAppInteractions() {
    if (Date.now() < this.nextInteractionTime || inAppPets.length < 2) return;

    inAppPets.forEach(other => {
      if (other === this || other.dragging) return;
      const dist = Math.abs(other.physics.position.x - this.physics.position.x);
      if (dist < 100) {
        this.nextInteractionTime = Date.now() + 15000;
        other.nextInteractionTime = Date.now() + 15000;

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

// Global entrypoints for the main app Integration
window.initInAppShimeji = function() {
  const container = document.getElementById('inAppShimejiContainer');
  if (!container) return;

  // Clear old ones
  inAppPets.forEach(p => p.destroy());
  inAppPets = [];

  const shimejiEnabled = state.shimeji?.inAppEnabled;
  if (!shimejiEnabled) {
    container.style.display = 'none';
    cancelAnimationFrame(inAppLoopId);
    inAppLoopId = null;
    return;
  }

  container.style.display = 'block';

  // Load sound settings
  window.ShimejiSound.enabled = state.shimeji?.soundEnabled !== false;
  window.ShimejiSound.volume = (Number(state.shimeji?.soundVolume) || 50) / 100;

  // Spawn active ones
  const activeIds = state.shimeji?.activeCompanions || ['maxie'];
  activeIds.forEach(id => {
    inAppPets.push(new InAppPetInstance(id, {}));
  });

  if (!inAppLoopId) {
    lastInAppFrameTime = performance.now();
    requestAnimationFrame(inAppLoopStep);
  }
};

function inAppLoopStep(timestamp) {
  if (!state.shimeji?.inAppEnabled) return;
  inAppLoopId = requestAnimationFrame(inAppLoopStep);

  const isSaver = state.shimeji?.batterySaver;
  const fps = isSaver ? 12 : (inAppIdle ? 15 : 45);
  const interval = 1000 / fps;
  const elapsed = timestamp - lastInAppFrameTime;

  if (elapsed < interval) return;
  lastInAppFrameTime = timestamp - (elapsed % interval);

  inAppPets.forEach(p => p.tick());
}

// Inactivity tracking
function resetInAppIdle() {
  inAppIdle = false;
  clearTimeout(inAppIdleTimer);
  inAppIdleTimer = setTimeout(() => {
    inAppIdle = true;
  }, 15000);
}
window.addEventListener('touchstart', resetInAppIdle);
resetInAppIdle();

// Pause when tab minimized / backgrounded
document.addEventListener('visibilitychange', () => {
  if (document.hidden) {
    cancelAnimationFrame(inAppLoopId);
    inAppLoopId = null;
  } else {
    if (state.shimeji?.inAppEnabled && !inAppLoopId) {
      lastInAppFrameTime = performance.now();
      requestAnimationFrame(inAppLoopStep);
    }
  }
});
