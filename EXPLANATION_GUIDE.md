# SkillForgeAI: Hackathon Codebase & Presentation Guide

Welcome to the **SkillForgeAI** codebase guide. This document explains the architecture, file organization, features, and database schemas of the platform to help you easily present, explain, and pitch this project at the hackathon.

---

## 🚀 Hackathon Pitch: The Problem & Our Solution

### The Problem
Traditional student portfolios (PDF resumes) are static, unverified, and disconnected from academic progress and industry demands. Students struggle to find structured pathways, while companies struggle to find verified, industry-ready talent.

### The Solution: *SkillForgeAI*
SkillForgeAI is an end-to-end, AI-driven career intelligence and portfolio platform. It bridges the gap between classrooms and boardrooms through a 3-stage ecosystem:
1. **Stage 1 (Initiation)**: Interactive academic onboarding, target interest profiling, and dynamic learning roadmap generation.
2. **Stage 2 (Body)**: Interactive technical & aptitude assessments, and a premium audio-visual mock interview simulator featuring situational case studies to evaluate workplace personality, ethics, and growth mindset. It grades performance across three pillars (Technical, Communication, Mindset) and auto-recommends study materials for scores under 90%.
3. **Stage 3 (Final & Scalability)**: A live A4 resume editor compiled directly from academic and training history, featuring a dynamic ATS Checker, circular score meter, and interactive AI Resume Coach chat. Also includes a moderator hub connecting college indices with company hiring requirements.

---

## 🛠️ Technology Stack & Libraries

- **Frontend**: React + Vite (Fast building, native ES Modules)
- **Database & Auth**: Supabase (PostgreSQL engine)
- **Styling & Theme**: Vanilla CSS (Responsive brand palettes mapping clean professional Light Mode and Midnight Slate Dark Mode, toggled via a header button and saved in localStorage). Uses a cohesive color scheme: Sky Blue, Emerald Green, Amber/Orange warning highlights, and Slate backgrounds/typography.
- **Theme Transitions**: Custom-curated cubic-bezier transitions applied globally to text, backgrounds, buttons, and card containers for seamless dark/light theme adjustments and micro-interaction states.
- **Icons**: Lucide React
- **Voice Capabilities**: Web Speech API (`SpeechSynthesis` for talking AI and `SpeechRecognition` for candidate voice transcription)
- **Video Capture**: Web Media Stream (`getUserMedia` rendering candidate webcam feeds)

---

## 📂 Codebase File Directory Map

```
d:/SkillForgeAI/
├── package.json               # Project dependencies and run commands
├── vite.config.js             # Vite builder configurations
├── index.html                 # App container template and SEO tags
├── supabase_schema.sql         # SQL script to initialize Database structures
├── EXPLANATION_GUIDE.md       # This markdown document
├── EXPLANATION_GUIDE.txt      # Text version of this guide
├── CLONE_INSTRUCTIONS.md      # Full source blueprint code file
└── src/
    ├── main.jsx               # Application React DOM mount entrypoint
    ├── index.css              # Custom styling sheet (Light Theme style design)
    ├── App.jsx                # Global state manager, navbar tab router, dashboard container
    ├── services/
    │   ├── supabaseClient.js  # Supabase client with live-or-mock runtime fallback
    │   └── aiService.js       # Content provider supporting local presets and Gemini API calls
    ├── hooks/
    │   └── useSpeech.js       # Custom wrapper for Text-To-Speech & Speech-To-Text
    └── components/
        ├── GlassCard.jsx      # Design utility representing glassmorphic cards
        ├── SettingsModal.jsx  # Configuration screen for Supabase & Gemini API keys
        ├── OnboardingWizard.jsx # Onboarding setup form + Supabase auth triggers
        ├── RoadmapView.jsx    # Visual milestone flow and target job analysis
        ├── TrainingCenter.jsx # Technical/Aptitude testing engine with past score timelines
        ├── InterviewSim.jsx   # Webcam preview mock interviewer with speech engines
        ├── ResumeBuilder.jsx  # Interactive A4 CV template and custom print setups
        └── ModeratorPortal.jsx # College indices view and corporate recruit outreach
```

---

## ⚙️ Core Engineering Design Patterns

### 1. Dual-Mode Supabase Client (Live & Offline Mock Mode)
To ensure the app runs flawlessly for hackathon judges without requiring them to set up a database first, the client in `supabaseClient.js` checks for credentials. If environment variables or runtime configurations (configured in the dashboard settings) are missing, it silently falls back to a **Mock Service Layer** stored in `localStorage`. 

Once Supabase credentials are input in the **Settings Panel**, the application dynamically re-initializes and begins syncing data directly to the live PostgreSQL tables.

### 2. Live Webcam Rendering (Correct React Lifecycle Binding)
In the **Mock Interview Simulator (`InterviewSim.jsx`)**, the candidate's camera stream is requested via `navigator.mediaDevices.getUserMedia` when they click "Start Interview". Instead of simple HTML bindings, the React state manages the lifecycle. A dedicated `useEffect` binds the active `MediaStream` to the HTML5 video element via `videoRef.current.srcObject` when the state updates. This bypasses typical React state-sync bugs and ensures the stream plays instantly.

