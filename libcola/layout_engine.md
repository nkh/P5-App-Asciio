# Layout Engine Protocol and JSON Format  
Complete Documentation — Full Version (Part 1 of 6)

# Table of Contents

1. Overview  
2. Process Model  
3. Command‑Line Options  
   - 3.1 Input Separator  
   - 3.2 Output Separator  
4. Request Format  
   - 4.1 id  
   - 4.2 nodes  
   - 4.3 edges  
   - 4.4 constraints  
     - 4.4.1 Layout Control  
     - 4.4.2 Grid, Snapping, and Attraction  
     - 4.4.3 Node Spacing and Padding  
     - 4.4.4 Alignment Constraints  
     - 4.4.5 Ordering Constraints  
     - 4.4.6 Non‑Overlap Constraints  
     - 4.4.7 Fixed Positions  
     - 4.4.8 Routing Mode  
     - 4.4.9 Routing Parameters  
     - 4.4.10 Port Constraints  
     - 4.4.11 Edge Label Placement  
     - 4.4.12 Post‑Processing  
5. Response Format  
   - 5.1 Node Output Format  
   - 5.2 Edge Output Format  
   - 5.3 Metadata  
6. Separator Behavior  
   - 6.1 Input Separator  
   - 6.2 Output Separator  
7. Error Handling  
   - 7.1 Types of Errors  
   - 7.2 Error Recovery  
8. Layout Engine Internals  
   - 8.1 Node Layout (libcola)  
   - 8.2 Edge Routing (libavoid)  
   - 8.3 Coordinate System  
   - 8.4 Bounding Box  
9. Performance Considerations  
   - 9.1 Persistent Process  
   - 9.2 Request Size  
   - 9.3 Constraint Complexity  
   - 9.4 Routing Cost  
10. Constraint Reference  
11. Perl Integration  
12. Examples  
13. Size Limits  
14. Normalization and Scaling  
15. Bounding Box Calculation  
16. Coordinate Semantics  
17. Complete Request/Response Examples  
18. Exit Command  
19. Best Practices  
20. Summary  
21. End of Documentation

## 1. Overview

The `layout` program is a persistent, long‑running layout and routing engine designed for automated diagram generation, graph layout, and edge routing. It communicates exclusively through JSON over standard input and standard output, making it suitable for embedding in automation pipelines, interactive tools, and server‑side systems.

The engine provides:

- Node layout using libcola  
- Edge routing using libavoid  
- A composable constraint system  
- A persistent process model for high‑throughput use  
- A clean JSON‑in / JSON‑out protocol  
- Optional Perl integration via a Perl‑to‑JSON filter  
- Configurable separators for streaming multiple requests  
- Support for both layout and routing independently or together  

The engine does not maintain state between requests. Each request is processed independently and produces a complete response.

This document describes the entire protocol, including request format, response format, constraints, routing modes, separators, and integration details.

---

## 2. Process Model

The layout engine runs as a persistent process. It does not exit after processing a single request. Instead, it loops indefinitely until explicitly instructed to terminate.

The lifecycle of each request is:

1. The engine waits for input.  
2. It reads lines until it encounters the configured input separator.  
3. The accumulated text is parsed as JSON.  
4. If the JSON contains `"command": "exit"`, the engine terminates.  
5. Otherwise:  
   - Nodes are loaded  
   - Constraints are applied  
   - Layout is performed (unless disabled)  
   - Routing is performed (if enabled)  
6. A JSON response is written to stdout.  
7. If an output separator is configured, it is printed after the response.  
8. The engine returns to step 1.

This model allows clients to send many layout requests in sequence without restarting the process.

---

## 3. Command‑Line Options

The engine accepts two optional command‑line arguments that control how requests and responses are delimited.

### 3.1 `--input-separator=STRING`

Defines the separator that marks the end of each JSON request.

Example:

```
./layout --input-separator="---END---"
```

Behavior when provided:

- A line equal to STRING ends the current request.  
- Empty lines inside the JSON are allowed.  
- The separator itself is not part of the JSON.

Behavior when not provided:

- A blank line ends the current request.  
- Empty lines inside JSON are not allowed.  
- The engine treats any empty line as the end of the request.

This option is essential when sending complex or pretty‑printed JSON.

---

### 3.2 `--separator=STRING`

Defines the separator printed after each JSON response.

Example:

```
./layout --separator="---END---"
```

Behavior:

