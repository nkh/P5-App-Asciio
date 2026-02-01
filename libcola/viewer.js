
(function() {
  const svg = document.getElementById('graph');
  const container = document.getElementById('container');
  const fitBtn = document.getElementById('fitBtn');
  const zoomInBtn = document.getElementById('zoomInBtn');
  const zoomOutBtn = document.getElementById('zoomOutBtn');

  const toggleNodes = document.getElementById('toggleNodes');
  const toggleEdges = document.getElementById('toggleEdges');
  const toggleGrid = document.getElementById('toggleGrid');
  const toggleClusters = document.getElementById('toggleClusters');
  const toggleBBox = document.getElementById('toggleBBox');

  const tooltip = document.getElementById('tooltip');

  const data = window.LAYOUT_VIEWER_DATA || {};
  const constraints = data.constraints || {};
  const engine = data.engine || {};

  const config = window.LAYOUT_VIEWER_CONFIG || {
    colors: {},
    features: {},
    opacity: {}
  };

  let viewBox = svg.getAttribute('viewBox').split(/\s+/).map(Number);
  const originalViewBox = viewBox.slice();

  function setViewBox(vb) {
    svg.setAttribute('viewBox', vb.join(' '));
    viewBox = vb;
  }

  function fitToView() {
    setViewBox(originalViewBox.slice());
  }

  function zoom(factor, cx, cy) {
    const [x, y, w, h] = viewBox;
    const mx = cx !== undefined ? cx : x + w / 2;
    const my = cy !== undefined ? cy : y + h / 2;

    const newW = w * factor;
    const newH = h * factor;

    const dx = mx - (mx - x) * factor;
    const dy = my - (my - y) * factor;

    setViewBox([dx, dy, newW, newH]);
  }

  container.addEventListener('wheel', function(ev) {
    if (!ev.ctrlKey && !ev.metaKey) {
      return; // normal scrolling
    }
    ev.preventDefault();
    const rect = svg.getBoundingClientRect();
    const cx = viewBox[0] + (ev.clientX - rect.left) * (viewBox[2] / rect.width);
    const cy = viewBox[1] + (ev.clientY - rect.top) * (viewBox[3] / rect.height);

    const factor = ev.deltaY < 0 ? 0.9 : 1.1;
    zoom(factor, cx, cy);
  }, { passive: false });

  fitBtn.addEventListener('click', fitToView);
  zoomInBtn.addEventListener('click', function() { zoom(0.9); });
  zoomOutBtn.addEventListener('click', function() { zoom(1.1); });

  // Layer toggles
  function setLayerVisible(id, visible) {
    const layer = document.getElementById(id);
    if (!layer) return;
    if (visible) {
      layer.classList.remove('hidden');
    } else {
      layer.classList.add('hidden');
    }
  }

  toggleNodes.addEventListener('change', () => {
    setLayerVisible('layer-nodes', toggleNodes.checked);
  });
  toggleEdges.addEventListener('change', () => {
    setLayerVisible('layer-edges', toggleEdges.checked);
  });
  toggleGrid.addEventListener('change', () => {
    setLayerVisible('layer-grid', toggleGrid.checked);
  });
  toggleClusters.addEventListener('change', () => {
    setLayerVisible('layer-clusters', toggleClusters.checked);
  });
  toggleBBox.addEventListener('change', () => {
    setLayerVisible('layer-bbox', toggleBBox.checked);
  });

  // Tooltip handling
  function showTooltip(text, x, y) {
    tooltip.textContent = text;
    tooltip.style.left = (x + 10) + 'px';
    tooltip.style.top = (y + 10) + 'px';
    tooltip.style.display = 'block';
  }
  function hideTooltip() {
    tooltip.style.display = 'none';
  }

  function attachTooltips() {
    const nodes = svg.querySelectorAll('.node');
    nodes.forEach(g => {
      const text = g.getAttribute('data-tooltip');
      if (!text) return;
      g.addEventListener('mousemove', ev => {
        showTooltip(text, ev.clientX, ev.clientY);
      });
      g.addEventListener('mouseleave', hideTooltip);
    });

    const edges = svg.querySelectorAll('.edge');
    edges.forEach(path => {
      const text = path.getAttribute('data-tooltip');
      if (!text) return;
      path.addEventListener('mousemove', ev => {
        showTooltip(text, ev.clientX, ev.clientY);
      });
      path.addEventListener('mouseleave', hideTooltip);
    });
  }

  // Constraint-aware styling
  function applyConstraintStyling() {
    const alignV = new Set(constraints.align_vertical || []);
    const alignH = new Set(constraints.align_horizontal || []);
    const orderLR = new Set(constraints.order_left_to_right || []);
    const orderTB = new Set(constraints.order_top_to_bottom || []);
    const fixed = new Set(constraints.fixed || []);
    const clusters = constraints.clusters || [];

    const nodeGroups = svg.querySelectorAll('.node');
    const nodeById = {};
    nodeGroups.forEach(g => {
      const id = g.getAttribute('data-node-id');
      if (!id) return;
      nodeById[id] = g;
      g.classList.remove(
        'node-align-vertical',
        'node-align-horizontal',
        'node-order-left-right',
        'node-order-top-bottom',
        'node-fixed',
        'node-source',
        'node-sink'
      );
      const rect = g.querySelector('.node-rect');
      if (rect) {
        rect.style.fill = '';   // reset inline overrides
        rect.style.stroke = '';
        rect.style.strokeWidth = '';
      }
    });

    // Basic source/sink detection from edges
    const inDeg = {};
    const outDeg = {};
    const edgeGroups = svg.querySelectorAll('.edge-group');
    edgeGroups.forEach(g => {
      const path = g.querySelector('.edge');
      if (!path) return;
      const tooltip = path.getAttribute('data-tooltip') || '';
      const m = tooltip.match(/Edge\s+(\S+)\s+→\s+(\S+)/);
      if (!m) return;
      const src = m[1];
      const dst = m[2];
      outDeg[src] = (outDeg[src] || 0) + 1;
      inDeg[dst] = (inDeg[dst] || 0) + 1;
    });

    const useConstraintColors = !!config.features.constraint_colors;
    const useFixedHighlight   = !!config.features.fixed_highlighting;
    const useSourceSink       = !!config.features.source_sink;

    Object.keys(nodeById).forEach(id => {
      const g = nodeById[id];
      const rect = g.querySelector('.node-rect');
      if (!rect) return;

      // Constraint-based fill
      if (useConstraintColors) {
        if (alignV.has(id)) {
          g.classList.add('node-align-vertical');
          if (config.colors.align_vertical) {
            rect.style.fill = config.colors.align_vertical;
          }
        } else if (alignH.has(id)) {
          g.classList.add('node-align-horizontal');
          if (config.colors.align_horizontal) {
            rect.style.fill = config.colors.align_horizontal;
          }
        } else if (orderLR.has(id)) {
          g.classList.add('node-order-left-right');
          if (config.colors.order_left_right) {
            rect.style.fill = config.colors.order_left_right;
          }
        } else if (orderTB.has(id)) {
          g.classList.add('node-order-top-bottom');
          if (config.colors.order_top_bottom) {
            rect.style.fill = config.colors.order_top_bottom;
          }
        }
      }

      // Fixed / source / sink
      const indeg = inDeg[id] || 0;
      const outdeg = outDeg[id] || 0;

      if (useFixedHighlight && fixed.has(id)) {
        g.classList.add('node-fixed');
        rect.style.stroke = config.colors.fixed || rect.style.stroke || '#ff0000';
        rect.style.strokeWidth = 2;
      } else if (useSourceSink) {
        if (outdeg > 0 && indeg === 0) {
          g.classList.add('node-source');
          rect.style.stroke = config.colors.source || rect.style.stroke || '#00aa00';
          rect.style.strokeWidth = 2;
        } else if (indeg > 0 && outdeg === 0) {
          g.classList.add('node-sink');
          rect.style.stroke = config.colors.sink || rect.style.stroke || '#0000aa';
          rect.style.strokeWidth = 2;
        }
      }
    });

    // Clusters
    const layerClusters = document.getElementById('layer-clusters');
    if (layerClusters) {
      layerClusters.innerHTML = '';
      if (config.features.clusters) {
        clusters.forEach(cl => {
          const ids = cl.nodes || [];
          let cx1, cy1, cx2, cy2;
          ids.forEach(id => {
            const g = nodeById[id];
            if (!g) return;
            const rect = g.querySelector('.node-rect');
            if (!rect) return;
            const x = parseFloat(rect.getAttribute('x'));
            const y = parseFloat(rect.getAttribute('y'));
            const w = parseFloat(rect.getAttribute('width'));
            const h = parseFloat(rect.getAttribute('height'));
            const lx = x;
            const rx = x + w;
            const by = y;
            const ty = y + h;
            cx1 = cx1 === undefined ? lx : Math.min(cx1, lx);
            cy1 = cy1 === undefined ? by : Math.min(cy1, by);
            cx2 = cx2 === undefined ? rx : Math.max(cx2, rx);
            cy2 = cy2 === undefined ? ty : Math.max(cy2, ty);
          });
          if (cx1 === undefined) return;
          const pad = 8;
          const rect = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
          rect.setAttribute('x', cx1 - pad);
          rect.setAttribute('y', cy1 - pad);
          rect.setAttribute('width', (cx2 - cx1) + 2 * pad);
          rect.setAttribute('height', (cy2 - cy1) + 2 * pad);
          rect.setAttribute('rx', 8);
          rect.setAttribute('ry', 8);
          const color = config.colors.cluster || '#ff00ff';
          const op = config.opacity.cluster != null ? config.opacity.cluster : 0.15;
          rect.setAttribute('fill', color);
          rect.setAttribute('fill-opacity', op);
          rect.setAttribute('stroke', color);
          rect.setAttribute('stroke-width', 1);
          layerClusters.appendChild(rect);
        });
      }
    }

    // BBox
    const layerBBox = document.getElementById('layer-bbox');
    if (layerBBox) {
      layerBBox.innerHTML = '';
      if (config.features.bbox) {
        const rect = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
        rect.setAttribute('x', originalViewBox[0]);
        rect.setAttribute('y', originalViewBox[1]);
        rect.setAttribute('width', originalViewBox[2]);
        rect.setAttribute('height', originalViewBox[3]);
        const color = config.colors.bbox || '#000000';
        rect.setAttribute('fill', 'none');
        rect.setAttribute('stroke', color);
        rect.setAttribute('stroke-width', 1);
        rect.setAttribute('stroke-dasharray', '4 4');
        layerBBox.appendChild(rect);
      }
    }

    // Grid
    const layerGrid = document.getElementById('layer-grid');
    if (layerGrid) {
      layerGrid.innerHTML = '';
      if (config.features.grid) {
        const g = constraints.grid;
        if (g && g > 0) {
          const [vx, vy, vw, vh] = originalViewBox;
          const color = config.colors.grid || '#cccccc';
          const op = config.opacity.grid != null ? config.opacity.grid : 0.08;
          for (let x = Math.floor(vx / g) * g; x <= vx + vw; x += g) {
            const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
            line.setAttribute('x1', x);
            line.setAttribute('y1', vy);
            line.setAttribute('x2', x);
            line.setAttribute('y2', vy + vh);
            line.setAttribute('stroke', color);
            line.setAttribute('stroke-width', 0.5);
            line.setAttribute('stroke-opacity', op);
            layerGrid.appendChild(line);
          }
          for (let y = Math.floor(vy / g) * g; y <= vy + vh; y += g) {
            const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
            line.setAttribute('x1', vx);
            line.setAttribute('y1', y);
            line.setAttribute('x2', vx + vw);
            line.setAttribute('y2', y);
            line.setAttribute('stroke', color);
            line.setAttribute('stroke-width', 0.5);
            line.setAttribute('stroke-opacity', op);
            layerGrid.appendChild(line);
          }
        }
      }
    }

    // Edge labels visibility (in case config.features.edge_labels is false)
    const edgeLabels = svg.querySelectorAll('.edge-label');
    edgeLabels.forEach(lbl => {
      if (config.features.edge_labels === false) {
        lbl.classList.add('hidden');
      } else {
        lbl.classList.remove('hidden');
      }
    });
  }

  // Initial layer visibility from config
  setLayerVisible('layer-grid', !!config.features.grid);
  setLayerVisible('layer-clusters', !!config.features.clusters);
  setLayerVisible('layer-bbox', !!config.features.bbox);

  // Initial setup
  fitToView();
  applyConstraintStyling();
  attachTooltips();
})();
