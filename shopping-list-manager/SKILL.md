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

Only compress numbering when user says "finalizada".

### Step 4: Track Deletion Order
Internally track which items are deleted and in what order. This reveals store layout:

```
Deletion Order: 2, 4, 1 → Items were close together
Grouping: Pan-Leche-Servilletas are nearby
```

### Step 5: Finalize List
When user says "finalizada" or "finished":
1. **RENUMBER all remaining items starting from 1** (compress all gaps)
2. Organize by deletion order (items deleted in sequence = nearby in store)
3. Display final optimized list with message confirming list was finalized

```
User says: finalizada

✅ LISTA FINALIZADA!

📋 Lista Final (Renumerada):
1. Servilletas de cocina
2. Leche
3. Pan
(Gaps eliminated, fresh numbering from 1)
```

## Key Rules

1. **Persistent State:** Keep the list active across all messages in the conversation
2. **No Automatic Renumbering:** Only renumber on "finalizada" command
3. **Track Deletion Order:** Remember sequence of deletions to understand store layout
4. **Spanish/English:** Accept commands in both languages
5. **Visual Feedback:** Always confirm when item is added/deleted
6. **Grouping Logic:** Items deleted in same order = store proximity

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

## Verification

✅ List persists across messages
✅ Items added correctly with "falta [item]"
✅ Items displayed with "muestrame la lista"
✅ Items deleted by number without renumbering
✅ Final list renumbered only on "finalizada"
✅ Deletion order tracked for store proximity grouping