- After printing the JSON response, the engine prints STRING on its own line.  
- If not provided, no separator is printed.  
- This is useful for streaming clients that read until they see the separator.

---

## 4. Request Format

Each request is a single JSON object. It may span multiple lines and may contain nested structures.

General structure:

```
{
  "id": "req1",
  "nodes": [ ... ],
  "edges": [ ... ],
  "constraints": { ... }
}
```

The fields are described in detail below.

---

## 4.1 `id` (optional)

The `id` field is optional and may contain any JSON value. If present, it is echoed back in the response exactly as provided.

Purpose:

- Allows clients to correlate responses with requests  
- Especially useful when multiple requests are in flight  

Example:

```
"id": "request_42"
```

---

## 4.2 `nodes` (required)

The `nodes` array defines all nodes in the diagram. Each node is represented as an object with the following fields:

- id (string, required)  
- width (number, optional, default 60)  
- height (number, optional, default 40)  
- x (number, optional)  
- y (number, optional)

If `x` and `y` are omitted and layout is enabled, libcola computes positions.

Example:

```
"nodes": [
  { "id": "A", "width": 40, "height": 40, "x": 100, "y": 200 },
  { "id": "B", "width": 40, "height": 40, "x": 300, "y": 200 }
]
```

---

## 4.3 `edges` (optional)

The `edges` array defines connections between nodes.

Each edge:

- source (string, required)  
- target (string, required)

Example:

```
"edges": [
  { "source": "A", "target": "B" }
]
```

If routing is enabled, the engine computes a route for each edge.

---

## 4.4 `constraints` (optional, composable)

The `constraints` object controls layout behavior, spacing, alignment, routing, and postprocessing. All fields are optional and may be combined freely.

Example skeleton:

```
"constraints": {
  "layout": true,
  "grid_mode": "min_spacing",
  "grid": 100,
  "routing": "orthogonal"
}
```

The following sections describe each constraint category in detail.

---

## 4.4.1 Layout Control

```
"layout": true | false
```

- true (default): libcola layout is applied  
- false: node positions are taken as given; only routing is performed  

This is useful when the client wants to control node positions manually.

---

## 4.4.2 Grid, Snapping, and Attraction

The grid system supports several modes that influence node spacing, snapping, or attraction to grid points.

Fields:

- grid_mode  
- grid  
- snap_after_layout  
- snap_x_after  
- snap_y_after  

These modes are described in detail in Part 2.


# Layout Engine Protocol and JSON Format  



Complete Documentation — Full Version (Part 2 of 6)

## 4.4.2 Grid, Snapping, and Attraction (continued)

The grid system influences node spacing, snapping, and alignment. It is optional and fully composable with other constraints.

### `grid_mode`

Controls how the grid affects layout.

Allowed values:

- `"none"`  
  No grid influence.

- `"min_spacing"`  
  Nodes are kept at least `grid` units apart horizontally and vertically.

- `"snap"`  
  Nodes are snapped to the nearest grid intersection after layout.

- `"attract"`  
  Nodes are gently pulled toward grid intersections during layout.

### `grid`

A positive number defining the grid spacing in user units.

Example:

```
"grid": 100
```

### `snap_after_layout`

If true, nodes are snapped to the grid after layout completes.

### `snap_x_after`, `snap_y_after`

If provided, snapping can be restricted to one axis.

Examples:

```
"snap_x_after": true
"snap_y_after": false
```

---

## 4.4.3 Node Spacing and Padding

These constraints control minimum distances between nodes.

### `node_spacing`

Defines the minimum allowed distance between node bounding boxes.

Example:

```
"node_spacing": 40
```

### `padding`

Adds padding around the entire layout.

Example:

```
"padding": 20
```

---

## 4.4.4 Alignment Constraints

Alignment constraints allow nodes to be aligned along axes.

### Horizontal alignment

```
"align_horizontal": ["A", "B", "C"]
```

All listed nodes share the same y‑coordinate.

### Vertical alignment

```
"align_vertical": ["X", "Y"]
```

All listed nodes share the same x‑coordinate.

---

## 4.4.5 Ordering Constraints

Ordering constraints enforce relative ordering between nodes.

### `order_left_to_right`

Example:

```
"order_left_to_right": ["A", "B", "C"]
```

Ensures:

A.x < B.x < C.x

### `order_top_to_bottom`

Example:

```
"order_top_to_bottom": ["H", "I"]
```

