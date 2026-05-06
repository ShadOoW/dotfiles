# Codebase Pattern Fingerprinting — Production-Ready Auto-Discovery

Extract your codebase's implicit style guide through statistical analysis. This fingerprint ensures new code matches existing conventions perfectly — whether AI-generated or human-written.

---

## Quick Start

**First run:**

```
Fingerprint the codebase
```

**Continue building coverage:**

```
Continue fingerprinting
```

**Check progress:**

```
Show fingerprinting progress
```

**Targeted analysis:**

```
Fingerprint: src/services/

Hint: We always validate permissions before Parse queries
```

---

## What This Creates

**File location:** `$HOME/.fingerprint/{PROJECT_NAME}_CODEBASE_PATTERNS.md`

Where `{PROJECT_NAME}` is derived from your git repository root (e.g., if your repo is `/path/to/myapp`, the file will be `$HOME/.fingerprint/MYAPP_CODEBASE_PATTERNS.md`).

**Works from anywhere:** Uses `git rev-parse --show-toplevel` to find the project root, so it doesn't matter if you run this from the project root, a subdirectory like `web/code`, or via different AI agent CLIs (Claude Code, OpenCode, etc.).

The pattern file has **three sections** for different use cases:

### 📋 SUMMARY (2 min read)

Human entry point — verify patterns are correct at a glance

### 🔒 MANUAL OVERRIDES + 🎯 QUICK REFERENCE (code generation)

What LLMs read before writing code — templates, rules, anti-patterns

### 📊 DETAILED ANALYSIS (code review)

Complete statistical breakdown — what LLMs use for pattern-matched reviews

---

## How It Works

### Auto-Discovery with Intelligent Sampling

**You don't select files manually.** The prompt:

1. **Scans** your codebase (finds all `.ts`/`.tsx` files)
2. **Categorizes** files (components, hooks, services, models, utils, tests)
3. **Samples** 15-20 files per run across categories
4. **Tracks** what's been analyzed (`$HOME/.fingerprint/{PROJECT_NAME}.json`)
5. **Eventually covers** everything if run enough times

**Sampling strategy:**

- Prioritize unanalyzed files
- Ensure representation across all modules
- Prefer larger/complex files first (more signal)
- Later passes fill gaps and validate patterns

### Pattern Extraction

For each file analyzed:

**Naming analysis:**

- Extract all variable/function/component/type names
- Calculate length distributions (median, p90)
- Identify prefixes/suffixes (handle*, use*, is\*, Props, Data)
- Detect abbreviation patterns (btn vs button, err vs error)
- Determine casing conventions

**Code structure:**

- File organization (imports order, section layout)
- Function size (lines per function)
- Component structure (hooks → handlers → render)
- Nesting depth, complexity patterns
- When logic is extracted vs inlined

**TypeScript patterns:**

- interface vs type usage (when each is used)
- Generic usage frequency
- Type assertion style (as vs type guards)
- Type location (colocated vs central)
- Type reuse patterns

**React patterns (if applicable):**

- Component structure and ordering
- Hook usage (useState vs useReducer, dependency arrays)
- State management approach
- Props patterns

**Backend patterns (if applicable):**

- Parse query structure (select, include, optional chaining)
- MongoDB query patterns
- Service function signatures
- Error handling approach

**Comments:**

- Density (comments per 100 lines)
- Style (full sentences vs fragments, punctuation, tone)
- What's commented (why vs what)
- JSDoc/TSDoc frequency

**Error handling:**

- How errors are thrown
- Try/catch patterns
- Error propagation (throw vs return tuples)
- Async error handling

### Pattern Confidence Tracking

- 🔴 **Low (1-5 samples):** Observed but needs more data
- 🟡 **Medium (6-15 samples):** Likely representative
- 🟢 **High (16+ samples):** Well-established

### Conflict Detection

When new files contradict existing patterns:

```markdown
⚠️ **CONFLICT**
**Existing:** 70% use `type`, 30% use `interface`
**New data:** Recent files show 60% `interface`, 40% `type`
**Action:** Pattern is shifting. Flag conflict in pattern file and continue.
```

---

## Generated Pattern File Structure

### Section 1: SUMMARY (Human Verification Entry Point)

**Purpose:** Verify patterns are correct in 2-5 minutes

**Contains:**

- Files analyzed, coverage %
- Key patterns (one-line per category)
- Active conflicts
- Manual overrides count
- What needs more samples

**Example:**

```markdown
## 📋 SUMMARY

**Coverage:** 45/120 files (38%) | **Runs:** 3 | **Updated:** 2025-05-05

**High Confidence Patterns (🟢):**

- Naming: camelCase, median 14 chars, no abbrev except err/idx/btn
- Comments: Sparse (1 per 20 lines), terse fragments, explain "why"
- TypeScript: interface for props, type for utilities
- Errors: throw in services, catch + log in components
- Parse: optional chaining everywhere `result?.get()`

**Medium Confidence (🟡 — needs more samples):**

- Hooks: useState dominant (15 samples)
- Service patterns (12 samples)

**Conflicts:** None

**Manual Overrides:** 2 active
```

