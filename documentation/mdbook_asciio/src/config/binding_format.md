# BINDINGS FORMAT

**Asciio** processes external configuration files that dynamically define the application's keybindings, keybindings structure, and context menus.

These files are valid Perl scripts, you can defined code to bind to in the files but we recommend you create a module instead.

## Action Definition Commands

Use the following commands to define commands:

| Subroutine Name                        | Purpose                                                             | Data Format Expected              |
| ---                                    | ---                                                                 | ---                               |
| register_action_handlers               | Defines actions, and multi-level action groups.                     |                                   |
| register_action_handlers_with_override | As above but also **deletes** old shortcuts                         | list of key-value pairs           |
| PROXY_GROUP                            | Defines the content of the top-level grouping used for menu display | shortcut and a list of action     |
| ROOT_GROUP                             | Defines actions that are registered in the default group            | information and a list of actions |
| GROUP                                  | Used to declare a nested, ordered, action group.                    |                                   |
| USE_GROUP                              | binds a shortcut with a group                                       |                                   |
| CONTEXT_MENU                           | Defines actions that are only accessible via a context menu         |                                   |
| MACRO                                  | associate a action to set of commands                               |                                   |

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

| Key          | Type                      | Purpose                                                        |
| ---          | ---                       | ---                                                            |
| SHORTCUTS    | Scalar or ArrayRef        | The keybinding(s) that activate/enter this group               |
| ENTER_GROUP  | CodeRef,ArrayRef or undef | Optional code to execute *when* the group is activated.        |
| ESCAPE_KEYS  | Scalar or ArrayRef        | Optional keybinding(s) that deactivate/exit the group          |
| ESCAPE_GROUP | CodeRef                   | Optional code to execute *when* the group is exited.           |
| CAPTURE_KEYS |                           | Pass as sub to ENTER_GROUP if you just want to capture keys    |
| HIDE         | Scalar (0 or 1)           | Optional atrribute, the group is hidden from bindingsdisplays. |

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

### Navigating groups programatically

There are two possibilities:

- run_actions
- run_actions_by name

*run_actions* runs actions in the current binding (it is used by *Asciio* to handle keyboard events).

*run_actions_by_name* executes one of more named functions (with optional arguments); the functions are registered in the default config.

*Asciio* looks up keyboard events and run the correxponding function in the current binding group. 

Groups are also registered functions, functions that manipulates the current binding group.

We can programmatically manipulate the current bindings but it's much easier to define a group of bindings that we can make the active binding group; that's exactly what GROUP does.

To change the current keyboard bindings, we just need to run the right GROUP. 

```perl
$self->run_actions_by_name("the GROUP name") ;
```

That's available anywhere but the right way to do it is in the config so we get a keyboard driven flow rather than a code driven flow with if-then-else.

The configuration below is to get in group 'x' from group 'Insert ->' and back.

Two solutions are presented, the difference is explained below.

Note: the normal behavior when exiting a GROUP, is to reset to the default keyboard bindings. 

```perl

'Insert ->' => GROUP
	(
	SHORTCUTS => '000-i',
	'X ->'    => ['000-x', USE_GROUP('x')] ,
	),

	'group_x' => GROUP
		(
		SHORTCUTS    => 'group_x',
		ESCAPE_KEYS  => '000-Escape',
		        
		# solution 1
		ESCAPE_GROUP => sub { $_[0]->run_actions_by_name("Insert ->") ;},
		
		#solution 2
		'return to Insert'   => ['000-Escape', sub{ $_[0]->run_actions_by_name("Insert ->") ; }, undef , {HIDE => 1}], 
		),
```


- if you decide to use *solution 1*, the code for *solution 2* is not needed
- if you decide to use *solution 2*, the code for *solution 1* is not needed
- you can use *solution 1* and *solution 2* together but in this case there is no gain

Difference:
- *solution 1* will change the current bindings but the bindings help
- *solution 2* will change the current bindings and display the bindings help

Note:
- we stop capturing keyboard input to GROUP(X) bindings because both solutions use '000-Escape'.
- we're not forced to jump "back" to the previous group, we could jump anywhere, that's what USE_GROUP does.

### Macros

Macros allows ***Single Action Definition*** to run multiple commands.

The commands can be:
- the name of another action
- an array containing
    - a Perl subroutine reference to execute
    - optional arguments to be passed to the CODE subroutine


**Example of MACRO usage:**

```perl

'Add diagonal arrow' => 
	[
	'0A0-a',
	MACRO
		(
		'Add arrow',
		'enable diagonals',
		# you can also call actions directly
		# [\&App::Asciio::Actions::Arrow::allow_diagonals, 1],
		)
	],
```

