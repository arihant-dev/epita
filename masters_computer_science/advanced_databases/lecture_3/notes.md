# Lecture 3: Advanced Databases

## Directory Databases

## What is a directory and isn't?
 - A directory service is a specializzed database optimized for:
    - Read operations (Reads >> Writes 1000:1)
    - Hierarchical data organization
    - Fast lookups based on attributes
    - Replicated widely
    - Standard schema
- **The dominat protocol is LDAP (Lightweight Directory Access Protocol)**

### LDAP vs RDBMS
| Aspect | LDAP | RDBMS |
|---------|------|-------|
| Data shape | Hierarchical (tree) | Tabular (relations) |
| Identifier | Distinguished Name (DN) | Primary Key |
| Schema | Standardized (object classes, attributes) | Flexible (tables, columns) |
| Workload | Read-heavy (1000:1) | Balanced (reads/writes) |
| Updates | Atomic (per entry) | Transactional (multi-row) |

### The LDAP data model - DIT

#### Directory Information Tree (DIT)

```
dc=epita,dc=fr                                  <- root
|
- ou=people                                     <- organizational unit
   |
   - uid=jdoe,ou=people,dc=epita,dc=fr         <- entry (user)
   |
   - uid=jsmith,ou=people,dc=epita,dc=fr
|
- ou=groups
   |
   - cn=admins,ou=groups,dc=epita,dc=fr
   - cn=users,ou=groups,dc=epita,dc=fr
```

#### RN (Relative Distinguished Name) and DN (Distinguished Name)
- **RDN**: The part of the DN that uniquely identifies an entry within its parent (e.g., `uid=jdoe` is the RDN for the user entry)
- **DN**: The full path to an entry in the DIT (e.g., `uid=jdoe,ou=people,dc=epita,dc=fr`)

#### LDAP naming - RDN prefixes
- `dc` (domain component): Used to represent parts of the domain name (e.g., `dc=epita,dc=fr` for epita.fr)
- `ou` (organizational unit): Used to group related entries (e.g., `ou=people`, `ou=groups`)
- `uid` (user ID): Used to identify individual user entries (e.g., `uid=jdoe`)
- `cn` (common name): Used for entries that represent groups or other non-user entities (e.g., `cn=admins`)
- `o` (organization): Used to represent an organization (e.g., `o=epita`)

#### Entries and Attributes
- An **entry** in LDAP is a collection of attributes that represent an object (e.g., a user, a group).
- Each entry has a unique DN and can have multiple attributes (e.g., `cn`, `mail`, `uid`).
- Attributes can have multiple values (e.g., a user can have multiple email addresses).

#### Schema, object classes, and attributes
- The LDAP schema defines the structure of the directory, including the object classes and attributes that can be used.
- **Object classes** define the types of entries and the attributes they can have (e.g., `inetOrgPerson` for user entries).
- **Attributes** are the properties of an entry (e.g., `cn`, `mail`, `uid`) and can be single-valued or multi-valued.
- The schema ensures consistency and allows for validation of entries when they are added or modified in the directory.

###### Common objectClasses:
- `top`: The root object class that all entries must inherit from.
** People **
- `person`: A basic object class for representing people, with attributes like `cn` and `sn`.
- `organizationalUnit`: Used to represent organizational units, with attributes like `ou`.
- `inetOrgPerson`: An extension of the `person` class that includes additional attributes like `mail` and `uid`, commonly used for user entries in directories.

** Groups **
- `groupOfNames`: Used to represent groups, with attributes like `cn` and `member` (which lists the DNs of group members).
- `groupOfUniqueNames`: Similar to `groupOfNames`, but the `member` attribute must contain unique values (no duplicates).

** UNIX accounts **
- `posixAccount`: Used to represent UNIX user accounts, with attributes like `uid`, `gidNumber`, and `homeDirectory`.
- `posixGroup`: Used to represent UNIX groups, with attributes like `cn` and `gidNumber`.

### LDAP operations
- **BIND**: Authenticate to the directory (e.g., using a username and password).
- **SEARCH**: Query the directory for entries that match certain criteria (e.g., find all users with a specific email domain).
- **ADD**: Create a new entry in the directory.
- **MODIFY**: Update attributes of an existing entry.
- **Delete**: Remove an entry from the directory.
- **Unbind**: Terminate the session with the directory.
- **MODDN**: Modify the DN of an entry (e.g., move an entry to a different location in the DIT).
- **Compare**: Check if an entry has a specific attribute value (e.g., verify if a user has a certain email address).


## Introduction to Mongodb

### The document model

```json
{
    "_id": ObjectId("507f1f77bcf86cd799439011"),
    "title": "Advanced Databases",
    "school": "EPITA",
    "hours": 18,
    "tags": ["database", "mongodb", "nosql"],
    "instructor": {
        "name": "Tarek",
        "email": "tarek@example.com"
    },
    "sessions": [
        {
            "date": "2024-06-01",
            "topics": ["LDAP", "Directory Services"]
        },
        {
            "date": "2024-06-08",
            "topics": ["MongoDB", "Document Databases"]
        }
    ]
}
```
A document = a JSON-like object stored as BSON (binary JSON).
