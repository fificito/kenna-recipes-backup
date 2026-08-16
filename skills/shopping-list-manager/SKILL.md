---
name: shopping-list-manager
description: Manage grocery shopping lists with intelligent item grouping based on store location proximity
tags: [shopping, list, grocery, productivity, organization]
---

# Shopping List Manager

A comprehensive system for managing grocery shopping lists with intelligent item grouping based on store location order.

## Trigger

User needs to manage a shopping list with the following commands:
- "falta [item]" (Spanish) / "need [item]" (English) — Add item to list
- "muestrame la lista" / "show me the list" — Display all numbered items
- "[number]" — Delete that item from list
- "finalizada" / "finished" — Finalize list and renumber remaining items

## Overview

This skill manages a **shared, persistent shopping list** that:
1. Adds items as user requests them
2. Displays items with numbers
3. Removes items by number
4. Groups items by proximity in store based on deletion order
5. **Maintains persistent state across messages in the same conversation**
6. **Visible and editable by all users in the shared chat** (multi-user shopping list)
7. Survives conversation continuations (cross-session persistence via chat history)

## Dual-Store Lists (Felipe Workflow)

Maintain two completely separate persistent lists with identical behavior:
- **Costco**
- **Super**

Commands:
- `Costco [item]` or `c [item]` → add the item to the Costco list
- `Super [item]` or `s [item]` → add the item to the Super list (accept obvious typos such as `cuper`)
- `c X` → remove Costco item number X **when X is numeric**
- `s X` → remove Super item number X **when X is numeric**
- `c finalizada` / `s finalizada` → finalize and renumber only the specified list

Disambiguation: after `c` or `s`, numeric text means deletion; non-numeric text means an item to add.

Each list has its own numbering and deletion gaps. Never renumber one list because an item was removed or finalized in the other. If the user asks to show the list without naming a store, display both lists under separate headings.

## Multi-User Shared Chat Pattern

When multiple users are added to the same Telegram chat:
- ✅ All users see the same shopping list
- ✅ Any user can add items ("falta [item]")
- ✅ Any user can view ("muestrame la lista")
- ✅ Any user can delete ("2", "3", etc.)
- ✅ Any user can finalize ("finalizada")
- ✅ List state is visible to everyone in real-time

**Use case:** Family or group shopping where multiple people contribute items and track deletions together.

## Instructions

### Step 1: Initialize List
When user says "falta [item]", add the item to the shopping list. Keep items in order of addition.

```
Current List:
1. Servilletas de cocina
2. Papel de baño
```

### Step 2: Show List
When user says "muestrame la lista" or "show me the list", display all items with numbers:

```
📋 Lista de Compra:
1. Servilletas de cocina
2. Papel de baño
3. Leche
4. Pan
```

### Step 3: Delete Items
When user provides a number (e.g., "2"), delete that item. Keep track of deletion order because:
- Items deleted in the same sequence = they're close together in the store
- Grouping will improve as more items are marked

**CRITICAL — MANDATORY:** Do NOT renumber after deletion until user explicitly says "finalizada"

Keep original numbering with gaps. Example:

```
User says: 1
Result: Remove "Papel de baño"
Remaining (NO RENUMBERING):
2. Jabón roma
3. Jabón de baño
4. Jeringas
5. Crema
```

If items 1 and 3 are deleted, the list shows: 2, 4, 5, 6... (gaps preserved)
This is NOT a bug — it is intentional. Deletion gaps track which items were purchased together at same store location.

**ONLY renumber when user says "finalizada"** — NOT before, NOT by default, NOT ever until explicitly commanded.

### Step 4: Track Deletion Order
Internally track which items are deleted and in what order. This reveals store layout:

```
Deletion Order: 2, 4, 1 → Items were close together
Grouping: Pan-Leche-Servilletas are nearby
```

### Step 5: Finalize List (RENUMBER HERE)
When user says "finalizada" or "finished":
1. **RENUMBER all remaining items starting from 1** (compress all gaps)
2. Organize by deletion order (items deleted in sequence = nearby in store)
3. Display final optimized list with confirmation message

```
User says: finalizada

✅ LISTA FINALIZADA!

📋 Lista Final (Renumerada):
1. Servilletas de cocina
2. Leche
3. Pan
(Gaps eliminated, fresh numbering from 1)
```

