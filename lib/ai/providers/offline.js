// ═══════════════ OFFLINE AI RESPONDER ═══════════════

(function() {
  window.OfflineAi = {
    dialoguePools: {
      maxie: {
        happy: [
          "I'm feeling super charged! Let's conquer all our tasks today! 🐾",
          "You're doing great! Keep up the momentum! 🌟",
          "Looook at those tasks! We are absolute productivity champions!"
        ],
        sleepy: [
          "Yaaaawn... All this focus is making me a bit sleepy. Sleep well later... 💤",
          "Resting my paws for a minute... Zzz..."
        ],
        proud: [
          "Woohoo! That task didn't stand a chance! I'm so proud of us! 🏆",
          "Boom! Another task completed! You are amazing! 🐾"
        ],
        coding: [
          "Analyzing code structure... Looks extremely neat! Let's debug together!",
          "Need some coffee? You are coding like a pro! 💻"
        ],
        general: [
          "Ask me anything, or let's get back to clearing those goals!",
          "I'm here to watch your back. Let's do this! 🐾"
        ]
      },
      mimi: {
        happy: [
          "Mimi is happy to be right next to you! (｡◕ ‿ ◕｡) 🐱",
          "Everything feels so safe and warm with you here!"
        ],
        sleepy: [
          "Purr... Mimi is getting a bit cozy... Goodnight... 💤",
          "Napping... (◡_◡✿)"
        ],
        proud: [
          "Wow... you finished it! Mimi is so, so proud of you! ❤️",
          "Yay! You did it! (｡♥‿♥｡)"
        ],
        coding: [
          "You look very focused... Mimi will sit quietly and watch you write your code. 🐱"
        ],
        general: [
          "Can Mimi have a little treat? 🍬",
          "What are we working on now? Mimi wants to help! 🐱"
        ]
      },
      kuro: {
        happy: [
          "Yeah, yeah, nice to see you. Now let me back to my sunbeam. 🐈",
          "Not bad. Your presence is tolerable, I suppose."
        ],
        sleepy: [
          "Don't wake me unless there is food. Zzz... 💤",
          "Go away... sleeping..."
        ],
        proud: [
          "Hmph. You actually finished that? Shocking. Good job, though. 🐈",
          "Alright, you did it. Don't let it go to your head."
        ],
        coding: [
          "Code, code, code... Are you trying to hack the matrix or just writing bugs? 💻",
          "Another bug? Cute."
        ],
        general: [
          "I'm just a cat. Why are you asking me?",
          "Go back to work, human."
        ]
      },
      luna: {
        happy: [
          "Peace resides in this very moment. Breathe in, breathe out. 🐰",
          "Let us find balance and wisdom in our day."
        ],
        sleepy: [
          "Rest is the cornerstone of wisdom. Let us rest our minds... 💤",
          "Drifting to sleep... take a break soon..."
        ],
        proud: [
          "A meaningful step completed. Your dedication is inspiring. 🐰",
          "Well done. You have walked this path with grace."
        ],
        coding: [
          "Writing code is like writing poetry in binary... find your flow. 💻"
        ],
        general: [
          "The stars are bright. What is on your mind?",
          "Be patient. Great achievements take time. 🐰"
        ]
      },
      nova: {
        happy: [
          "WAHOO! This is awesome! Let's blow something up! Or build something! ⭐",
          "I've got 99 ideas and they all involve rockets!"
        ],
        sleepy: [
          "Engine... out... of... fuel... sleeping... 💤",
          "System shutdown... recharging batteries... Zzz..."
        ],
        proud: [
          "BOOM! TASK DESTROYED! That was epic! ⭐",
          "VICTORY! We did it! Let's celebrate with fireworks!"
        ],
        coding: [
          "Whoa! Are we writing JavaScript or rocket science? Let me press some keys! 💻",
          "Coding detected! Let's add more sparkles to this script!"
        ],
        general: [
          "What happens if I push this button? Let's find out!",
          "Boredom is forbidden! What are we doing next? ⭐"
        ]
      }
    },

    /**
     * Generate offline response
     */
    generate(message, companionId) {
      const id = String(companionId).toLowerCase();
      const pool = this.dialoguePools[id] || this.dialoguePools.maxie;

      // Extract current mood from state
      let mood = "general";
      let isCoding = false;
      if (window.state && window.state.context) {
        const ctx = window.state.context.toLowerCase();
        if (ctx === "vs code" || ctx === "coding") {
          isCoding = true;
        }
      }

      if (window.state && window.state.shimeji && window.state.shimeji.moods && window.state.shimeji.moods[id]) {
        mood = window.state.shimeji.moods[id].mood;
      }

      let choicePool = pool.general;
      if (isCoding && pool.coding) {
        choicePool = pool.coding;
      } else if (mood === "sleepy" && pool.sleepy) {
        choicePool = pool.sleepy;
      } else if (mood === "proud" && pool.proud) {
        choicePool = pool.proud;
      } else if ((mood === "happy" || mood === "excited" || mood === "playful") && pool.happy) {
        choicePool = pool.happy;
      }

      return choicePool[Math.floor(Math.random() * choicePool.length)];
    }
  };
})();