---

### Section 2: MANUAL OVERRIDES (Human + LLM Authority)

**Purpose:** Rules that override auto-discovered patterns

**Format:**

```markdown
## 🔒 MANUAL OVERRIDES

_Human-maintained. Takes precedence over auto-discovered patterns._

### TypeScript: Interface vs Type

**Rule:** Use `interface` for public APIs, `type` for utilities
**Reason:** Team decision Jan 2025, legacy code mostly uses `type`
**Overrides:** Auto-discovered 60% interface, 40% type split

### Parse Query Safety

**Rule:** Always use optional chaining for Parse results
**Reason:** Prevents null reference crashes
**Overrides:** Auto-discovered 80% optional chaining, 20% if-checks
```

**When to add:**

- Team decided on a standard that isn't statistically dominant yet
- Legacy code has anti-patterns being phased out
- Domain-specific requirements not obvious from code

---

### Section 3: QUICK REFERENCE (LLM Code Generation)

**Purpose:** Templates and rules for writing new code

**Format:**

````markdown
## 🎯 QUICK REFERENCE

_Read this before generating code_

### Component Template

```typescript
import React, { useState } from 'react'
import { ServiceName } from '@/services'
import { ComponentNameProps } from './types'

export default function ComponentName({ prop }: ComponentNameProps) {
  // hooks first
  const [state, setState] = useState()

  // handlers second
  const handleAction = () => {}

  // render
  return <div>...</div>
}
```
````

### Service Template

```typescript
export async function fetchResource(id: string): Promise<Resource> {
  if (!id) throw new Error('ID required');

  const query = new Parse.Query('Resource');
  query.select('field1', 'field2');

  const result = await query.get(id);
  return result?.toJSON();
}
```

### Naming Quick Rules

- **Variables:** camelCase, 10-15 chars, avoid abbrev (except err/idx/btn)
- **Functions:** camelCase, 15-20 chars, prefix handle*/fetch*/validate\*
- **Components:** PascalCase, 10-15 chars, no prefix/suffix
- **Types:** PascalCase, suffix Props for component props, Data for API

### Import Order Template

```typescript
// 1. React/external
import React from 'react';
import { parseLibrary } from 'library';

// 2. Internal modules
import { service } from '@/services';

// 3. Types
import { Props } from './types';

// 4. Styles (if any)
import './styles.css';
```

### Comment Rules

- **Density:** ~1 per 20 lines (sparse)
- **Style:** Terse fragments, no punctuation, lowercase
- **Content:** Explain "why" not "what"
- **No JSDoc** unless public API utility

**Good:**

```typescript
// refresh needed after permission change
// fallback for legacy data format
```

**Bad:**

```typescript
// Set the user state to the new user data
// This function fetches the user
```

### Error Handling Template

```typescript
// Services: throw errors
export async function getUser(id: string) {
  if (!id) throw new Error('User ID required');
  // ...
}

// Components: catch and set state
try {
  await getUser(id);
} catch (err) {
  console.error('Failed to fetch user:', err);
  setError(err.message);
}
```

### Anti-Patterns (NEVER DO)

❌ **Verbose names**

```typescript
// Bad
const handleUserDataProcessingAndValidation = () => {};
// Good (median 18 chars)
const handleUserProcess = () => {};
```

❌ **Restating code in comments**

```typescript
// Bad
// Set the user state to the new user
setUser(newUser);
// Good (explain why if non-obvious)
// cache invalidated, fetch required
setUser(newUser);
```

❌ **Error tuples (legacy pattern)**

```typescript
// Bad (old code)
return { data, error };
// Good (current standard)
throw new Error('message');
```

❌ **Bare type assertions**

```typescript
// Bad
const user = data as User;
// Good
const user = data?.user; // optional chaining
```

❌ **JSDoc everywhere**

```typescript
// Bad
/**
 * Handles user click event
 * @param event - The click event
 */
const handleClick = (event) => {};
// Good (no JSDoc for internal functions)
const handleClick = (event) => {};
```

````

---

### Section 4: DETAILED ANALYSIS (LLM Code Review)

**Purpose:** Complete statistical reference for pattern-matched reviews

**Format:** Collapsible sections with full data

