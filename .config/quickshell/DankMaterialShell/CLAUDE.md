# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## AI Guidance

* Ignore GEMINI.md and GEMINI-*.md files
* After receiving tool results, carefully reflect on their quality and determine optimal next steps before proceeding. Use your thinking to plan and iterate based on this new information, and then take the best next action.
* For maximum efficiency, whenever you need to perform multiple independent operations, invoke all relevant tools simultaneously rather than sequentially.
* Before you finish, please verify your solution
* Do what has been asked; nothing more, nothing less.
* NEVER create files unless they're absolutely necessary for achieving your goal.
* ALWAYS prefer editing an existing file to creating a new one.
* NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.
* When you update or modify core context files, also update markdown documentation and memory bank
* When asked to commit changes, exclude CLAUDE.md and CLAUDE-*.md referenced memory bank system files from any commits.

## Memory Bank System

This project uses a structured memory bank system with specialized context files. Always check these files for relevant information before starting work:

### Core Context Files

* **CLAUDE-activeContext.md** - Current session state, goals, and progress (if exists)
* **CLAUDE-patterns.md** - Established code patterns and conventions (if exists)
* **CLAUDE-decisions.md** - Architecture decisions and rationale (if exists)
* **CLAUDE-troubleshooting.md** - Common issues and proven solutions (if exists)
* **CLAUDE-config-variables.md** - Configuration variables reference (if exists)
* **CLAUDE-temp.md** - Temporary scratch pad (only read when referenced)

**Important:** Always reference the active context file first to understand what's currently being worked on and maintain session continuity.

### Memory Bank System Backups

When asked to backup Memory Bank System files, you will copy the core context files above and @.claude settings directory to directory @/path/to/backup-directory. If files already exist in the backup directory, you will overwrite them.

## Project Overview

## Project Overview

This is a Quickshell-based desktop shell implementation with Material Design 3 dark theme. The shell provides a complete desktop environment experience with panels, widgets, and system integration services.

**Architecture**: Modular design with clean separation between UI components (Modules), system services (Services), and shared utilities (Common).

## Technology Stack

- **QML (Qt Modeling Language)** - Primary language for all UI components
- **Quickshell Framework** - QML-based framework for building desktop shells
- **Qt/QtQuick** - UI rendering and controls
- **Wayland** - Display server protocol
- **Matugen** - Dynamic theming system for wallpaper-based colors and system app theming

## Development Commands

Since this is a Quickshell-based project without traditional build configuration files, development typically involves:

```bash
# Run the shell (requires Quickshell to be installed)
quickshell -p shell.qml

# Or use the shorthand
qs -p .

# Code formatting and linting
qmlformat -i **/*.qml    # Format all QML files in place
qmllint **/*.qml         # Lint all QML files for syntax errors
```

## Architecture Overview

### Modular Structure

The shell follows a clean modular architecture reduced from 4,830 lines to ~250 lines in shell.qml:

```
shell.qml           # Main entry point (minimal orchestration)
├── Common/         # Shared resources
│   ├── Theme.qml   # Material Design 3 theme singleton
│   └── Utilities.js # Shared utility functions
├── Services/       # System integration singletons
│   ├── AudioService.qml
│   ├── NetworkService.qml
│   ├── BrightnessService.qml
│   └── [9 total services]
├── Modules/        # UI components
│   ├── TopBar.qml
│   ├── AppLauncher.qml
│   ├── ControlCenter.qml
│   └── [18 total modules]
└── Widgets/        # Reusable UI controls
    ├── DankIcon.qml
    ├── DankSlider.qml
    ├── DankToggle.qml
    ├── DankTabBar.qml
    ├── DankGridView.qml
    ├── DankListView.qml
    └── [6 total widgets]
```

### Component Organization

1. **Shell Entry Point** (`shell.qml`)
   - Minimal orchestration layer (~250 lines)
   - Imports and instantiates components
   - Handles global state and property bindings
   - Multi-monitor support using Quickshell's `Variants`

