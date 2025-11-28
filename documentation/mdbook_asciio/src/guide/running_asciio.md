Asciio is developed, and runs, on both Linux and Windows (cygwin).

# Running asciio

    $> asciio [file.asciio]       # GUI application using Gtk3

    $> tasciio [file.asciio]      # TUI application

    $> asciio_to_text file.asciio # converts asciio files to ASCII

    $> text_to_asciio ...         # makes an asciio file from text


# Command line options

| option                    |                                            | context        |
| -                         | -                                          | -              |
| b                         | put the input in a box element             | text_to_asciio |
| text_separator=s          | put the input in a boxed element           | text_to_ascioo |
| display_setup_information | verbose setup information                  |                |
| show_binding_override     | display binding overrides in terminal      |                |
| setup_path=s              | sets the root of the setup directory       |                |
| s,script=s                | script to be run at Asciio start           |                |
| p,web_port=s              | port for web server                        |                |
| debug_fd=i                | debug file descriptor number               |                |
| add_binding=s             | file containing bindings to embedd         |                |
| reset_bindings            | remove all embedded bindings from document |                |
| dump_bindings             | write the embedded bindings to files       |                |
| dump_binding_names        | display name of embbeded bindings          |                |

# Opening Asciio documents from the command line

## Asciio Documents and Projects


The Asciio (tabbed) application distinguishes between two file types: individual asciio documents and asciio projects. Understanding this distinction is essential for proper file management.

### File Types

#### Asciio Documents

Asciio documents represent individual diagrams. Each document contains:

- Drawing elements and their properties
- Setup data

Documents are loaded into individual tabs within the application interface.

#### Asciio Projects

Asciio projects are container that bundle multiple asciio documents together. A project file contains:

- Multiple serialized asciio documents
- Project data specifying tab count and document order

### Loading Files from Command Line

#### Command Line Behavior

Files specified as command-line arguments are processed sequentially. The application automatically detects whether each file is a document or project.

#### Type Detection Mechanism

File type detection operates through document validation:

- The application attempts to open the file as an asciio project
- Open failure triggers single-document loading

This approach allows transparent handling of both file types without requiring file extension conventions or explicit type specification.

#### Multiple File Loading

When multiple files are provided via command line:

- Each file is processed independently
- Projects expand into multiple tabs (one per contained document)
- Asciio documents in a tab each
- All loaded files coexist in the same application session

### Writing Projects

#### Project Structure

When saving a project, the application:

- Serializes each open tab's asciio document
- Generates unique filenames for each document within the archive
- Creates an `asciio_project` data file containing document count and ordering
- Packages all components into a project file

### Naming Collision Resolution

#### During Project Creation

The application implements collision detection when saving projects:

- Documents without titles receive automatic names (`untitled_0`, `untitled_1`, etc.)
- Duplicate names trigger automatic suffix generation using random integers (0-9999)

This ensures filesystem-safe uniqueness within the project file.

### Save Operations

#### Project Modified State

The application tracks modifications at two levels:

- Individual document modification (tracked per tab)
- Project-level modification (tab operations, document additions/removals)

#### File Overwrite Protection

The save mechanism implements defensive overwrite handling:

- Existing filenames trigger confirmation dialogs
- User cancellation aborts the save operation

### Application Exit

#### Modified Content Handling

Application termination with unsaved changes triggers:

- Detection of any modified documents or project structure
- Presentation of save/quit/cancel dialog

### Document vs Project Saves

Asciio uses project-level saves during exit. Individual document modifications are captured within the project save operation. You can save individual documents at any time.

### Error Handling Behavior

#### Non-Existent Files

When a non-existent file path is provided on the command line:

- A new empty tab is created

The application launches successfully but the non-existent file produces an empty tab, error is output to the console.

#### Invalid File Formats

When an existing file contains invalid or corrupted data:

- A new empty tab is created

#### Error Recovery

Asciio is resilient to bad input:

- Individual file failures do not prevent application launch
- Subsequent command-line files are processed
- Error messages provide diagnostic information to STDERR

### Command Line Examples

#### Single Asciio Document

**Command**:

```bash
asciio diagram.ascii
```

**Behavior**:

- Application launches with one document
- no tab is displayed when a single file is loaded

### Single Project

**Command**:

```bash
asciio project.asciios
```

**Behavior**:
- Application launches with multiple tabs (one per contained document)
- Tab labels reflect individual document names from archive
- Tab order matches the orders of the saved project

#### Multiple Asciio Documents

**Command**:

```bash
asciio doc1.asciio doc2.asciio doc3.asciio
```

**Behavior**:

- Application launches with three tabs
- Each document loads into separate sequential tab
- Tab labels: `doc1.asciio`, `doc2.asciio`, `doc3.asciio`

#### Multiple Projects

**Command**:

```bash
asciio project1.asciios project2.asciios
```

**Behavior**:

- Application launches with tabs from both projects
- First project's documents load into initial tabs
- Second project's documents append to tab bar
- Tab labels reflect individual document names
- Naming collision resolution applies if documents share names

### Mixed Asciio Documents and Projects

**Command**:

```bash
asciio header.asciio project.asciios footer.asciio
```

**Behavior**:

- Tab sequence: `header.asciio`, then project documents, then `footer.asciio`
- Project expands into multiple consecutive tabs
- Final tab arrangement reflects command-line order

#### Project with Document Name Collisions

**Command**:

```bash
asciio project1.asciios project2.asciios
```

**Where both projects contain a document named `diagram`**:

**Behavior**:
- First `diagram` from `project1.asciio` loads with original name
- Second `diagram` from `project2.asciio` receives random suffix
- Resulting tabs: `diagram`, `diagram_4721` (random number varies)
- Collision detection operates at session load time
- Suffix generation prevents tab label conflicts

#### All Invalid Files

**Command**:
```bash
asciio missing1.ascii0 missing2.asciio missing3.asciio
```

**Behavior**:

- Three empty tabs created
- Three error messages to STDERR
- Application remains functional
- User can immediately begin working in empty tabs
- No crash or abnormal termination

