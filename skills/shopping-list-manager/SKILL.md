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

This skill manages a persistent shopping list that:
1. Adds items as user requests them
2. Displays items with numbers
3. Removes items by number
4. Groups items by proximity in store based on deletion order
5. Maintains persistent state across messages

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

**Important:** Do NOT renumber after deletion unless user says "finalizada"

```
User says: 2
Result: Remove "Papel de baño"
Remaining:
1. Servilletas de cocina
2. Leche (was 3)
3. Pan (was 4)
```

### Step 4: Track Deletion Order
Internally track which items are deleted and in what order. This reveals store layout:

```
Deletion Order: 2, 4, 1 → Items were close together
Grouping: Pan-Leche-Servilletas are nearby
```

### Step 5: Finalize List
When user says "finalizada" or "finished":
1. Renumber all remaining items starting from 1
2. Organize by deletion order (items deleted in sequence = nearby in store)
3. Display final optimized list

```
User says: finalizada

📋 Lista Final (Optimizada):
1. Servilletas de cocina
2. Leche
3. Pan
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

- ❌ **Renumbering too early:** Don't renumber until "finalizada" is said
- ❌ **Losing deletion order:** Track sequence to understand grouping
- ❌ **Forgetting items:** Keep persistent list state across messages
- ❌ **Not acknowledging:** Always confirm additions/deletions with ✅
- ❌ **Mixing languages:** Support both Spanish and English naturally

## Verification

✅ List persists across messages
✅ Items added correctly with "falta [item]"
✅ Items displayed with "muestrame la lista"
✅ Items deleted by number without renumbering
✅ Final list renumbered only on "finalizada"
✅ Deletion order tracked for store proximity grouping