2. **Common/** - Shared resources
   - `Theme.qml` - Material Design 3 theme singleton with consistent colors, spacing, fonts
   - `Utilities.js` - Shared functions for workspace parsing, notifications, menu handling

3. **Services/** - System integration singletons
   - **Pattern**: All services use `Singleton` type with `id: root`
   - **Independence**: No cross-service dependencies
   - **Examples**: AudioService, NetworkService, BrightnessService, WeatherService
   - Services handle system commands, state management, and hardware integration

4. **Modules/** - UI components
   - **Full-screen components**: AppLauncher, ClipboardHistoryModal, ControlCenter
   - **Panel components**: TopBar, SystemTray, NotificationPopup
   - **Layout components**: WorkspaceSwitcher

5. **Widgets/** - Reusable UI controls
   - **DankIcon**: Centralized icon component with Material Design font integration
   - **DankSlider**: Enhanced slider with animations and smart detection
   - **DankToggle**: Consistent toggle switch component
   - **DankTabBar**: Unified tab bar implementation
   - **DankGridView**: Reusable grid view with adaptive columns
   - **DankListView**: Reusable list view with configurable styling

### Key Architectural Patterns

1. **Singleton Services Pattern**:
   ```qml
   import QtQuick
   import Quickshell
   import Quickshell.Io
   pragma Singleton
   pragma ComponentBehavior: Bound

   Singleton {
       id: root
       
       property type value: defaultValue
       
       function performAction() { /* implementation */ }
   }
   ```

2. **Smart Feature Detection**: Services detect system capabilities:
   ```qml
   property bool featureAvailable: false
   // Auto-hide UI elements when features unavailable
   visible: ServiceName.featureAvailable
   ```

3. **Property Bindings**: Reactive UI updates through property binding
4. **Material Design Theming**: Consistent use of Theme singleton throughout

### Important Components

- **ControlCenter**: System controls (WiFi, Bluetooth, brightness, volume, night mode)
- **AppLauncher**: Full-featured app grid/list with 93+ applications, search, categories
- **ClipboardHistoryModal**: Complete clipboard management with cliphist integration
- **TopBar**: Per-monitor panels with workspace switching, clock, system tray
- **System App Theming**: Automatic GTK and Qt application theming using matugen templates

#### Key Widgets

- **DankIcon**: Centralized icon component with automatic Material Design font detection
- **DankSlider**: Enhanced slider with animations and smart detection
- **DankToggle**: Consistent toggle switch component
- **DankTabBar**: Unified tab bar implementation
- **DankGridView**: Reusable grid view with adaptive columns
- **DankListView**: Reusable list view with configurable styling

## Code Conventions

### QML Style Guidelines

1. **Structure and Formatting**:
   - Use 4-space indentation
   - `id` should be the first property
   - Properties before signal handlers before child components
   - Prefer property bindings over imperative code
   - **IMPORTANT**: Be very conservative with comments - add comments only when absolutely necessary for understanding complex logic

2. **Naming Conventions**:
   - **Services**: Use `Singleton` type with `id: root`
   - **Components**: Use descriptive names (e.g., `DankSlider`, `TopBar`)
   - **Properties**: camelCase for properties, PascalCase for types

3. **Null-Safe Operations**:
   - **Do NOT use** `?.` operator (not supported by qmlformat)
   - **Use** `object && object.property` instead of `object?.property`
   - **Example**: `activePlayer && activePlayer.trackTitle` instead of `activePlayer?.trackTitle`

4. **Component Structure**:
   ```qml
   // For regular components
   Item {
       id: root
       
       property type name: value
       
       signal customSignal(type param)
       
       onSignal: { /* handler */ }
       
       Component { /* children */ }
   }
   
   // For services (singletons)
   Singleton {
       id: root
       
       property bool featureAvailable: false
       property type currentValue: defaultValue
       
       function performAction(param) { /* implementation */ }
   }
   ```

### Import Guidelines

1. **Standard Import Order**:
   ```qml
   import QtQuick
   import QtQuick.Controls  // If needed
   import Quickshell
   import Quickshell.Widgets
   import Quickshell.Io     // For Process, FileView
   import qs.Common         // For Theme, utilities
   import qs.Services       // For service access
   import qs.Widgets        // For reusable widgets (DankIcon, etc.)
   ```

2. **Service Dependencies**:
   - Services should NOT import other services
   - Modules and Widgets can import and use services via property bindings
   - Use `Theme.propertyName` for consistent styling
   - Use `DankIcon { name: "icon_name" }` for all icons instead of manual Text components

### Component Development Patterns

1. **Smart Feature Detection**:
   ```qml
   // In services - detect capabilities
   property bool brightnessAvailable: false
   
   // In modules - adapt UI accordingly
   DankSlider {
       visible: BrightnessService.brightnessAvailable
       enabled: BrightnessService.brightnessAvailable
       value: BrightnessService.brightnessLevel
   }
   ```

2. **Reusable Components**:
   - Create reusable widgets for common patterns (like DankSlider)
   - Use configurable properties for different use cases
   - Include proper signal handling with unique names (avoid `valueChanged`)

3. **Service Integration**:
   - Services expose properties and functions
   - Modules and Widgets bind to service properties for reactive updates
   - Use service functions for actions: `ServiceName.performAction(value)`
   - **CRITICAL**: DO NOT create wrapper functions for everything - bind directly to underlying APIs when possible
   - Example: Use `BluetoothService.adapter.discovering = true` instead of `BluetoothService.startScan()`
   - Example: Use `device.connect()` directly instead of `BluetoothService.connect(device.address)`

### Error Handling and Debugging

1. **Console Logging**:
   ```qml
   // Use appropriate log levels
   console.log("Info message")           // General info
   console.warn("Warning message")       // Warnings
   console.error("Error message")        // Errors
   
   // Include context in service operations
   onExited: (exitCode) => {
       if (exitCode !== 0) {
           console.warn("Service failed:", serviceName, "exit code:", exitCode)
       }
   }
   ```

2. **Graceful Degradation**:
   - Always check feature availability before showing UI
   - Provide fallbacks for missing system tools
   - Use `visible` and `enabled` properties appropriately

## Multi-Monitor Support

The shell uses Quickshell's `Variants` pattern for multi-monitor support:
- Each connected monitor gets its own top bar instance
- Workspace switchers are per-display and Niri-aware
- Monitors are automatically detected by screen name (DP-1, DP-2, etc.)
- Workspaces are dynamically synchronized with Niri's per-output workspaces

## Common Development Tasks

### Testing and Validation

When modifying the shell:
1. **Test changes**: `qs -p .` (automatic reload on file changes)
2. **Code quality**: Run `qmlformat -i **/*.qml` and `qmllint **/*.qml` to ensure proper formatting and syntax
3. **Performance**: Ensure animations remain smooth (60 FPS target)
4. **Theming**: Use `Theme.propertyName` for Material Design 3 consistency
5. **Wayland compatibility**: Test on Wayland session
6. **Multi-monitor**: Verify behavior with multiple displays
7. **Feature detection**: Test on systems with/without required tools

### Adding New Modules

1. **Create component**:
   ```bash
   # Create new module file
   touch Modules/NewModule.qml
   ```

2. **Follow module patterns**:
   - Use `Theme.propertyName` for styling
   - Import `qs.Common` and `qs.Services` as needed
   - Import `qs.Widgets` for reusable components
   - Bind to service properties for reactive updates
   - Consider per-screen vs global behavior
   - Use `DankIcon` for icons instead of manual Text components

3. **Integration in shell.qml**:
   ```qml
   NewModule {
       id: newModule
       // Configure properties
   }
   ```

### Adding New Widgets

1. **Create component**:
   ```bash
   # Create new widget file
   touch Widgets/NewWidget.qml
   ```

2. **Follow widget patterns**:
   - Use `Theme.propertyName` for styling
   - Import `qs.Common` for theming
   - Focus on reusability and composition
   - Keep widgets simple and focused
   - Use `DankIcon` for icons instead of manual Text components

### Adding New Services

1. **Create service**:
   ```qml
   // Services/NewService.qml
   import QtQuick
   import Quickshell
   import Quickshell.Io
   pragma Singleton
   pragma ComponentBehavior: Bound

   Singleton {
       id: root
       
       property bool featureAvailable: false
       property type currentValue: defaultValue
       
       function performAction(param) {
           // Implementation
       }
   }
   ```

2. **Use in modules**:
   ```qml
   // In module files
   property alias serviceValue: NewService.currentValue
   
   SomeControl {
       visible: NewService.featureAvailable
       enabled: NewService.featureAvailable
       onTriggered: NewService.performAction(value)
   }
   ```

### Debugging Common Issues

1. **Import errors**: Check import paths
2. **Singleton conflicts**: Ensure services use `Singleton` type with `id: root`
3. **Property binding issues**: Use property aliases for reactive updates
4. **Process failures**: Check system tool availability and command syntax
5. **Theme inconsistencies**: Always use `Theme.propertyName` instead of hardcoded values

### Best Practices Summary

- **Modularity**: Keep components focused and independent
- **Reusability**: Create reusable components for common patterns using Widgets/
- **Responsiveness**: Use property bindings for reactive UI
- **Robustness**: Implement feature detection and graceful degradation
- **Consistency**: Follow Material Design 3 principles via Theme singleton
- **Performance**: Minimize expensive operations and use appropriate data structures
- **Icon Management**: Use `DankIcon` for all icons instead of manual Text components
- **Widget System**: Leverage existing widgets (DankSlider, DankToggle, etc.) for consistency
- **NO WRAPPER HELL**: Avoid creating unnecessary wrapper functions - bind directly to underlying APIs for better reactivity and performance

### Common Widget Patterns

1. **Icons**: Always use `DankIcon { name: "icon_name" }` instead of `Text { font.family: Theme.iconFont }`
2. **Sliders**: Use `DankSlider` for consistent styling and behavior
3. **Toggles**: Use `DankToggle` for switches and checkboxes
4. **Tab Bars**: Use `DankTabBar` for tabbed interfaces
5. **Lists**: Use `DankListView` for scrollable lists
6. **Grids**: Use `DankGridView` for grid layouts
