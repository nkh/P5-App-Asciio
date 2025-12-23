# BINDINGS FORMAT

**Asciio** processes external configuration files that dynamically define the application's keybindings, keybindings structure, and context menus.

These files are valid Perl scripts, you can defined code to bind to in the files but we recommend you create a module instead.

## Action Definition Commands

Use the following commands to define commands:

| Subroutine Name                        | Purpose                                                             | Data Format Expected          |
| ---                                    | ---                                                                 | ---                           |
| register_action_handlers               | Defines actions, and multi-level action groups.                     |                               |
| register_action_handlers_with_override | As above but also **deletes** old shortcuts                         | list of key-value pairs       |
| TOP_LEVEL_GROUP                        | Defines the content of the top-level grouping used for menu display | shortcut and a list of action |
| GROUP                                  | Used to declare a nested, ordered, action group.                    |                               |
| USE_GROUP                              | binds a shortcut with a group                                       |                               |
| CONTEXT_MENU                           | Defines actions that are only accessible via a context menu         |                               |

## Action Definition Formats

The definitions passed to *register_action_handlers* can take two primary forms:

- Single Action 
- Group Definition

### Single Action Definition

Single action definition are declared within a pair of square brackets (a Perl array ref).

| Index | Defines   | Type               | Purpose                                                                |
| ---   | ---       | ---                | ---                                                                    |
| 0     | SHORTCUTS | Scalar or ArrayRef | The keybindings that trigger the action                                |
| 1     | CODE      | CodeRef            | The Perl subroutine reference to execute when the shortcut is pressed. |
| 2     | ARGUMENTS | Scalar or ArrayRef | Optional arguments to be passed to the CODE subroutine.                |
| 3     | OPTIONS   | HashRef            | Optional hash of flags or attributes for the binding                   |

**Example of Single Action:**

```perl

register_action_handlers
(
'Undo' => 
    [ 
        ['C00-z', '000-u'],                      # [0] SHORTCUTS
        \&App::Asciio::Actions::Unsorted::undo,  # [1] CODE
        -1,                                      # [2] optional ARGUMENTS
        { ... },                                 # [3] optional BINDING OPTIONS
    ],

# ... more  bindings
);
```

#### Binding Options

- HIDE => 1/0, controls if this binding is shown in the bindings help

### `GROUP` Definition

Used for defining a collection of related commands.

The commands typically share a single shortcut that, when pressed, switches the application's context to the commands defined within the group.

####  Group Control Keys

The definition must contain the following control keys at the top-level of the group:

| Key         | Type               | Purpose                                                        |
| ---         | ---                | ---                                                            |
| SHORTCUTS   | Scalar or ArrayRef | The keybinding(s) that activate/enter this group               |
| ESCAPE_KEYS | Scalar or ArrayRef | Optional keybinding(s) that deactivate/exit the group          |
| ENTER_GROUP | CodeRef or undef   | Optional code to execute *when* the group is activated.        |
| HIDE        | Scalar (0 or 1)    | Optional atrribute, the group is hidden from bindingsdisplays. |

#### Group Actions

Following the control keys, an the ordered list of actions:

| Type      | Purpose                               |
| ---       | ---                                   |
| ArrayRef  | A Single Action Definition            |
| GROUP     | A Nested Group Definition             |
| USE_GROUP | Command to switches to another group. |

**Example of Group Definition:**

```perl
register_action_handlers
(
'grouping ->' => 
    GROUP # create a GROUP
        (
        # control keys
        SHORTCUTS   => '000-g',
        ESCAPE_KEYS => '000-Escape',

        # Single element
        'selected elements' => [ '000-g', \&App::Asciio::Actions::ElementsManipulation::group_selected_elements ],

        # Nested Group
        'Subgroup' => GROUP
                        ( 
                        SHORTCUTS => '000-a',
                        'Align top' => ['000-t', \&App::Asciio::Actions::Align::align, 'top'],
                        ),

        'Enter Other Group' => USE_GROUP('other_group_name'),
        ),

# ... other actions
);
        
'group_other_group_name' => GROUP ( ...), # note that 'group_' is needed in the declaration of groups referred to by USE_GROUP
```