```markdown
## 📊 DETAILED ANALYSIS

*Complete statistical breakdown. Used for code reviews and validation.*

**Coverage Status:**
✅ Components (15/~30) — 50%
✅ Services (12/~20) — 60%
🟡 Hooks (5/~15) — 33% (needs more)
❌ Models (0/~10) — 0% (not analyzed)

---

<details>
<summary><b>Naming Patterns</b> — 45 files analyzed</summary>

### Variables
**Sample:** 45 files | **Confidence:** 🟢 High

**Pattern:** camelCase, median 12 chars, p90 18 chars

**Abbreviations:** Only standard ones
- `err` for error (98% of error variables)
- `idx` for index (95% of index variables)
- `btn` for button (90% of button variables)
- No other abbreviations observed

**Length Distribution:**
- 4-8 chars: 15%
- 9-12 chars: 45% ← median range
- 13-16 chars: 30%
- 17+ chars: 10%

**Examples:**
- `userData` (src/hooks/useAuth.ts:23)
- `isLoading` (src/components/UserList.tsx:45)
- `errorMessage` (src/services/user.ts:67)
- `currentUser` (src/contexts/AuthContext.tsx:12)

---

### Functions
**Sample:** 45 files | **Confidence:** 🟢 High

**Pattern:** camelCase, median 18 chars, p90 28 chars

**Prefix Patterns:**
- `handle*` — 65% of event handlers
  - Examples: handleClick, handleSubmit, handleUserSelect
- `fetch*` — 80% of API calls
  - Examples: fetchUserData, fetchOrders, fetchSettings
- `validate*` — 90% of validation functions
  - Examples: validateEmail, validateForm, validateInput

**Length Distribution:**
- 8-12 chars: 10%
- 13-18 chars: 50% ← median range
- 19-25 chars: 30%
- 26+ chars: 10%

**Examples:**
- `handleUserClick` (src/components/UserList.tsx:45) — 15 chars
- `fetchUserData` (src/services/user.ts:23) — 13 chars
- `validateEmail` (src/utils/validation.ts:12) — 13 chars

---

### Components
**Sample:** 15 files | **Confidence:** 🟡 Medium

**Pattern:** PascalCase, median 12 chars, no prefix/suffix

**No common prefixes/suffixes observed:**
- 0% use `Base*` or `*Container` or `*View`
- 100% use simple nouns

**Length Distribution:**
- 6-10 chars: 40%
- 11-15 chars: 50% ← median range
- 16+ chars: 10%

**Examples:**
- `UserList` (src/components/UserList.tsx) — 8 chars
- `LoginForm` (src/components/LoginForm.tsx) — 9 chars
- `Header` (src/components/Header.tsx) — 6 chars
- `ProfileCard` (src/components/ProfileCard.tsx) — 11 chars

---

### Types/Interfaces
**Sample:** 25 files | **Confidence:** 🟢 High

**Pattern:** PascalCase, suffix `Props` for component props, `Data` for API responses

**Suffix Patterns:**
- `*Props` — 95% of component prop types
  - Examples: UserListProps, LoginFormProps
- `*Data` — 85% of API response types
  - Examples: UserData, OrderData
- No suffix — 70% of domain model types
  - Examples: User, Order, Product

**Examples:**
- `UserListProps` (src/components/UserList.tsx:5)
- `UserData` (src/types/user.ts:3)
- `User` (src/models/User.ts:1)
- `ApiResponse<T>` (src/types/api.ts:8)

</details>

---

<details>
<summary><b>TypeScript Patterns</b> — 35 files analyzed</summary>

### Interface vs Type
**Sample:** 35 files | **Confidence:** 🟢 High

⚠️ **Manual override exists — see MANUAL OVERRIDES section**

**Auto-discovered pattern:**
- 60% `interface` (up from 30% in early samples)
- 40% `type` (down from 70%)
- **Pattern is shifting:** Recent files prefer `interface`

**Current usage:**
- `interface` — Component props, public APIs
- `type` — Utility types, unions, mapped types

**Examples:**
```typescript
// Interface (component props)
interface UserListProps {
  users: User[]
  onSelect: (id: string) => void
}

// Type (utility)
type ApiResponse<T> = {
  data: T
  error?: string
}

// Type (union)
type Status = 'idle' | 'loading' | 'success' | 'error'
````

---

### Generic Usage

**Sample:** 45 files | **Confidence:** 🟢 High

**Pattern:** Used sparingly (12% of functions), mostly for API wrappers and utilities

**Where generics are used:**

- API response wrappers: `ApiResponse<T>`
- Data fetching: `fetchData<T>(url: string): Promise<T>`
- Array utilities: `unique<T>(arr: T[]): T[]`

**Where generics are NOT used:**

- React components (0% use generics)
- Service functions (8% use generics)
- Simple utilities (5% use generics)

**Examples:**

```typescript
// API wrapper
async function fetchData<T>(url: string): Promise<T> {
  const response = await fetch(url);
  return response.json();
}

// Utility
function unique<T>(arr: T[]): T[] {
  return [...new Set(arr)];
}
```

---

### Type Location Strategy

**Sample:** 45 files | **Confidence:** 🟢 High

**Pattern:**

1. **Colocated** — Default (95% of cases)
2. **Central** — When used in 3+ files (5% of cases)

