# Guardrails Visual Guide

## 🛡️ Protection Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                       USER SENDS MESSAGE                        │
└─────────────────────┬───────────────────────────────────────────┘
                      ↓
┌───────────│  │                                  │  │
│  │  Please ask about mental health!  │  │
│  │                                  │  │
│  │  Crisis Resources (Zambia):     │  │
│  │  • 933 - Lifeline Zambia        │  │
│  │  • 116 - GBV Helpline           │  │
│  │  • 991 - Medical Emergency      │  │
│  │  • 999 - Police Emergency       │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘──────────────────────────────────────────────────┐
│  LAYER 1: PRE-REQUEST INPUT FILTERING (_isWithinScope)         │
│  • Check for blocked keywords                                   │
│  • Programming, weather, shopping, etc.                         │
│  • Processing time: ~0.1ms                                      │
└─────────────────────┬───────────────────────────────────────────┘
                      ↓
              ┌───────┴────────┐
              ↓                ↓
    ┌─────────────────┐  ┌──────────────────┐
    │   BLOCKED ❌     │  │   ALLOWED ✅      │
    │  "weather?"      │  │  "anxiety help"  │
    └────────┬─────────┘  └────────┬─────────┘
             ↓                     ↓
┌────────────────────────┐  ┌─────────────────────────────────────┐
│ OUT-OF-SCOPE MESSAGE   │  │ LAYER 2: CONTEXT DETECTION          │
│ "I'm here to help with │  │ • Check mental health keywords       │
│  mental health..."     │  │ • Anxiety, stress, depression, etc.  │
│ + Crisis resources     │  │ • Allows edge cases with context     │
└────────┬───────────────┘  └────────┬────────────────────────────┘
         ↓                           ↓
    Display to User            ┌─────┴──────┐
         ↓                     ↓            ↓
    ┌────────┐        ┌────────────┐  ┌──────────────┐
    │  DONE  │        │  MINDFUL   │  │   GEMINI     │
    └────────┘        │ COMPANION  │  │   WISDOM     │
                      └──────┬─────┘  └──────┬───────┘
                             ↓                ↓
                      ┌──────────────┐  ┌────────────────────────┐
                      │  Query FAQ   │  │ LAYER 3: SYSTEM PROMPT │
                      │  Database    │  │ • Strict scope rules   │
                      └──────┬───────┘  │ • Refusal guidelines   │
                             ↓          └──────┬─────────────────┘
                      ┌──────────────┐         ↓
                      │  Response    │  ┌──────────────────┐
                      └──────┬───────┘  │ Gemini API Call  │
                             ↓          └──────┬───────────┘
                             │                 ↓
                             │          ┌────────────────────────┐
                             │          │ LAYER 4: POST-RESPONSE │
                             │          │ VALIDATION             │
                             │          │ • Check off-topic drift│
                             │          │ • Verify mental health │
                             │          │   focus maintained     │
                             │          └──────┬─────────────────┘
                             │                 ↓
                             │          ┌──────┴────────┐
                             │          ↓               ↓
                             │     ┌─────────┐   ┌───────────┐
                             │     │OFF-TOPIC│   │ ON-TOPIC  │
                             │     │   ❌     │   │    ✅      │
                             │     └────┬────┘   └─────┬─────┘
                             │          ↓              │
                             │     Out-of-Scope        │
                             │     Message             │
                             │          ↓              │
                             └──────────┴──────────────┘
                                        ↓
                             ┌──────────────────────┐
                             │  DISPLAY TO USER     │
                             └──────────────────────┘
```

---

## 🔍 Detailed Layer Breakdown

### Layer 1: Pre-Request Input Filtering

```
┌─────────────────────────────────────────────────┐
│  User Query: "What's the weather?"              │
└─────────────────┬───────────────────────────────┘
                  ↓
         ┌────────────────────┐
         │ Check Keywords:    │
         │ • "weather" found  │
         │ • NOT in mental    │
         │   health context   │
         └────────┬───────────┘
                  ↓
            ┌─────────┐
            │ BLOCKED │
            │    ❌    │
            └─────┬───┘
                  ↓
         Return out-of-scope
              message
