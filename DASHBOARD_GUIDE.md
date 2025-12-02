# Mini Agent Dashboard Guide

## Overview
The Mini Agent Dashboard is a macOS application that provides a visual interface for managing AI-powered development agents. It uses a browser-style tab system where each tab represents different functionality.

---

## Tab System (Top Bar)

### What It Is
- **Browser-style tabs** at the top of the window
- Each tab represents a different view/functionality
- Drag tabs left/right to reorder them
- Click **+** button to add new tabs
- Click **X** on any tab to close it

### Available Tabs

| Tab | Icon | Purpose |
|-----|------|---------|
| **Dashboard** | cpu.fill | Main control panel for running agents and commands |
| **AI Tools** | cpu.fill | Configure AI integrations (Copilot, Gemini, OpenAI, Ollama) |
| **Commands** | terminal.fill | Manage custom CLI commands |
| **Projects** | folder.fill | Project management (not yet implemented) |
| **Generate** | wand.and.stars | Code generation interface (not yet implemented) |
| **Knowledge** | book.fill | Knowledge base/notes (not yet implemented) |
| **Preferences** | gearshape.fill | App settings (not yet implemented) |

---

## Dashboard Tab (Main View)

### Header Section

#### Left Side: Title
- **Icon**: CPU symbol (represents agent processing)
- **Text**: "Mini Agent Dashboard"

#### Right Side: System Status
- **Green Circle**: Agents are running
- **Red Circle**: Agents are stopped
- **Text**: "Running" or "Stopped"

### Left Sidebar: AGENTS

**What It Shows:**
- List of all registered agents in the system
- Each agent name appears when registered

**Current Agents:**
1. **builder** - Handles Swift build operations
2. **test** - Runs tests
3. **repo** - Git repository operations  
4. **memory** - Stores and retrieves notes/context

**Status Indicator:**
- Each agent row shows if the agent system is running
- Green dot = system active
- Gray dot = system inactive

### Main Content Area

#### QUICK ACTIONS Section

Four button grid for common operations:

1. **Build** (Blue, Hammer Icon)
   - Runs `swift build` on your project
   - Compiles the code
   - Shows build output in the output panel

2. **Test** (Green, Checkmark Icon)  
   - Runs `swift test`
   - Executes your test suite
   - Shows test results in output panel

3. **Status** (Orange, Info Icon)
   - Runs `git status`
   - Shows current repository state
   - Lists modified/staged files

4. **List Memory** (Purple, Book Icon)
   - Shows saved memory notes
   - Retrieves context from MemoryAgent
   - Displays stored information

**What Happens When You Click:**
- Button becomes disabled during processing
- Action is sent to the appropriate agent
- Output appears in the bottom panel
- `isProcessing` state prevents multiple simultaneous actions

#### COMMANDS Section

Three input forms for manual operations:

**1. Commit**
- **Input Field**: "Commit message"
- **Button**: "Commit"
- **What It Does**: 
  - Stages all changes (`git add .`)
  - Creates commit with your message
  - Sends request to RepoAgent
  - Shows commit result in output

**2. Create Branch**
- **Input Field**: "Branch name"  
- **Button**: "Create Branch"
- **What It Does**:
  - Creates new git branch with given name
  - Sends request to RepoAgent
  - Shows success/failure in output

**3. Save Note**
- **Input Field**: "Memory note"
- **Button**: "Save Note"
- **What It Does**:
  - Saves text to MemoryAgent
  - Stores context for later retrieval
  - Useful for tracking decisions/ideas
  - Shows confirmation in output

#### OUTPUT Panel (Bottom)

**What It Shows:**
- Real-time results from all actions
- Build output, test results, git status
- Error messages
- Success confirmations

**Features:**
- **Scrollable** - Can view long outputs
- **Monospace font** - Easy to read code/terminal output
- **Processing indicator** - Spinner shows when action is running
- **Header**: "OUTPUT" with optional progress indicator

**Example Output:**
```
Processing build...
Building for debugging...
[1/5] Compiling MiniAgentCore
[2/5] Compiling Agents
...
Build complete!
```

---

## AI Tools Tab

### Purpose
Configure external AI services that agents can use for code generation, questions, and reasoning.

### Configuration Cards

Each AI tool has a card showing:

**1. GitHub Copilot** (Green terminal icon)
- **CLI Command**: Path to `gh copilot` command
- **Toggle**: Enable/disable Copilot
- **Best For**: Code generation, inline suggestions
- **Expandable**: Click to show API key and advanced settings

**2. Google Gemini** (Blue sparkles icon)
- **CLI Command**: Path to `gemini` CLI
- **Toggle**: Enable/disable Gemini  
- **Best For**: Questions, explanations, research
- **Expandable**: API configuration

**3. OpenAI** (Purple CPU icon)
- **API Key**: Your OpenAI API key
- **Toggle**: Enable/disable OpenAI
- **Best For**: Complex reasoning, GPT models
- **Expandable**: Model selection, temperature

**4. Ollama** (Orange server icon)
- **CLI Command**: Path to `ollama` command
- **Toggle**: Enable/disable Ollama
- **Best For**: Local models, privacy, offline work
- **Expandable**: Model management

### Smart Routing (Future Feature)
The system will automatically choose the best AI for each task:
- Copilot for code generation
- Gemini for questions
- OpenAI for complex reasoning
- Ollama for local/offline work

---

## Commands Tab

### Purpose
Create and manage custom CLI commands for common workflows.

### Custom Commands