**Colocated examples:**

```typescript
// src/components/UserList.tsx
interface UserListProps { ... }
export default function UserList(props: UserListProps) { ... }
```

**Central examples:**

```typescript
// src/types/api.ts (used in 15+ files)
export type ApiResponse<T> = { data: T; error?: string }

// src/types/user.ts (used in 8+ files)
export interface User { id: string; name: string; ... }
```

**Threshold observed:** Types move to `src/types/` when used in 3+ files

</details>

---

<details>
<summary><b>React Component Patterns</b> — 15 files analyzed</summary>

### Component Structure

**Sample:** 15 files | **Confidence:** 🟡 Medium

**Pattern:** Hooks → Handlers → Render

**Typical structure:**

```typescript
export default function Component({ props }: ComponentProps) {
  // 1. Hooks (useState, useEffect, custom hooks)
  const [state, setState] = useState()
  const { data } = useCustomHook()

  // 2. Handlers
  const handleClick = () => {}
  const handleSubmit = () => {}

  // 3. Render (no separate early returns or render functions)
  return (
    <div>...</div>
  )
}
```

**Component size:**

- Median: 85 lines
- P90: 150 lines
- Max observed: 220 lines
- Recommendation: Extract when >150 lines

**No separation observed:**

- 0% use separate render functions
- 0% use render props pattern
- 100% inline JSX directly

---

### Hook Usage

**Sample:** 15 components, 5 custom hooks | **Confidence:** 🟡 Medium

**Pattern:**

- `useState` — 90% of state management
- `useReducer` — 5% (only for complex state)
- `useEffect` — 70% of components (mostly data fetching)
- Custom hooks — Prefixed `use*`, extracted when reused 2+ times

**Dependency arrays:**

- 100% exhaustive (ESLint enforced)
- 0% disabled with `// eslint-disable`

**Custom hook pattern:**

```typescript
// src/hooks/useAuth.ts
export function useAuth() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // fetch user
  }, []);

  return { user, loading };
}
```

**Extraction threshold:** Logic extracted to custom hook when:

- Used in 2+ components, OR
- State logic exceeds 20 lines

---

### State Management

**Sample:** 15 files | **Confidence:** 🟡 Medium

**Pattern:** Local `useState` for component state, no global state library

**No global state detected:**

- 0% use Redux, Zustand, or similar
- 0% use React Context for state (only for DI)
- 100% use local state

**State colocation:**

- State lives in component that owns it
- Passed down via props (no prop drilling beyond 2 levels observed)

**Examples:**

```typescript
// Local state
const [users, setUsers] = useState<User[]>([]);
const [loading, setLoading] = useState(false);

// Context (dependency injection, not state)
const api = useContext(ApiContext); // service instance
```

</details>

---

<details>
<summary><b>Backend Patterns</b> — 12 files analyzed</summary>

### Parse Query Patterns

**Sample:** 12 service files | **Confidence:** 🟡 Medium

**Pattern:**

1. Always use `.select()` for field projection
2. Optional chaining for results: `result?.get('field')`
3. Include related objects with `.include()`

**Field selection:**

```typescript
// 100% of queries use .select()
const query = new Parse.Query('User');
query.select('id', 'name', 'email'); // explicit fields
const result = await query.get(id);
```

**Result access:**

```typescript
// 80% use optional chaining
const name = result?.get('name');
const email = result?.get('email');

// 20% use if-check (legacy)
if (result) {
  const name = result.get('name');
}
```

**Related objects:**

```typescript
// 90% of multi-table queries use .include()
const query = new Parse.Query('Order');
query.include('user');
query.include('items');
```

---

### Service Function Patterns

**Sample:** 12 files | **Confidence:** 🟡 Medium

**Pattern:** Async functions, return data directly, throw on error

**Signature pattern:**

```typescript
export async function getResource(id: string): Promise<Resource> {
  // Validate input
  if (!id) throw new Error('ID required');

  // Query
  const query = new Parse.Query('Resource');
  const result = await query.get(id);

  // Return data
  return result?.toJSON();
}
```

**Error handling:** 100% throw errors (no error tuples)

**Return pattern:** 100% return data directly (not wrapped in objects)

</details>

---

<details>
<summary><b>Comment Patterns</b> — 45 files analyzed</summary>

### Comment Density

**Sample:** 45 files | **Confidence:** 🟢 High

**Pattern:** Sparse — approximately 1 comment per 20 lines

**Measured density:**

- Components: 1 comment / 22 lines
- Services: 1 comment / 18 lines
- Utils: 1 comment / 25 lines

**Total code analyzed:** ~3,200 lines  
**Total comments:** ~155 comments

---

### Comment Style

**Sample:** 155 comments analyzed | **Confidence:** 🟢 High

**Pattern:** Terse fragments, no punctuation, lowercase start