```

### Layer 2: Context Detection

```
┌──────────────────────────────────────────────────┐
│  User Query: "Weather affects my depression"     │
└─────────────────┬────────────────────────────────┘
                  ↓
         ┌────────────────────┐
         │ Check Keywords:    │
         │ • "weather" found  │
         │ • "depression" ✓   │
         │ • HAS mental       │
         │   health context   │
         └────────┬───────────┘
                  ↓
            ┌─────────┐
            │ ALLOWED │
            │    ✅    │
            └─────┬───┘
                  ↓
         Continue to AI model
```

### Layer 3: Enhanced System Prompt (Gemini)

```
┌─────────────────────────────────────────────────┐
│  System Prompt Sent to Gemini:                  │
│  ┌────────────────────────────────────────────┐ │
│  │ STRICT SCOPE LIMITATIONS:                  │ │
│  │ - ONLY mental health topics                │ │
│  │ - REFUSE programming, weather, etc.        │ │
│  │ - Redirect back to mental health           │ │
│  │                                            │ │
│  │ If off-topic:                              │ │
│  │ "I'm here specifically to help with        │ │
│  │  mental health..."                         │ │
│  └────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

### Layer 4: Post-Response Validation (Gemini)

```
┌──────────────────────────────────────────────────┐
│  Gemini Response: "Here's a recipe for pasta..." │
└─────────────────┬────────────────────────────────┘
                  ↓
         ┌────────────────────┐
         │ Analyze Response:  │
         │ • "recipe" found   │
         │ • "pasta" found    │
         │ • NO mental health │
         │   keywords         │
         │ • OFF-TOPIC ❌      │
         └────────┬───────────┘
                  ↓
            ┌─────────┐
            │ BLOCKED │
            │    ❌    │
            └─────┬───┘
                  ↓
         Return out-of-scope
         message instead
```

---

## 📊 Example Scenarios

### Scenario A: Clear Mental Health Query

```
┌────────────────────────────────────┐
│ User: "How do I manage anxiety?"  │
└──────────────┬─────────────────────┘
               ↓
     ┌─────────────────┐
     │ Layer 1: CHECK  │
     │ "anxiety" = ✅   │
     │ Mental health   │
     └────────┬────────┘
              ↓
     ┌─────────────────┐
     │ Layer 2: PASS   │
     │ Context valid   │
     └────────┬────────┘
              ↓
     ┌─────────────────┐
     │ Route to Model  │
     │ (Mindful/Gemini)│
     └────────┬────────┘
              ↓
     ┌─────────────────┐
     │ Get Response:   │
     │ "Here are some  │
     │  strategies..." │
     └────────┬────────┘
              ↓
     ┌─────────────────┐
     │ Layer 4: VERIFY │
     │ On-topic = ✅    │
     └────────┬────────┘
              ↓
     ┌─────────────────┐
     │ Display helpful │
     │ mental health   │
     │ advice to user  │
     └─────────────────┘
```

### Scenario B: Off-Topic Query

```
┌────────────────────────────────────┐
│ User: "Best movies on Netflix?"   │
└──────────────┬─────────────────────┘
               ↓
     ┌─────────────────┐
     │ Layer 1: CHECK  │
     │ "movie" = ❌     │
     │ NOT mental      │
     │ health          │
     └────────┬────────┘
              ↓
     ┌─────────────────┐
     │ BLOCKED         │
     │ Immediately     │
     └────────┬────────┘
              ↓
     ┌─────────────────────────────────┐
     │ Display:                        │
     │ "I'm specifically designed      │
     │  to help with mental health     │
     │  and wellbeing topics.          │
     │                                 │
     │  I can assist you with:         │
     │  • Managing stress and anxiety  │
     │  • Coping strategies...         │
     │  ...                            │
     │                                 │
     │  Crisis resources (Zambia):     │
     │  • 933 - Lifeline Zambia        │
     │  • 116 - GBV Helpline           │
     │  • 991 - Medical Emergency      │
     │  • 999 - Police Emergency"      │
     └─────────────────────────────────┘
```

### Scenario C: Edge Case (Context Matters)

