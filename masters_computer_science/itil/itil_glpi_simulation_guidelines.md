# ITIL Simulation – GLPI  
**Detailed Instructions & Final Deliverable**

## Objective
The objective of this exercise is to simulate how an IT team operates using ITIL best practices in GLPI.

---

## Part 1 – Build your CMDB

### Step 1 – Create CI
Go to **Assets → Computers → + Add**  
Create:
- WEB-SRV-TeamXX (Web Server)
- APP-SRV-TeamXX (Application Server)
- DB-SRV-TeamXX (Database Server)
- ERP-SRV-TeamXX (ERP Server)

### Step 2 – Fill in CI information
- Name
- Status: In production
- Type: Server
- Location: Data Center
- Comments

### Step 3 – Define relationships
- WEB depends on APP
- APP depends on DB

---

## Part 2 – Incident Management

### Step 4 – Create tickets
Go to **Assistance → Tickets → + Add**

### Step 5 – Link tickets to CI (**MANDATORY**)

### Step 6 – Manage tickets
- Assign
- Update
- Comment
- Prioritize

---

## Part 3 – Problem Management

### Step 7 – Create a problem
Go to **Assistance → Problems → + Add**

### Step 8 – Link incidents to the problem

---

## Part 4 – Change Management

### Step 9 – Create a change request
Go to **Assistance → Changes → + Add**

---

**Important Rule:**  
If it is not in GLPI, it does not exist.

---

## Final Deliverable

1. **GLPI content:**
   - CI created
   - Tickets linked
   - Problem created
   - Change created

2. **Screenshots:**
   - CI list
   - Ticket
   - Problem
   - Change

3. **Mini Dashboard:**
   - Number of incidents
   - Critical incidents
   - Impacted CI
   - Root cause

4. **Short analysis:**
   - What happened?
   - Root cause?
   - Lessons learned?
   - Improvements?