**What You Can Save:**
- Command name (e.g., "deploy", "test-prod")
- Full command text (e.g., `npm run build && npm test`)
- Category (optional grouping)

**Why This Is Useful:**
- Store frequently used commands
- No need to memorize complex commands
- One-click execution of multi-step workflows
- Share commands across projects

**Example Commands:**
```
Name: Full Build
Command: swift build && swift test
Category: Development

Name: Git Push  
Command: git add . && git commit -m "Auto commit" && git push
Category: Git
```

---

## Projects Tab (Not Yet Implemented)

### Planned Features:
- Break down large projects into tasks
- Track progress visually
- Daily workflow (start/done/today)
- Remember where you left off
- Project switching

---

## Generate Tab (Not Yet Implemented)

### Planned Features:
- Natural language → code generation
- Connect to AI tools configured in AI Tools tab
- Learn your coding patterns
- Save generated code
- Refine with AI conversation

---

## Knowledge Tab (Not Yet Implemented)

### Planned Features:
- Auto-save notes and decisions
- Search everything
- Build knowledge over time
- Link notes to code/projects
- Export/import knowledge base

---

## How Data Flows

```
User Action → Agent Manager → Specific Agent → Output Panel
     ↓
  Tab View updates
     ↓
  UI reflects state
```

### Example: Clicking "Build"

1. **User**: Clicks "Build" button
2. **DashboardView**: Sets `isProcessing = true`
3. **Function**: Calls `runAction("build")`
4. **Agent Manager**: Receives request
5. **Builder Agent**: Executes `swift build`
6. **Output**: Result sent back to DashboardView
7. **UI Update**: Output panel shows results
8. **Done**: `isProcessing = false`, button re-enabled

### Example: Saving Configuration

1. **User**: Toggles Copilot enabled in AI Tools tab
2. **ConfigurationManager**: Updates `copilotEnabled` property
3. **Auto-save**: Changes written to `~/.mini/config.json`
4. **Persistence**: Configuration loaded on next app launch

---

## Key Concepts

### Agent Manager
- Central coordinator for all agents
- Keeps track of registered agents (builder, test, repo, memory)
- Routes requests to appropriate agents
- Manages agent lifecycle (start/stop)

### State Management
- `@StateObject`: Persists across view updates
- `@State`: Local view state (like form inputs)
- `@Published`: Notifies views of changes
- Observable pattern for reactive UI

### Async Operations
- All agent actions are asynchronous
- UI doesn't freeze during operations
- Progress indicators show activity
- Results appear when ready

---

## Current Limitations

1. **Agents Not Fully Implemented**: Most agents are placeholder shells
2. **No AI Integration Yet**: AI Tools config doesn't connect to actual APIs
3. **No Project Management**: Projects tab is placeholder
4. **No Code Generation**: Generate tab not built
5. **No Knowledge Base**: Knowledge tab not built
6. **No Persistence**: Configuration saves but not fully wired up

---

## Next Development Steps

### Phase 1: Core Agents
1. Implement BuilderAgent properly (Swift PM integration)
2. Implement TestAgent (parse test output)
3. Implement RepoAgent (full git operations)
4. Implement MemoryAgent (JSON storage)

### Phase 2: AI Integration
1. Wire up Copilot adapter
2. Wire up Gemini adapter  
3. Wire up OpenAI adapter
4. Wire up Ollama adapter
5. Implement smart routing

### Phase 3: Advanced Features
1. Project breakdown system
2. Code generation interface
3. Knowledge base with search
4. Command palette (Cmd+K)
5. Keyboard shortcuts

---

## Architecture

```
MiniDashboard (macOS App)
├── FlexibleTabView (Tab System)
│   ├── TabBar (Horizontal tabs)
│   ├── TabContentView (Current tab content)
│   └── TabManager (State management)
│
├── DashboardView (Main control panel)
│   ├── Header (Title + status)
│   ├── Sidebar (Agent list)
│   ├── Actions (Quick buttons)
│   ├── Commands (Input forms)
│   └── Output (Results panel)
│
├── ConfigurationView (AI Tools config)
│   ├── AIToolCard (Per-tool settings)
│   └── ConfigurationManager (Persistence)
│
├── MiniAgentCore (Framework)
│   ├── Agent (Protocol)
│   ├── AgentManager (Coordinator)
│   ├── Configuration (Settings)
│   └── Logger (Logging)
│
└── Agents (Implementations)
    ├── BuilderAgent
    ├── TestAgent
    ├── RepoAgent
    ├── MemoryAgent
    ├── GeneratorAgent
    ├── LanguageAgent
    └── WorkflowAgent
```

---

## User Data Storage

```
~/.mini/
├── config.json          # App configuration
│   ├── AI tool settings
│   ├── Custom commands
│   └── Preferences
│
├── projects/            # Project data (future)
│   └── [project-id]/
│       ├── tasks.json
│       ├── progress.json
│       └── notes.json
│
└── knowledge/           # Knowledge base (future)
    ├── notes.json
    └── index.json
```

---

## Summary

**What Works Now:**
- Browser-style tab system with drag-to-reorder
- Dashboard with agent status display
- Basic action buttons (build, test, status, memory)
- Input forms for git and memory operations
- Output panel for viewing results
- AI Tools configuration UI
- Professional SF Symbol icons

**What's Coming:**
- Full agent implementation
- AI tool integration
- Project management
- Code generation
- Knowledge base
- Smart routing
- Command palette

**Goal:**
Create a comprehensive development assistant that uses AI to help you build software without needing to remember commands, manage complexity, or lose track of large projects.