Ensures:

H.y < I.y

---

## 4.4.6 Non‑Overlap Constraints

Non‑overlap is enabled by default when layout is true.

To disable:

```
"no_overlap": false
```

To enforce stronger separation:

```
"no_overlap_padding": 20
```

---

## 4.4.7 Fixed Positions

Nodes may be fixed in place:

```
"fixed": ["A", "B"]
```

Nodes listed here will not move during layout.

---

## 4.4.8 Edge Routing Mode

Routing is controlled by the `"routing"` field.

Allowed values:

- `"none"`  
  No routing is performed.

- `"straight"`  
  Straight‑line segments.

- `"polyline"`  
  Polyline routing with obstacle avoidance.

- `"orthogonal"`  
  Manhattan‑style routing using libavoid.

- `"orthogonal_compact"`  
  A more compact orthogonal routing mode.

Example:

```
"routing": "orthogonal"
```

---

## 4.4.9 Routing Parameters

Routing modes may accept additional parameters.

### `routing_padding`

Minimum distance between routed edges and node boundaries.

Example:

```
"routing_padding": 10
```

### `routing_grid`

Grid size for orthogonal routing.

Example:

```
"routing_grid": 20
```

### `avoid_overlaps`

If true, routed edges avoid crossing node bounding boxes.

Default: true

---

## 4.4.10 Port Constraints

Edges may connect to specific sides of nodes.

Example:

```
"ports": {
  "A": "east",
  "B": "west"
}
```

Allowed values:

- `"north"`  
- `"south"`  
- `"east"`  
- `"west"`  
- `"auto"` (default)

---

## 4.4.11 Edge Label Placement

Edge labels may be placed automatically.

Example:

```
"edge_labels": true
```

Optional parameters:

```
"edge_label_padding": 6
```

---

## 4.4.12 Post‑Processing

After layout and routing, optional post‑processing steps may be applied.

### `normalize_coordinates`

If true, the entire layout is shifted so that the minimum x and y are zero.

### `round_coordinates`

If true, coordinates are rounded to integers.

### `scale`

Scales all coordinates by a factor.

Example:

```
"scale": 2.0
```

---

## 5. Response Format

The response is a JSON object containing:

- The echoed `id` (if provided)  
- The final node positions  
- The routed edges (if routing is enabled)  
- Optional metadata  

General structure:

```
{
  "id": "req1",
  "nodes": [ ... ],
  "edges": [ ... ],
  "metadata": { ... }
}
```

---

## 5.1 Node Output Format

Each node is returned with:

- id  
- x  
- y  
- width  
- height  

Example:

```
"nodes": [
  { "id": "A", "x": 120.5, "y": 200.0, "width": 40, "height": 40 }
]
```

---

## 5.2 Edge Output Format

If routing is enabled, each edge includes a `"route"` array of points.

Example:

```
"edges": [
  {
    "source": "A",
    "target": "B",
    "route": [
      { "x": 140, "y": 220 },
      { "x": 200, "y": 220 },
      { "x": 260, "y": 220 }
    ]
  }
]
```

If routing is disabled:

```
"edges": [
  { "source": "A", "target": "B" }
]
```

---

## 5.3 Metadata

Metadata may include:

- layout time  
- routing time  
- number of iterations  
- bounding box  

Example:

```
"metadata": {
  "layout_time_ms": 12,
  "routing_time_ms": 4,
  "bbox": { "x": 0, "y": 0, "width": 800, "height": 600 }
}
```


# Layout Engine Protocol and JSON Format  
Complete Documentation — Full Version (Part 3 of 6)

## 6. Separator Behavior

Separators define how the engine reads requests and how clients detect the end of responses.

There are two independent separators:

- **Input separator**: ends a request  
- **Output separator**: ends a response  

Both are optional and configurable.

---

## 6.1 Input Separator

Configured via:

```
--input-separator=STRING
```

### Behavior

- The engine reads lines until it encounters a line that matches STRING exactly.
- The separator line itself is not included in the JSON.
- Empty lines inside the JSON are allowed.

### Without an input separator

If no input separator is provided:

- A **blank line** ends the request.
- Empty lines inside JSON are **not allowed**.
- Pretty‑printed JSON becomes impossible.

### Example

```
{ "id": 1, "nodes": [] }
---END---
```

---

## 6.2 Output Separator

Configured via:

```
--separator=STRING
```

### Behavior