**Characteristics:**

- 95% are fragments (not full sentences)
- 98% start lowercase
- 99% no ending punctuation
- 100% single-line (`//` not `/* */`)

**Examples (actual from codebase):**

```typescript
// fetch user data
// handle error case
// update local state
// refresh needed after permission change
// fallback for legacy data format
// cache invalidated
```

**NOT seen:**

```typescript
// This function fetches the user data from the API
// Handle the error case by setting error state
// Update the local state with the new user
```

---

### Comment Content

**Sample:** 155 comments | **Confidence:** 🟢 High

**Pattern:** Explain "why" not "what"

**Why (85% of comments):**

```typescript
// refresh needed after permission change
// workaround for API bug #123
// fallback for legacy data format
```

**What (15% of comments, mostly TODOs):**

```typescript
// TODO: add validation
// fetch user data
```

---

### JSDoc/TSDoc

**Sample:** 45 files | **Confidence:** 🟢 High

**Pattern:** Rare (5% of functions), only for public API utilities

**Where JSDoc is used:**

- Public utility functions in `src/utils/` (50% have JSDoc)
- Exported library functions (80% have JSDoc)
- React components (0% have JSDoc)
- Service functions (0% have JSDoc)

**Example:**

```typescript
// Public util (has JSDoc)
/**
 * Formats a date string to ISO format
 */
export function formatDate(date: Date): string { ... }

// Component (no JSDoc)
export default function UserList({ users }: Props) { ... }

// Service (no JSDoc)
export async function getUser(id: string) { ... }
```

</details>

---

<details>
<summary><b>Code Structure</b> — 45 files analyzed</summary>

### File Size Distribution

**Sample:** 45 files | **Confidence:** 🟢 High

**Components:**

- Median: 85 lines
- P90: 150 lines
- Max: 220 lines

**Services:**

- Median: 120 lines
- P90: 200 lines
- Max: 280 lines

**Utils:**

- Median: 45 lines
- P90: 80 lines
- Max: 150 lines

---

### Function Size

**Sample:** ~280 functions | **Confidence:** 🟢 High

**Pattern:** Median 12 lines, p90 28 lines

**Distribution:**

- 1-5 lines: 25%
- 6-12 lines: 45% ← median range
- 13-20 lines: 20%
- 21-30 lines: 8%
- 31+ lines: 2%

**Extraction threshold observed:**

- Functions extracted when >30 lines OR
- Logic is reused 2+ times

---

### Nesting Depth

**Sample:** 45 files | **Confidence:** 🟢 High

**Pattern:** Max 3 levels, early returns preferred

**Max nesting observed:** 3 levels (rare, only 5% of functions)

**Typical patterns:**

```typescript
// Early return (preferred)
function process(data) {
  if (!data) return null;
  if (!data.valid) return null;

  return transform(data);
}

// Nested (avoided)
function process(data) {
  if (data) {
    if (data.valid) {
      return transform(data);
    }
  }
  return null;
}
```

</details>

---

<details>
<summary><b>Error Handling</b> — 35 files analyzed</summary>

### Pattern

**Sample:** 35 files | **Confidence:** 🟢 High

**Service layer:** Throw errors  
**Component layer:** Catch and log

**Service pattern (100% of services):**

```typescript
export async function getUser(id: string): Promise<User> {
  if (!id) throw new Error('User ID required');

  const query = new Parse.Query('User');
  const result = await query.get(id);

  if (!result) throw new Error('User not found');

  return result.toJSON();
}
```

**Component pattern (90% of components):**

```typescript
try {
  const user = await getUser(id);
  setUser(user);
} catch (err) {
  console.error('Failed to fetch user:', err);
  setError(err.message);
}
```

**Error types:**

- 95% use built-in `Error` class
- 5% use custom error classes
- 0% use error codes/enums

**Async error handling:**

- 80% use try/catch
- 20% use `.catch()` (mostly in React effects)

</details>

---

<details>
<summary><b>Import/Export Patterns</b> — 45 files analyzed</summary>

### Import Order

**Sample:** 45 files | **Confidence:** 🟢 High

**Pattern:** React/external → Internal → Types → Styles

**Observed structure (95% of files):**

```typescript
// 1. React/external libraries
import React, { useState } from 'react';
import { parseLibrary } from 'library';

// [blank line]

// 2. Internal modules
import { userService } from '@/services';
import { formatDate } from '@/utils';

// [blank line]

// 3. Types
import { User, UserProps } from './types';

// [blank line]

// 4. Styles (if any)
import './styles.css';
```

**Blank lines:** 98% of files have blank lines between groups

---

### Export Patterns

**Sample:** 45 files | **Confidence:** 🟢 High

**Components:**

- 100% use default export
- 0% use named export

**Utilities/Services:**

- 100% use named export
- 0% use default export

**Examples:**

