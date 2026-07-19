class PetPhysics {
  constructor(bounds) {
    this.position = { x: bounds.x || 180, y: bounds.y || 180 };
    this.target = { ...this.position };
    this.velocity = { x: 0, y: 0 };
    this.baseSpeed = 0.018;
    this.speed = this.baseSpeed;
    this.damping = 0.76;
    this.gravity = 0;
    this.floorY = this.position.y;
    this.bounce = 0.36;
  }

  setSpeed(multiplier) {
    this.speed = this.baseSpeed * Math.max(0.5, Math.min(2, Number(multiplier) || 1));
  }

  configure(options = {}) {
    this.setSpeed(options.speed);
    this.damping = options.physicsMode === false ? 0.68 : 0.78;
    this.gravity = options.gravity ? 0.08 * Math.max(0, Math.min(2, Number(options.gravityStrength) || 0.35)) : 0;
    this.bounce = options.bounceLanding === false ? 0.08 : 0.36;
  }

  setFloor(y) {
    this.floorY = Number.isFinite(y) ? y : this.floorY;
  }

  setTarget(x, y) {
    if (!Number.isFinite(Number(x)) || !Number.isFinite(Number(y))) return;
    this.target.x = x;
    this.target.y = y;
  }

  step() {
    const ax = (this.target.x - this.position.x) * this.speed;
    const ay = (this.target.y - this.position.y) * this.speed;
    this.velocity.x = (this.velocity.x + ax) * this.damping;
    this.velocity.y = (this.velocity.y + ay + this.gravity) * this.damping;
    this.position.x += this.velocity.x;
    this.position.y += this.velocity.y;
    if (this.gravity && this.position.y > this.floorY) {
      this.position.y = this.floorY;
      this.velocity.y = -Math.abs(this.velocity.y) * this.bounce;
      if (Math.abs(this.velocity.y) < 0.45) this.velocity.y = 0;
    }
    return { ...this.position };
  }

  isNearTarget(distance = 14) {
    return Math.hypot(this.target.x - this.position.x, this.target.y - this.position.y) < distance;
  }
}

window.PetPhysics = PetPhysics;