- After printing the JSON response, the engine prints STRING on its own line.
- If not provided, no separator is printed.

### Example

Response:

```
{ "id": 1, "nodes": [] }
---END---
```

---

## 7. Error Handling

The engine attempts to provide clear, structured error messages.

Errors are returned as JSON objects with:

- `"error"`: a short error code  
- `"message"`: human‑readable explanation  
- `"id"`: echoed request ID (if provided)  

Example:

```
{
  "id": "req1",
  "error": "invalid_json",
  "message": "Failed to parse JSON input."
}
```

---

## 7.1 Types of Errors

### `invalid_json`

The input could not be parsed.

### `missing_nodes`

The request did not include a `nodes` array.

### `invalid_constraint`

A constraint field was malformed or unsupported.

### `routing_failure`

Routing failed due to impossible geometry or invalid parameters.

### `layout_failure`

Layout failed due to invalid constraints or numerical instability.

---

## 7.2 Error Recovery

The engine:

- Returns an error JSON object  
- Prints the output separator (if configured)  
- Continues running  
- Waits for the next request  

The process does **not** terminate unless the request explicitly contains:

```
{ "command": "exit" }
```

---

## 8. Layout Engine Internals

This section describes how the engine uses libcola and libavoid.

---

## 8.1 Node Layout (libcola)

When `"layout": true`, the engine:

1. Loads all nodes into a libcola graph.  
2. Applies constraints:  
   - alignment  
   - ordering  
   - non‑overlap  
   - fixed positions  
   - grid attraction  
3. Runs the solver.  
4. Extracts final node positions.  

### 8.1.1 Iterations and Convergence

The solver runs until:

- convergence is reached, or  
- the maximum iteration count is reached  

The iteration count may be exposed in metadata.

---

## 8.2 Edge Routing (libavoid)

If routing is enabled:

1. Node shapes are added as obstacles.  
2. Each edge is added as a connector.  
3. libavoid computes a route according to the selected mode.  
4. The route is returned as a list of points.

### 8.2.1 Routing Modes

#### Straight

A single segment from source center to target center.

#### Polyline

Polyline routing with obstacle avoidance.

#### Orthogonal

Manhattan routing with 90‑degree turns.

#### Orthogonal Compact

A more compact variant with fewer bends.

---

## 8.3 Coordinate System

The engine uses a standard Cartesian coordinate system:

- x increases to the right  
- y increases downward  
- units are arbitrary but consistent  

Node positions refer to the **top‑left corner** of the node.

---

## 8.4 Bounding Box

The engine computes a bounding box that encloses all nodes and routed edges.

Example:

```
"bbox": { "x": 0, "y": 0, "width": 800, "height": 600 }
```

This is useful for:

- rendering  
- exporting  
- scaling  
- centering  

---

## 9. Performance Considerations

The engine is optimized for:

- repeated use  
- low overhead  
- predictable performance  

### 9.1 Persistent Process

Running the engine as a persistent process avoids:

- repeated initialization  
- repeated library loading  
- repeated memory allocation  

This dramatically improves throughput.

---

## 9.2 Request Size

Large requests (hundreds of nodes, thousands of edges) may require:

- more layout iterations  
- more routing time  
- more memory  

The engine attempts to remain stable under heavy load.

---

## 9.3 Constraint Complexity

Some constraints increase computational cost:

- large alignment groups  
- many ordering constraints  
- dense non‑overlap regions  
- complex routing obstacles  

Use constraints judiciously for best performance.

---

## 9.4 Routing Cost

Routing is often the most expensive step, especially in orthogonal mode.

Performance depends on:

- number of edges  
- number of obstacles  
- routing grid size  
- padding settings  

---

End of Part 3 of 6.


# Layout Engine Protocol and JSON Format  
Complete Documentation — Full Version (Part 4 of 6)

## 10. Constraint Reference (Complete)

This section provides a full reference for all constraint fields supported by the engine.  
All constraints are optional and composable.

---

## 10.1 Layout Control

### `layout`
```
true | false
```

- `true` (default): run libcola layout  
- `false`: skip layout; use provided node positions  

---

## 10.2 Grid and Snapping

### `grid_mode`
```
"none" | "min_spacing" | "snap" | "attract"
```

### `grid`
Grid spacing in user units.

### `snap_after_layout`
Snap nodes to grid after layout.

### `snap_x_after`, `snap_y_after`
Axis‑specific snapping.

---

