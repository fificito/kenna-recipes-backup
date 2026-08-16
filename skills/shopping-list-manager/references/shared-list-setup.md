# Shared Shopping List Setup

## What is a Shared List?

A shopping list created in a **multi-user Telegram chat** (not a DM) where:
- Multiple users can add, view, and remove items
- List persists across messages in the same chat
- All users see the same state (no conflicts)
- Language: Spanish (for Spanish-speaking household)

## How It Works

### Adding Items
```
User A: "falta leche"
Agent: ✅ Anotado!
       1. Servilletas de cocina
       2. Papel de baño
       3. Leche
```

### Viewing the List
```
User B: "muestrame la lista"
Agent: 📋 Lista de Compra:
       1. Servilletas de cocina
       2. Papel de baño
       3. Leche
```

User B sees the same list as User A — no separate copies.

### Removing Items
```
User C: "2"
Agent: ✅ Eliminado: Papel de baño
       Restante:
       1. Servilletas de cocina
       2. Leche
```

The removal is visible to all users.

### Finalizing
```
User A: "finalizada"
Agent: 📋 Lista Final (Optimizada):
       1. Servilletas de cocina
       2. Leche
       (Items grouped by store proximity based on deletion order)
```

## Multi-User Notes

- **No login needed:** Works for anyone in the chat
- **Permissions:** Anyone can add, remove, or finalize (trust-based)
- **Persistence:** Lives in chat history; survives across sessions as long as chat is accessible
- **Conflicts:** If two users add simultaneously, agent tracks both (no data loss)
- **Deletion order matters:** The order users say numbers determines store grouping (useful for shared shopping trips)

## Example Scenario

```
Session 1 (Monday):
- User A: "falta manzanas"
- User B: "falta leche"
- User C: "muestrame la lista"
→ List: manzanas, leche

Session 2 (Wednesday, same chat):
- User A: "1" (remove manzanas)
- User D: "falta pan"
- User B: "muestrame la lista"
→ List: leche, pan (User D sees the same list as original users)

Session 3 (Friday):
- User A: "finalizada"
→ Final optimized list based on deletion order
```

## When to Use

✅ **Good for:**
- Household shopping (multiple family members)
- Shared meal planning
- Group grocery trips
- Recurring lists with same people

❌ **Not ideal for:**
- Private, individual lists (use DM instead)
- Lists that need access control (who can delete?)
- Lists that need to persist across unrelated conversations