### 3. Voice Synthesis & Voice Recognition Synchronization
The voice loop runs asynchronously:
1. The AI synthesizes the question and speaks to the candidate using `window.speechSynthesis`.
2. When the speaker completes the prompt, the `onend` callback triggers.
3. This callback automatically starts the browser's `webkitSpeechRecognition` engine, activating the microphone.
4. As the candidate speaks, their voice is transcribed in real-time and mapped to the text area.

### 4. Lightweight SVG Data Visualization
Instead of importing heavy charting libraries (like Chart.js or Recharts) which can introduce dependency conflicts and balloon the production bundle size, the **Learning History Trend** in `TrainingCenter.jsx` utilizes native SVG elements. It maps scores array data to viewport space coordinates dynamically, rendering a smooth executive trend line with data circles, value labels, and hover status cards.

---

## 📂 Component & Code Logic Walkthrough

### 1. Database Setup (`supabase_schema.sql`)
Creates the schemas required to persist student portfolios:
- **`profiles` table**: Extends standard user accounts with institution, branch, subjects, target interests, and learning timelines.
- **`scores` table**: Tracks student results across Tech, Aptitude, and Interview tests, saving detailed JSON payloads of questions and recommendations.
- **`resumes` table**: Persists custom CV summaries, education records, and projects.
- **Signup Trigger (`handle_new_user`)**: Listens to standard Supabase user registrations and automatically creates linked empty profiles and resume records.

### 2. Client Controller (`App.jsx`)
Acts as the router and global state provider. It listens to the Supabase auth state change:
- If a user session is active, it queries profile data and score list.
- If no session exists, it renders the `OnboardingWizard.jsx` signup forms.
- Distributes progress statistics (percent complete) and quiz records downstream to sub-views.

### 3. Onboarding Wizard (`OnboardingWizard.jsx`)
A 3-step setup form:
- **Step 1**: Collects auth credentials (Email, Password, Phone Number), name, and academic institution.
- **Step 2**: Prompts selection of tech domains (e.g. Full Stack, AI/ML).
- **Step 3**: Collects timeline consistency parameters (e.g., 6 months). Clicking "Build Roadmap" signs up the user in Supabase Auth.

### 4. Interactive Quiz & Mindset Checker (`TrainingCenter.jsx`)
Enables student technical self-testing and workplace situational alignment:
- Pulls questions either from custom Google Gemini prompts (if API key is active) or local mock lists for:
  - **Technical Training**: Dynamic stack questions matching target interests.
  - **Aptitude Assessment**: Quantitative, logical, and verbal practice.
  - **Personality & Case Study**: Situational judgment scenarios mapping workplace conflict resolution, ethical software decisions, collaborative compromise, and leadership mindset.
- Persists final scorecards to the Supabase database.
- Integrates a **Learning History SVG Line Graph** showing progress trend timelines.
- Generates targeted **Course Recommendations** (e.g. emotional intelligence, leadership, core technology, aptitude) matching the quiz domain to bridge skill gaps.

### 5. CV Designer & AI Coach (`ResumeBuilder.jsx`)
Features a dual-layout editor:
- **Left Panel (Tabbed Navigation)**:
  - **Edit Details**: Input fields to add, edit, or remove skills, project details, education milestones, and career experience.
  - **AI Coach & ATS Score**: Features a circular SVG score meter measuring compliance, an AI warning checklist pointing out structural/content gaps, actionable tips, an ATS keyword match scanner (with click-to-insert capabilities), and a live chat coach interface connected to the Gemini API/offline fallback to refine CV writing in real-time.
- **Right Panel**: A real A4-sized CSS layout representing the PDF. Standard CSS variables are configured to look neat when printed (`window.print()` prints the container cleanly).

### 6. Mock Interview Simulator (`InterviewSim.jsx`)
- Runs audio-video mock interview loops with real-time candidate webcam feeds, rotating glowing AI indicators, and talking AI prompts.
- Administers an 8-question curriculum structured into distinct phases: **Technical** (3 questions), **Behavioral** (2 questions), and **Personality/Situational Case-Studies** (3 questions covering workplace conflicts, technical debates, security threats, outages).
- Evaluates the transcripts using three key vectors: **Technical Competency**, **Communication Clarity**, and **Personality/Growth-Mindset**, saving individual scores and overall scores to the Supabase database.
- Details professional expert mentors and features a visual scheduling stepper with a premium virtual credit-card booking simulator for custom live human audits.

---

## 🎤 How to Pitch this Project at the Hackathon

1. **Start with the Hook**:
   * *"Most resumes are self-written PDF files with zero verification. We built SkillForgeAI to make career progression dynamic, AI-certified, and directly connected to recruiters."*
2. **Onboard live**:
   * Fill out the onboarding form. Explain how this maps the student's curriculum branch and subjects directly to target job markets. Show the generated visual roadmap.
3. **Run the AI Mock Interview**:
   * Click "Mock Interview" and start it. Allow the AI to speak the question. Answer via voice or text. Explain how the Speech APIs and webcam operate locally on the client's browser.
4. **Show the Certifications & Learning History**:
   * Show the learning history line graph and the scorecard showing that scores under 90% generate study resources. Show the curated Course Suggestions. Explain that successful certifications are automatically compiled into the live A4 Resume.
5. **Recruiter Overview**:
   * Switch to the "Moderator Hub". Show how a recruiter from Google or Stripe can search for candidates based on actual verified assessment metrics, matching student profiles immediately.