## 10.3 Node Spacing

### `node_spacing`
Minimum spacing between node bounding boxes.

### `padding`
Padding around the entire layout.

---

## 10.4 Alignment

### Horizontal alignment
```
"align_horizontal": ["A", "B", "C"]
```

### Vertical alignment
```
"align_vertical": ["X", "Y"]
```

---

## 10.5 Ordering

### Left‑to‑right ordering
```
"order_left_to_right": ["A", "B", "C"]
```

### Top‑to‑bottom ordering
```
"order_top_to_bottom": ["H", "I"]
```

---

## 10.6 Non‑Overlap

### Disable non‑overlap
```
"no_overlap": false
```

### Extra padding
```
"no_overlap_padding": 20
```

---

## 10.7 Fixed Nodes

### Fix nodes in place
```
"fixed": ["A", "B"]
```

---

## 10.8 Routing Mode

### `routing`
```
"none" | "straight" | "polyline" | "orthogonal" | "orthogonal_compact"
```

---

## 10.9 Routing Parameters

### `routing_padding`
Minimum distance between edges and nodes.

### `routing_grid`
Grid size for orthogonal routing.

### `avoid_overlaps`
Avoid node obstacles (default: true).

---

## 10.10 Ports

### Example
```
"ports": {
  "A": "east",
  "B": "west"
}
```

Allowed values:

- `"north"`  
- `"south"`  
- `"east"`  
- `"west"`  
- `"auto"` (default)

---

## 10.11 Edge Labels

### Enable labels
```
"edge_labels": true
```

### Padding
```
"edge_label_padding": 6
```

---

## 10.12 Post‑Processing

### Normalize coordinates
```
"normalize_coordinates": true
```

### Round coordinates
```
"round_coordinates": true
```

### Scale
```
"scale": 2.0
```

---

## 11. Perl Integration

The engine is designed to integrate cleanly with Perl‑based automation pipelines.

A typical workflow:

1. Perl script constructs a Perl data structure.  
2. Data is encoded as JSON.  
3. JSON is sent to the layout engine.  
4. The engine returns JSON.  
5. Perl decodes the JSON and continues processing.

---

## 11.1 Perl‑to‑JSON Filter

A helper script may be used to:

- read Perl data  
- convert to JSON  
- send to the engine  
- read the response  
- decode JSON back into Perl structures  

This allows seamless integration with existing Perl tools.

---

## 11.2 Example Perl Workflow

### Constructing a request

```perl
my $req = {
  id => "example",
  nodes => [
    { id => "A", width => 40, height => 40 },
    { id => "B", width => 40, height => 40 }
  ],
  edges => [
    { source => "A", target => "B" }
  ],
  constraints => {
    layout => 1,
    routing => "orthogonal"
  }
};
```

### Sending to the engine

```perl
print $json->encode($req), "\n---END---\n";
```

### Reading the response

```perl
my $resp = decode_json($response_text);
```

---

## 11.3 Persistent Engine Usage

Perl scripts typically:

- start the engine once  
- send many requests  
- read many responses  
- terminate the engine at the end  

This avoids repeated startup overhead.

---

## 12. Examples

This section provides complete examples of requests and responses.

---

## 12.1 Minimal Example

### Request

```
{
  "nodes": [
    { "id": "A" },
    { "id": "B" }
  ],
  "edges": [
    { "source": "A", "target": "B" }
  ]
}
```

### Response (simplified)

```
{
  "nodes": [
    { "id": "A", "x": 100, "y": 200 },
    { "id": "B", "x": 300, "y": 200 }
  ],
  "edges": [
    { "source": "A", "target": "B", "route": [ ... ] }
  ]
}
```

---

## 12.2 Orthogonal Routing Example

### Request

```
{
  "nodes": [
    { "id": "A", "width": 60, "height": 40 },
    { "id": "B", "width": 60, "height": 40 }
  ],
  "edges": [
    { "source": "A", "target": "B" }
  ],
  "constraints": {
    "routing": "orthogonal",
    "routing_grid": 20
  }
}
```

### Response (simplified)

```
{
  "nodes": [ ... ],
  "edges": [
    {
      "source": "A",
      "target": "B",
      "route": [
        { "x": 130, "y": 220 },
        { "x": 200, "y": 220 },
        { "x": 270, "y": 220 }
      ]
    }
  ]
}
```

---

End of Part 4 of 6.