```typescript
// Component
export default function UserList() { ... }

// Service
export async function getUser() { ... }
export async function updateUser() { ... }

// Util
export function formatDate() { ... }
export function parseDate() { ... }
```

</details>

---

## ⚠️ ANTI-PATTERNS

_Patterns observed in legacy code — DO NOT replicate_

### Error Tuples (Legacy)

**Found in:** 3 older service files  
**Pattern:** `return { data, error }`  
**Correct pattern:** Throw errors (see Error Handling)

**Don't:**

```typescript
async function getUser(id) {
  try {
    const user = await query.get(id);
    return { data: user, error: null };
  } catch (err) {
    return { data: null, error: err };
  }
}
```

**Do:**

```typescript
async function getUser(id) {
  const user = await query.get(id);
  return user;
}
```

---

### Verbose Naming (Legacy)

**Found in:** 2 older components  
**Pattern:** Names exceeding p90 significantly  
**Correct pattern:** Follow median length

**Don't:**

```typescript
const handleUserDataProcessingAndValidation = () => {};
const currentlyAuthenticatedUserData = {};
```

**Do:**

```typescript
const handleUserProcess = () => {};
const currentUser = {};
```

---

### JSDoc Overuse (Legacy)

**Found in:** 3 older files  
**Pattern:** JSDoc on every function  
**Correct pattern:** JSDoc only on public utils

**Don't:**

```typescript
/**
 * Handles the user click event
 * @param event - The click event object
 */
const handleClick = (event) => {};
```

**Do:**

```typescript
const handleClick = (event) => {};
```

---

## CONFIDENCE KEY

🟢 **High (16+ samples)** — Well-established, ready for enforcement  
🟡 **Medium (6-15 samples)** — Likely representative, use with caution  
🔴 **Low (1-5 samples)** — Initial observation, needs more data

---

````

---

## Implementation Details

### State Tracking

The prompt maintains `$HOME/.fingerprint/{PROJECT_NAME}.json`:

```json
{
  "analyzed_files": [
    "src/components/UserList.tsx",
    "src/services/user.ts",
    "..."
  ],
  "run_count": 3,
  "last_updated": "2025-05-05T10:30:00Z",
  "file_counts": {
    "components": 15,
    "services": 12,
    "hooks": 5,
    "utils": 10,
    "models": 0,
    "tests": 3
  }
}
````

### Sampling Algorithm

**Run 1-3:** Broad sampling (5 components, 5 services, 3 hooks, 2 utils)  
**Run 4-8:** Fill gaps (focus on categories with low samples)  
**Run 9+:** Validate patterns (sample remaining files, check consistency)

**Selection criteria per run:**

1. Filter out already-analyzed files
2. Group remaining by category
3. Sample N per category (prioritize low-sample categories)
4. Within category, prefer larger files (>100 lines) first

### Pattern Update Logic

**First data point:**

```markdown
### Function Naming

**Sample:** 5 files | **Confidence:** 🔴 Low
**Pattern:** camelCase, median 16 chars
```

**Update (confirms pattern):**

```markdown
### Function Naming

**Sample:** 5 → 18 files | **Confidence:** 🟡 Medium
**Pattern:** camelCase, median 16 chars
```

**Update (refines pattern):**

```markdown
### Function Naming

**Sample:** 18 → 32 files | **Confidence:** 🟢 High
**Pattern:** camelCase, median 16 → 18 chars
**Refinement:** Median increased with more samples
```

**Update (detects conflict):**

```markdown
⚠️ **CONFLICT DETECTED**
**Sample:** 32 → 45 files
**Previous:** 60% interface, 40% type
**Current:** 50% interface, 50% type
**Status:** Pattern is shifting, recommend manual override
```

### Progress Reporting

After each run:

```markdown
## Fingerprinting Run 3 Complete

**Analyzed:** 15 new files (45 total, 38% coverage)

**Categories sampled this run:**

- Components: 5 files (15 total, 🟡 medium confidence)
- Services: 5 files (12 total, 🟡 medium confidence)
- Hooks: 3 files (5 total, 🔴 low confidence)
- Utils: 2 files (8 total, 🔴 low confidence)

**New patterns discovered:**

- Parse query patterns (optional chaining dominant)
- Service error handling (throw, not tuples)

**Patterns confirmed:**

- Naming conventions (still consistent)
- Comment style (still sparse/terse)

**Conflicts detected:**

- None

**Next run should prioritize:**