**This is the ONLY time renumbering happens.** Never renumber during shopping.
3. Pan
(Gaps eliminated, fresh numbering from 1)
```

## Key Rules

1. **Persistent State:** Keep the list active across all messages in the conversation
2. **No Automatic Renumbering:** Only renumber on "finalizada" command
3. **Post-Finalization Persistence:** After "finalizada", remaining items become the new list (renumbered 1, 2, 3...). Items STAY in the list unless user explicitly provides a number to delete.
4. **Track Deletion Order:** Remember sequence of deletions to understand store layout
5. **Spanish/English:** Accept commands in both languages
6. **Visual Feedback:** Always confirm when item is added/deleted
7. **Grouping Logic:** Items deleted in same order = store proximity

## Example Workflow

```
User: "falta servilletas de cocina"
Assistant: ✅ Anotado!
Lista: 1. Servilletas de cocina

User: "falta papel de baño"
Assistant: ✅ Anotado!
Lista: 1. Servilletas de cocina
       2. Papel de baño

User: "muestrame la lista"
Assistant: 📋 Lista de Compra:
          1. Servilletas de cocina
          2. Papel de baño
          3. Leche
          4. Pan

User: "2"
Assistant: ✅ Eliminado: Papel de baño
Restante:
1. Servilletas de cocina
2. Leche
3. Pan

User: "4"
Assistant: ✅ Eliminado: Pan
Restante:
1. Servilletas de cocina
2. Leche

User: "finalizada"
Assistant: 📋 Lista Final:
          1. Servilletas de cocina
          2. Leche
          (Items grouped by store proximity)
```

## Pitfalls

- ❌ **Renumbering too early:** Don't renumber until "finalizada" is said — THIS IS NON-NEGOTIABLE. User will explicitly correct you if you renumber early.
- ❌ **Losing deletion order:** Track sequence to understand grouping
- ❌ **Forgetting items:** Keep persistent list state across messages
- ❌ **Not acknowledging:** Always confirm additions/deletions with ✅
- ❌ **Mixing languages:** Support both Spanish and English naturally
- ❌ **AUTO-RENUMBERING BUG (Session 18):** Agent renumbered list after each deletion despite user instruction not to. User had to explicitly say "Do not renumber until I say finalizada". Now fixed: never renumber gaps until user says "finalizada".
- ❌ **CONFIRMED AGAIN (Session ~22):** User reinforced: "Do not renumber until I say finalizada" — this is non-negotiable. Maintain gaps in numbering until explicit "finalizada" command. This is the ONLY accepted workflow for this user.
- ✅ **SESSION 25 FIX:** Added explicit behavior: After "finalizada", MUST renumber remaining items starting from 1 to compress all gaps. User corrected agent for not renumbering after finalizing the list.
- ✅ **SESSION 25 CLARIFICATION:** After "finalizada" is called, remaining items become the new list (renumbered from 1). New items added after that continue from the highest number. Items only leave the list when user provides their number to delete. Never assume finalizada clears the list — only items explicitly deleted by number are removed.

## Proximity-Based Grouping (Optional Advanced Mode)

This skill can optionally track **proximity chains** — the order in which items are removed reveals their location in the store.

### How Proximity Learning Works

When items are removed in a sequence (e.g., user says "2, 4, 1"), those items are physically close together in the store. Over multiple shopping trips, deletion patterns reveal store layout:

**Session 1:** Remove items 2, 4, 1 → Those three are nearby
**Session 2:** Remove 2, 3, 4, 6 → Refines understanding (2-4-3-6 is a proximity chain)
**Session 3+:** New items are automatically grouped near previous high-frequency neighbors

### Enabling Proximity Tracking

To use advanced proximity grouping:
1. After each "finalizada", note the removal order
2. Track which items are deleted in sequence (same trip = same store section)
3. On next shopping list, pre-group items that were removed together before
4. This gradually learns and encodes the store's physical layout

### Example Proximity-Enhanced Workflow

```
Session 1:
User adds: servilletas, papel de baño, leche, pan, queso
User removes: 2, 3, 4  (removal order: papel → leche → pan)
→ Learn: {2, 3, 4} are proximate (paper aisle → dairy → bakery section)

Session 2:
User adds: servilletas, papel de baño, leche, mantequilla, pan, huevos, queso
(New items grouped near learned proximity: 
 mantequilla near leche, huevos near dairy section)
User removes: 2, 3, 4, 5, 6  (follow same chain)
→ Confirm and strengthen: paper → dairy section is a real aisle sequence
```

**Pitfall:** Proximity learning is optional. If user never uses this advanced mode, the skill works as a simple non-renumbering list manager. No explicit commands needed — it's automatic if you track deletions.

## Verification

✅ List persists across messages
✅ Items added correctly with "falta [item]"
✅ Items displayed with "muestrame la lista"
✅ Items deleted by number without renumbering
✅ Final list renumbered only on "finalizada"
✅ Deletion order tracked for store proximity grouping (optional)