# Layout Engine Protocol and JSON Format  
Complete Documentation — Full Version (Part 5 of 6)

## 12.3 Fixed‑Position Example

### Request

```
{
  "nodes": [
    { "id": "A", "x": 100, "y": 100 },
    { "id": "B" },
    { "id": "C" }
  ],
  "constraints": {
    "layout": true,
    "fixed": ["A"]
  }
}
```

### Explanation

- Node **A** remains at (100, 100).  
- Nodes **B** and **C** are positioned relative to A.  
- Non‑overlap and spacing constraints still apply.

### Response (simplified)

```
{
  "nodes": [
    { "id": "A", "x": 100, "y": 100 },
    { "id": "B", "x": 240, "y": 100 },
    { "id": "C", "x": 240, "y": 200 }
  ]
}
```

---

## 12.4 Alignment Example

### Request

```
{
  "nodes": [
    { "id": "A" },
    { "id": "B" },
    { "id": "C" }
  ],
  "constraints": {
    "align_horizontal": ["A", "B", "C"]
  }
}
```

### Explanation

All nodes share the same **y** coordinate.

### Response (simplified)

```
{
  "nodes": [
    { "id": "A", "y": 200 },
    { "id": "B", "y": 200 },
    { "id": "C", "y": 200 }
  ]
}
```

---

## 12.5 Ordering Example

### Request

```
{
  "nodes": [
    { "id": "A" },
    { "id": "B" },
    { "id": "C" }
  ],
  "constraints": {
    "order_left_to_right": ["A", "B", "C"]
  }
}
```

### Explanation

The solver enforces:

A.x < B.x < C.x

### Response (simplified)

```
{
  "nodes": [
    { "id": "A", "x": 100 },
    { "id": "B", "x": 240 },
    { "id": "C", "x": 380 }
  ]
}
```

---

## 12.6 Grid Snapping Example

### Request

```
{
  "nodes": [
    { "id": "A" },
    { "id": "B" }
  ],
  "constraints": {
    "grid_mode": "snap",
    "grid": 50
  }
}
```

### Explanation

After layout, nodes are snapped to the nearest 50‑unit grid intersection.

### Response (simplified)

```
{
  "nodes": [
    { "id": "A", "x": 100, "y": 150 },
    { "id": "B", "x": 200, "y": 150 }
  ]
}
```

---

## 12.7 Orthogonal Compact Routing Example

### Request

```
{
  "nodes": [
    { "id": "A", "width": 60, "height": 40 },
    { "id": "B", "width": 60, "height": 40 }
  ],
  "edges": [
    { "source": "A", "target": "B" }
  ],
  "constraints": {
    "routing": "orthogonal_compact",
    "routing_padding": 8
  }
}
```

### Response (simplified)

```
{
  "edges": [
    {
      "source": "A",
      "target": "B",
      "route": [
        { "x": 130, "y": 220 },
        { "x": 200, "y": 220 }
      ]
    }
  ]
}
```

---

## 13. Size Limits

The engine is designed to handle large diagrams, but practical limits exist.

### 13.1 Node Count

Typical safe ranges:

- 1–500 nodes: fast  
- 500–2000 nodes: moderate  
- 2000+ nodes: heavy  

### 13.2 Edge Count

Routing cost grows with edges:

- Straight: O(E)  
- Polyline: O(E log E)  
- Orthogonal: O(E × obstacles)  

### 13.3 Constraint Complexity

Large alignment or ordering groups increase solver time.

### 13.4 JSON Size

Requests larger than several megabytes may:

- increase parsing time  
- increase memory usage  
- slow down routing  

---

## 14. Normalization and Scaling

Normalization and scaling are optional post‑processing steps.

### 14.1 Normalization

```
"normalize_coordinates": true
```

Shifts the entire layout so that:

- min_x = 0  
- min_y = 0  

### 14.2 Rounding

```
"round_coordinates": true
```

Rounds all coordinates to integers.

### 14.3 Scaling

```
"scale": 1.5
```

Multiplies all coordinates by the given factor.

---

## 15. Bounding Box Calculation

The bounding box includes:

- all nodes  
- all routed edges  
- padding (if any)  

Example:

```
"bbox": {
  "x": 0,
  "y": 0,
  "width": 900,
  "height": 700
}
```

This is useful for:

- rendering  
- exporting  
- centering  
- zooming  

---

## 16. Coordinate Semantics

### 16.1 Node Coordinates