- Hooks (only 5 samples, need 11 more for medium confidence)
- Models (0 samples, need to start)
```

---

## Execution Protocol

**Non-interactive mode:** Execute all steps to completion in a single run. Do not use todo lists as checkpoints. Do not pause after partial completion. Write all output files without interruption.

### Command: "Fingerprint the codebase"

> ⚠️ **Important:** Never use `~` in bash commands — always use `$HOME`. The tilde (`~`) may resolve incorrectly in headless agent execution environments like `opencode run`, where there is no interactive shell to expand it. All paths must use `$HOME` explicitly.

1. **Determine project root and name:**

   ```bash
   # Step 1: find the git root, fallback to $PWD
   GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
   if [ -z "$GIT_ROOT" ]; then
     GIT_ROOT="$PWD"
   fi

   # Step 2: navigate to git root
   cd "$GIT_ROOT"

   # Step 3: extract project name from directory name only
   PROJECT_NAME=$(basename "$GIT_ROOT" | tr '[:lower:]' '[:upper:]' | tr '[:space:]' '_' | tr '-' '_' | sed 's/[^A-Z0-9_]//g')

   # Step 4: guard against empty result
   if [ -z "$PROJECT_NAME" ] || [ "$PROJECT_NAME" = "_" ]; then
     PROJECT_NAME="UNKNOWN"
   fi

   # Step 5: define all paths using $HOME, never ~
   FINGERPRINT_DIR="$HOME/.fingerprint"
   PATTERN_FILE="$FINGERPRINT_DIR/${PROJECT_NAME}_CODEBASE_PATTERNS.md"
   STATE_FILE="$FINGERPRINT_DIR/${PROJECT_NAME}.json"

   # Step 6: ensure output directory exists
   mkdir -p "$FINGERPRINT_DIR"

   # Step 7: confirm resolved values
   echo "Git root:     $GIT_ROOT"
   echo "Project name: $PROJECT_NAME"
   echo "State file:   $STATE_FILE"
   echo "Pattern file: $PATTERN_FILE"
   ```

2. **Check if first run:**

   ```bash
   if [ ! -f "$STATE_FILE" ]; then
     echo "First run — state file will be created"
   else
     echo "Subsequent run — state file found, will update"
   fi
   ```

   Proceed to step 3 immediately in either case. Do not pause.

3. **Scan codebase:**

   Store results in a variable — do not dump the file list to stdout:

   ```bash
   FILES=$(find . -type f \( -name "*.ts" -o -name "*.tsx" \) \
     ! -path "*/node_modules/*" \
     ! -path "*/.git/*" \
     ! -path "*/dist/*" \
     ! -path "*/build/*" \
     | sort)
   echo "Found $(echo "$FILES" | wc -l) source files"
   ```

4. **Categorize files:**
   - Components: `*.tsx` with JSX
   - Hooks: `use*.ts` or `use*.tsx`
   - Services: files in `src/services/`
   - Models: Parse.Object or Mongoose schemas
   - Utils: everything else
   - Tests: `*.test.ts`, `*.spec.ts`

5. **Sample files:**
   - Read state file (analyzed files list)
   - Filter out analyzed files
   - Sample 15-20 new files across categories
   - Prioritize categories with low sample counts

6. **Extract patterns:**
   - Parse each file
   - Extract naming, structure, comments, etc.
   - Calculate distributions
   - Compare with existing patterns

7. **Update pattern file:**

   > **The pattern markdown file will be large (500-1000+ lines). This is expected and normal. Write the entire file in a single write operation without truncating or deferring. Do not split into multiple turns.**
   - Preserve MANUAL OVERRIDES (never auto-modify)
   - Update SUMMARY
   - Update DETAILED ANALYSIS sections
   - Increment sample counts
   - Update confidence levels
   - Flag conflicts if detected

8. **Update state file:**
   - Add newly analyzed files
   - Increment run count
   - Update timestamp
   - Update category counts

9. **Report progress**

### Command: "Continue fingerprinting"

Same as above (steps 1-9)

### Command: "Show fingerprinting progress"

Read state file and pattern file, report:

- Files analyzed / total estimated
- Coverage % per category
- Patterns with low confidence
- Suggested next sampling priorities

### Command: "Fingerprint: src/services/" (targeted)

Same workflow but only analyze files in specified directory

### With Hint

If user provides hint:

```
Continue fingerprinting

Hint: We always validate permissions before Parse queries
```

1. Run normal sampling
2. **Additionally:** Search all analyzed files for the hinted pattern
3. Extract pattern even if not statistically dominant
4. Add to DETAILED ANALYSIS with note:

   ```markdown
   ### Permission Validation

   **Sample:** 8 files (manually verified)
   **Confidence:** 🔒 Manual override candidate
   **Pattern:** All Parse queries preceded by permission check
   **User note:** "We always validate permissions before Parse queries"
   ```

---

## Output Quality Guarantees

### For Humans

**Summary section:**

- ✅ Readable in 2-5 minutes
- ✅ Shows coverage at a glance
- ✅ Highlights conflicts/issues
- ✅ Indicates what needs more samples

**Manual overrides:**

- ✅ Clear authority (overrides auto-discovery)
- ✅ Includes rationale
- ✅ Easy to add/modify

**Collapsible sections:**

- ✅ Can drill down where skeptical
- ✅ Don't have to read everything
- ✅ Examples include file references for verification

### For LLMs

**Code generation:**

- ✅ Quick Reference has everything needed
- ✅ Templates are copy-paste ready
- ✅ Anti-patterns clearly marked
- ✅ Rules are quantitative (not vague)

**Code review:**

- ✅ Detailed Analysis has statistical backing
- ✅ Examples show expected vs unexpected
- ✅ Confidence levels guide enforcement strictness
- ✅ Conflicts are flagged

**Pattern matching:**

- ✅ No ambiguity (percentages, not "usually")
- ✅ Clear precedence (Manual Overrides > Auto-discovered)
- ✅ File references for validation

---

## Usage Instructions for Generated File

### When Generating Code

**Include pattern file in every coding prompt:**

```markdown
[Paste entire pattern file]