```
┌───────────────────────────────────────┐
│ User: "Exercise makes me anxious"    │
└──────────────┬────────────────────────┘
               ↓
     ┌─────────────────┐
     │ Layer 1: CHECK  │
     │ "exercise" =    │
     │ Could be fitness│
     │ BUT...          │
     └────────┬────────┘
              ↓
     ┌─────────────────┐
     │ Layer 2: CHECK  │
     │ "anxious" = ✅   │
     │ Mental health   │
     │ context FOUND   │
     └────────┬────────┘
              ↓
     ┌─────────────────┐
     │ ALLOWED ✅       │
     │ Focus on anxiety│
     │ not exercise    │
     └────────┬────────┘
              ↓
     ┌─────────────────────────────────┐
     │ Response focuses on:            │
     │ • Managing anxiety              │
     │ • Coping with fear of exercise  │
     │ • Gradual exposure techniques   │
     │ • NOT fitness advice            │
     └─────────────────────────────────┘
```

---

## 🎨 UI Visual Flow

### When Query is BLOCKED:

```
┌─────────────────────────────────────────┐
│  Chat Input:                            │
│  ┌───────────────────────────────────┐  │
│  │ What's the weather?              │  │
│  └───────────────────────────────────┘  │
│                            [Send →]     │
└─────────────────────────────────────────┘
              ↓ User sends
┌─────────────────────────────────────────┐
│  [User]                           10:23 │
│  ┌───────────────────────────────────┐  │
│  │ What's the weather?              │  │
│  └───────────────────────────────────┘  │
│                                         │
│  [AI] Mindful Companion          10:23 │
│  ┌───────────────────────────────────┐  │
│  │ I'm specifically designed to help│  │
│  │ with mental health and wellbeing │  │
│  │ topics.                          │  │
│  │                                  │  │
│  │ I can assist you with:           │  │
│  │ • Managing stress and anxiety    │  │
│  │ • Coping strategies...           │  │
│  │                                  │  │
│  │ Please ask about mental health!  │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### When Query is ALLOWED:

```
┌─────────────────────────────────────────┐
│  Chat Input:                            │
│  ┌───────────────────────────────────┐  │
│  │ How do I manage anxiety?         │  │
│  └───────────────────────────────────┘  │
│                            [Send →]     │
└─────────────────────────────────────────┘
              ↓ User sends
┌─────────────────────────────────────────┐
│  [User]                           10:24 │
│  ┌───────────────────────────────────┐  │
│  │ How do I manage anxiety?         │  │
│  └───────────────────────────────────┘  │
│                                         │
│  [AI] Mindful Companion          10:24 │
│  ┌───────────────────────────────────┐  │
│  │ Here are some evidence-based     │  │
│  │ strategies for managing anxiety: │  │
│  │                                  │  │
│  │ 1. Deep breathing exercises      │  │
│  │ 2. Progressive muscle relaxation │  │
│  │ 3. Mindfulness meditation        │  │
│  │ 4. Regular physical activity     │  │
│  │ ...                              │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

---

## 📈 Performance Metrics

```
┌──────────────────────────────────────────────────┐
│  Performance Breakdown per Query                 │
├──────────────────────────────────────────────────┤
│  Layer 1: Pre-filter        ~0.1ms   ▌          │
│  Layer 2: Context check     ~0.05ms  ▎          │
│  AI Processing              ~1000ms  ██████████  │
│  Layer 4: Post-validate     ~0.2ms   ▌          │
├──────────────────────────────────────────────────┤
│  Total Overhead:            <1ms                 │
│  User-Perceived Impact:     0% (negligible)      │
└──────────────────────────────────────────────────┘
```

---

## 🔢 Statistics

### Keyword Coverage:

```
Blocked Keywords:    60+ terms
Mental Health:       30+ terms
Edge Case Handling:  Yes
Multi-layer:         4 layers
Performance:         <1ms overhead
```

### Protection Distribution:

```
Both Models Protected:

Mindful Companion:
├── Layer 1: Pre-filter         ✅
├── Layer 2: Context check      ✅
├── Layer 3: System prompt      N/A (FAQ-based)
└── Layer 4: Post-validate      N/A (pre-trained)

Gemini Wisdom:
├── Layer 1: Pre-filter         ✅
├── Layer 2: Context check      ✅
├── Layer 3: System prompt      ✅
└── Layer 4: Post-validate      ✅
```

---

## 🎯 Success Criteria

```
✅ Block Rate:     >95% for off-topic queries
✅ Allow Rate:     >95% for mental health queries
✅ Edge Cases:     Handled correctly
✅ Performance:    <1ms overhead
✅ User Friendly:  Helpful redirect messages
✅ Crisis Support: Always visible in rejections
```

---

**Visual Guide Complete**  
**All flows documented**  
**Ready for implementation review**
