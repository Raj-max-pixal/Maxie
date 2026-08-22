# MAXie Character Animations Guide

This document outlines all the Lottie/Rive animations needed for MAXie Mobile.

## Required Animations

### Core Animations (Priority: HIGH)

1. **maxie_idle.json** - Default idle animation
   - MAXie standing/breathing gently
   - Subtle movement to show life
   - Loop: Yes
   - Duration: 2-3 seconds

2. **maxie_happy.json** - Happy emotion
   - MAXie smiling, bouncing slightly
   - Tail wagging (if applicable)
   - Loop: Yes
   - Duration: 1-2 seconds

3. **maxie_sleepy.json** - Sleepy emotion
   - MAXie yawning, eyes half-closed
   - Slow, relaxed movements
   - Loop: Yes
   - Duration: 3-4 seconds

4. **maxie_excited.json** - Excited emotion
   - MAXie jumping, bouncing energetically
   - Fast movements
   - Loop: Yes
   - Duration: 1 second

5. **maxie_sad.json** - Sad emotion
   - MAXie looking down, slow movements
   - Drooping posture
   - Loop: Yes
   - Duration: 2-3 seconds

6. **maxie_focused.json** - Focused emotion
   - MAXie with glasses/accessory
   - Serious but cute expression
   - Loop: Yes
   - Duration: 2 seconds

### Activity-Specific Animations (Priority: MEDIUM)

7. **maxie_dancing.json** - Dancing to music
   - MAXie dancing to beat
   - Energetic movements
   - Loop: Yes
   - Duration: 2-3 seconds

8. **maxie_walking.json** - Walking animation
   - MAXie walking across screen
   - Smooth gait
   - Loop: Yes
   - Duration: 1-2 seconds

9. **maxie_running.json** - Running animation
   - MAXie running quickly
   - Fast movements
   - Loop: Yes
   - Duration: 1 second

10. **maxie_jumping.json** - Jumping animation
    - MAXie jumping up and down
    - Bouncy movements
    - Loop: Yes
    - Duration: 1 second

### Interaction Animations (Priority: MEDIUM)

11. **maxie_tap_reaction.json** - Reaction to tap
    - MAXie reacts to being tapped
    - Quick, cute response
    - Loop: No
    - Duration: 0.5-1 second

12. **maxie_double_tap.json** - Reaction to double tap
    - MAXie gets excited
    - Celebratory movement
    - Loop: No
    - Duration: 1-2 seconds

13. **maxie_long_press.json** - Reaction to long press
    - MAXie goes to sleep
    - Calming down
    - Loop: No
    - Duration: 1-2 seconds

### Special Animations (Priority: LOW)

14. **maxie_intro.json** - Introduction animation
    - MAXie appears and introduces itself
    - Welcoming movements
    - Loop: No
    - Duration: 3-4 seconds

15. **maxie_overlay.json** - Overlay mode animation
    - MAXie in overlay mode
    - Smaller, compact movements
    - Loop: Yes
    - Duration: 2 seconds

16. **maxie_emotions.json** - Emotion showcase
    - MAXie showing various emotions
    - Transitioning between states
    - Loop: Yes
    - Duration: 4-5 seconds

17. **maxie_friendship.json** - Friendship celebration
    - MAXie celebrating friendship
    - Heart effects, confetti
    - Loop: Yes
    - Duration: 2-3 seconds

### Context-Specific Animations (Priority: LOW)

18. **maxie_coding.json** - Coding mode
    - MAXie with laptop, typing
    - Smart/cute coding animation
    - Loop: Yes
    - Duration: 2-3 seconds

19. **maxie_gaming.json** - Gaming mode
    - MAXie as game coach
    - Energetic, hype movements
    - Loop: Yes
    - Duration: 2 seconds

20. **maxie_studying.json** - Study mode
    - MAXie with glasses, reading
    - Focused, calm movements
    - Loop: Yes
    - Duration: 2-3 seconds

## Animation Specifications

### Design Guidelines
- **Style**: Cute, adorable, minimalist
- **Colors**: Purple (#6C63FF) as primary, with complementary colors
- **Size**: Scalable vector graphics
- **Frame Rate**: 60 FPS for smooth animations
- **Format**: Lottie JSON (recommended) or Rive

### Character Design
- MAXie should be a small, cute creature
- Round shapes, soft edges
- Expressive eyes and mouth
- Small body with big personality
- Can have accessories (glasses, hats, etc.)

### Animation Principles
- **Squash and Stretch**: For bouncing and movement
- **Timing**: Appropriate for emotion (fast for excited, slow for sleepy)
- **Anticipation**: Prepare before major movements
- **Follow Through**: Natural movement after actions
- **Overlap**: Different body parts move at different speeds

## Tools for Creating Animations

### Lottie (Recommended)
1. **Adobe After Effects** with Lottie plugin
2. **LottieFiles** - Online animation tools
3. **Haiku** - Sketch-based animation tool
4. **Rive** - Alternative to Lottie

### Free Tools
- **LottieFiles Create** - Free online tool
- **Canva** - Basic animations
- **Blender** - 3D animations (export to 2D)

### Resources
- LottieFiles: https://lottiefiles.com/
- Rive: https://rive.app/
- Animation tutorials: YouTube

## Asset Placement

Place animation files in:
```
mobile/assets/lottie/
```

Update `pubspec.yaml` to include:
```yaml
assets:
  - assets/lottie/
```

## Implementation Notes

### Loading Animations
Use the Lottie package in Flutter:
```dart
Lottie.asset('assets/lottie/maxie_happy.json')
```

### Performance
- Use `Lottie.asset` for bundled animations
- Cache animations for better performance
- Use `LottieBuilder` for complex animations
- Consider animation complexity for battery life

### Fallbacks
If animations fail to load, show a fallback icon or simple animation using Flutter animations.

## Next Steps

1. Create basic character design in Figma/Sketch
2. Export character parts for animation
3. Create core animations (idle, happy, sleepy, excited)
4. Test animations in the app
5. Add more complex animations as needed
6. Optimize for performance

## Budget Considerations

- **Free Option**: Use LottieFiles Create or basic tools
- **Professional Option**: Hire animator or use Adobe After Effects
- **Estimated Cost**: $0 (DIY) to $500+ (professional)

## Timeline

- **Week 1**: Character design and core animations
- **Week 2**: Activity-specific animations
- **Week 3**: Interaction and special animations
- **Week 4**: Testing and optimization

---

**Note**: Animations are crucial for MAXie's personality. Invest time in making them smooth, cute, and expressive.