---

Task: Add a user profile component
```

**Why every time:**

- Prompt caching makes it nearly free after first use
- Guarantees pattern consistency
- No risk of drift in long conversations

**What LLM reads:**

1. MANUAL OVERRIDES (always)
2. QUICK REFERENCE (primary source for generation)
3. SUMMARY (context)
4. DETAILED ANALYSIS (only if Quick Reference unclear)

### When Reviewing Code

**Include pattern file in review prompt:**

```markdown
[Paste entire pattern file]

---

Review this PR for pattern compliance:
[git diff]
```

**What LLM reads:**

1. MANUAL OVERRIDES (takes precedence)
2. DETAILED ANALYSIS (fine-grained pattern matching)
3. QUICK REFERENCE (anti-patterns)

### Verifying Fingerprint Accuracy

**As a human:**

1. Read SUMMARY (2 min) — does this match your understanding?
2. Check MANUAL OVERRIDES — are these correct?
3. Expand 2-3 DETAILED ANALYSIS sections — do examples look right?
4. If anything looks wrong, add/modify MANUAL OVERRIDES

**You don't need to read all 50+ pages.** The summary + spot checks are sufficient.

---

## Error Handling

**Large codebase (1000+ files):**

Print a warning and proceed automatically — do not pause for confirmation:

```
⚠️ Large codebase detected (1,200 files)
Sampling will require 15-20 runs for full coverage.
Proceeding with this run's sample (15-20 files). Run again to increase coverage.
```

**No TypeScript files found:**

```
❌ No .ts/.tsx files found. Halting — cannot continue without source files.
```

**Pattern file corrupted:**

Automatically attempt repair — preserve any MANUAL OVERRIDES found, regenerate the analysis sections. Do not pause to ask:

```
⚠️ Pattern file exists but MANUAL OVERRIDES section is malformed
Auto-repairing: preserving overrides, regenerating analysis sections.
```

---

## Special Cases

### Git Commit Pattern Analysis

If requested:

```
Fingerprint the codebase including commit patterns
```

Additionally run:

```bash
git log --all --pretty=format:"%s" --since="6 months ago" | head -100
```

Analyze commit messages and add section to pattern file:

```markdown
<details>
<summary><b>Git Commit Patterns</b> — 100 commits analyzed</summary>

### Message Structure

**Sample:** Last 100 commits | **Confidence:** 🟢 High

**Pattern:**

- 65% use conventional commits (feat:, fix:, chore:, etc.)
- 35% use freeform
- Median length: 48 chars
- Max length: 72 chars (strict)
- Capitalization: First word capitalized
- Punctuation: No period at end
- Tense: Imperative mood

**Examples:**

- `feat: add user authentication flow`
- `fix: resolve null pointer in UserService`
- `chore: update dependencies`
- `docs: update API documentation`

</details>
```

---

## Final Checklist (Every Run)

Confirm these hold, then write both files immediately without pausing:

✅ MANUAL OVERRIDES section preserved exactly (no auto-modification)  
✅ SUMMARY updated with new stats  
✅ Sample counts incremented in DETAILED ANALYSIS  
✅ Confidence levels updated (🔴/🟡/🟢)  
✅ Collapsible sections properly formatted  
✅ No duplicate content across sections  
✅ Examples include file references  
✅ Conflicts flagged with ⚠️  
✅ Coverage status updated  
✅ State file updated with new analyzed files  
✅ Anti-patterns section includes any new legacy patterns found  
✅ All file writes use `"$PATTERN_FILE"` and `"$STATE_FILE"` variables (never hardcoded paths)  
✅ All mkdir/cat/write commands use `$HOME`, never `~`  
✅ Environment block was run and echo output confirmed before writing any files

---

## Ready to Begin

Common commands:

- `Fingerprint the codebase` — Start or continue analysis
- `Show fingerprinting progress` — Check coverage and confidence
- `Fingerprint: src/components/` — Analyze specific directory

**After fingerprinting is complete, use the generated pattern file in ALL coding and review prompts for maximum consistency.**