Node coordinates refer to the **top‑left corner** of the node.

### 16.2 Edge Route Coordinates

Each route point is an absolute coordinate in the same coordinate system.

### 16.3 Units

Units are arbitrary but consistent across:

- nodes  
- edges  
- routing  
- constraints  

---

End of Part 5 of 6.


# Layout Engine Protocol and JSON Format  
Complete Documentation — Full Version (Part 6 of 6)

## 17. Complete Request/Response Examples

This section provides full, realistic examples that combine multiple constraints, routing modes, and post‑processing options.

---

## 17.1 Full Layout + Orthogonal Routing Example

### Request

```
{
  "id": "full_example",
  "nodes": [
    { "id": "A", "width": 60, "height": 40 },
    { "id": "B", "width": 60, "height": 40 },
    { "id": "C", "width": 60, "height": 40 }
  ],
  "edges": [
    { "source": "A", "target": "B" },
    { "source": "B", "target": "C" }
  ],
  "constraints": {
    "layout": true,
    "node_spacing": 80,
    "align_vertical": ["A", "B", "C"],
    "routing": "orthogonal",
    "routing_padding": 10,
    "routing_grid": 20,
    "normalize_coordinates": true,
    "round_coordinates": true
  }
}
```

### Response (simplified)

```
{
  "id": "full_example",
  "nodes": [
    { "id": "A", "x": 0, "y": 0 },
    { "id": "B", "x": 0, "y": 120 },
    { "id": "C", "x": 0, "y": 240 }
  ],
  "edges": [
    {
      "source": "A",
      "target": "B",
      "route": [
        { "x": 30, "y": 40 },
        { "x": 30, "y": 120 }
      ]
    },
    {
      "source": "B",
      "target": "C",
      "route": [
        { "x": 30, "y": 160 },
        { "x": 30, "y": 240 }
      ]
    }
  ],
  "metadata": {
    "layout_time_ms": 14,
    "routing_time_ms": 6,
    "bbox": { "x": 0, "y": 0, "width": 120, "height": 300 }
  }
}
```

---

## 17.2 Layout Disabled + Routing Only Example

### Request

```
{
  "nodes": [
    { "id": "A", "x": 100, "y": 100 },
    { "id": "B", "x": 400, "y": 300 }
  ],
  "edges": [
    { "source": "A", "target": "B" }
  ],
  "constraints": {
    "layout": false,
    "routing": "polyline"
  }
}
```

### Explanation

- Node positions are taken as‑is.  
- Only routing is performed.

---

## 17.3 Grid Attraction + Ordering Example

### Request

```
{
  "nodes": [
    { "id": "A" },
    { "id": "B" },
    { "id": "C" }
  ],
  "constraints": {
    "grid_mode": "attract",
    "grid": 50,
    "order_left_to_right": ["A", "B", "C"]
  }
}
```

### Explanation

- Nodes are gently pulled toward grid intersections.  
- Ordering ensures A.x < B.x < C.x.

---

## 18. Exit Command

The engine terminates cleanly when it receives:

```
{ "command": "exit" }
```

Behavior:

- The engine prints no response.  
- The process exits immediately.  

This is the only way to terminate the persistent process.

---

## 19. Best Practices

### 19.1 Use an Input Separator

Always use:

```
--input-separator="---END---"
```

This allows:

- pretty‑printed JSON  
- multi‑line requests  
- embedded whitespace  

### 19.2 Use an Output Separator

Use:

```
--separator="---END---"
```

This makes it trivial for clients to detect response boundaries.

### 19.3 Keep Constraints Minimal

Only specify constraints you actually need.  
Unnecessary constraints slow down layout.

### 19.4 Normalize and Round for Rendering

Use:

```
"normalize_coordinates": true,
"round_coordinates": true
```

This produces clean, renderer‑friendly coordinates.

---

## 20. Summary

The layout engine provides:

- A persistent JSON‑based layout and routing service  
- Full libcola layout with constraints  
- Full libavoid routing with multiple modes  
- A clean, composable constraint system  
- Perl‑friendly integration  
- Configurable separators for streaming  
- Robust error handling  
- High‑performance operation for large diagrams  

It is designed to be embedded into automation pipelines, rendering systems, and interactive tools that require predictable, high‑quality layout and routing.

---

## 21. End of Documentation

This concludes the complete, full‑length specification of the layout engine protocol, request/response format, constraints, routing modes, and integration details.

