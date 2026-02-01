#include <iostream>
#include <vector>
#include <map>
#include <cmath>
#include <limits>
#include <string>

#include <nlohmann/json.hpp>

#include "libcola/cola.h"
#include "libcola/compound_constraints.h"
#include "libcola/cc_nonoverlapconstraints.h"
#include "libvpsc/rectangle.h"

#include "libavoid/router.h"
#include "libavoid/shape.h"
#include "libavoid/connector.h"

using json = nlohmann::json;
using namespace Avoid;

static double snap(double v, double g) {
    if (g <= 0) return v;
    return std::round(v / g) * g;
}

struct Context {
    json input;
    vpsc::Rectangles rects;
    std::map<std::string, unsigned> idx;
    std::vector<cola::Edge> edges;
    cola::CompoundConstraints ccs;
    cola::DesiredPositions desired;
    double grid = 0.0;
    bool use_desired = false;
};

static void build_nodes_and_edges(Context &ctx) {
    auto &input = ctx.input;

    for (size_t i = 0; i < input["nodes"].size(); i++) {
        auto &n = input["nodes"][i];
        double w = n.value("width", 60.0);
        double h = n.value("height", 40.0);

        double x = n.value("x", 0.0);
        double y = n.value("y", 0.0);

        ctx.rects.push_back(new vpsc::Rectangle(x - w / 2.0, x + w / 2.0,
                                                y - h / 2.0, y + h / 2.0));
        ctx.idx[n["id"]] = i;
    }

    for (auto &e : input["edges"]) {
        ctx.edges.emplace_back(ctx.idx[e["source"]], ctx.idx[e["target"]]);
    }

    auto *ex = new cola::NonOverlapConstraintExemptions();
    auto *noc = new cola::NonOverlapConstraints(ex);

    for (size_t i = 0; i < ctx.rects.size(); i++) {
        double halfW = ctx.rects[i]->width() / 2.0;
        double halfH = ctx.rects[i]->height() / 2.0;
        noc->addShape(i, halfW, halfH);
    }

    ctx.ccs.push_back(noc);
}

static void apply_grid_constraints(Context &ctx, const json &c) {
    if (c.contains("grid"))
        ctx.grid = c["grid"];

    std::string grid_mode = c.value("grid_mode", "none");

    if (grid_mode == "min_spacing") {
        for (size_t i = 0; i < ctx.rects.size(); i++) {
            for (size_t j = i + 1; j < ctx.rects.size(); j++) {
                ctx.ccs.push_back(new cola::SeparationConstraint(
                    vpsc::HORIZONTAL, i, j, ctx.grid, false));
                ctx.ccs.push_back(new cola::SeparationConstraint(
                    vpsc::VERTICAL, i, j, ctx.grid, false));
            }
        }
    }

    if (grid_mode == "attract" || grid_mode == "attract_x" || grid_mode == "attract_y") {
        ctx.use_desired = true;
        for (size_t i = 0; i < ctx.rects.size(); i++) {
            double cx = ctx.rects[i]->getCentreX();
            double cy = ctx.rects[i]->getCentreY();
            double tx = (grid_mode == "attract_y") ? cx : snap(cx, ctx.grid);
            double ty = (grid_mode == "attract_x") ? cy : snap(cy, ctx.grid);
            ctx.desired.push_back({(unsigned)i, tx, ty, 0.1});
        }
    }
}

static void apply_rank_constraints(Context &ctx, const json &c) {
    if (c.value("rank_vertical", false)) {
        double g = c.value("rank_vertical_spacing", ctx.grid);
        for (size_t i = 0; i + 1 < ctx.rects.size(); i++) {
            ctx.ccs.push_back(new cola::SeparationConstraint(
                vpsc::VERTICAL, i, i + 1, g, false));
        }
    }

    if (c.value("rank_horizontal", false)) {
        double g = c.value("rank_horizontal_spacing", ctx.grid);
        for (size_t i = 0; i + 1 < ctx.rects.size(); i++) {
            ctx.ccs.push_back(new cola::SeparationConstraint(
                vpsc::HORIZONTAL, i, i + 1, g, false));
        }
    }
}

static void apply_alignment_constraints(Context &ctx, const json &c) {
    if (c.value("align_left", false)) {
        auto *align = new cola::AlignmentConstraint(vpsc::HORIZONTAL, 0.0);
        for (size_t i = 0; i < ctx.rects.size(); i++)
            align->addShape(i, -ctx.rects[i]->width() / 2.0);
        ctx.ccs.push_back(align);
    }

    if (c.value("align_right", false)) {
        auto *align = new cola::AlignmentConstraint(vpsc::HORIZONTAL, 0.0);
        for (size_t i = 0; i < ctx.rects.size(); i++)
            align->addShape(i, ctx.rects[i]->width() / 2.0);
        ctx.ccs.push_back(align);
    }

    if (c.value("align_center_x", false)) {
        auto *align = new cola::AlignmentConstraint(vpsc::HORIZONTAL, 0.0);
        for (size_t i = 0; i < ctx.rects.size(); i++)
            align->addShape(i, 0.0);
        ctx.ccs.push_back(align);
    }

    if (c.value("align_top", false)) {
        auto *align = new cola::AlignmentConstraint(vpsc::VERTICAL, 0.0);
        for (size_t i = 0; i < ctx.rects.size(); i++)
            align->addShape(i, ctx.rects[i]->height() / 2.0);
        ctx.ccs.push_back(align);
    }

    if (c.value("align_bottom", false)) {
        auto *align = new cola::AlignmentConstraint(vpsc::VERTICAL, 0.0);
        for (size_t i = 0; i < ctx.rects.size(); i++)
            align->addShape(i, -ctx.rects[i]->height() / 2.0);
        ctx.ccs.push_back(align);
    }

    if (c.value("align_center_y", false)) {
        auto *align = new cola::AlignmentConstraint(vpsc::VERTICAL, 0.0);
        for (size_t i = 0; i < ctx.rects.size(); i++)
            align->addShape(i, 0.0);
        ctx.ccs.push_back(align);
    }
}

static void apply_spacing_constraints(Context &ctx, const json &c) {
    if (c.value("equal_horizontal_spacing", false)) {
        double g = c.value("equal_horizontal_spacing_value", ctx.grid);
        for (size_t i = 0; i + 1 < ctx.rects.size(); i++) {
            ctx.ccs.push_back(new cola::SeparationConstraint(
                vpsc::HORIZONTAL, i, i + 1, g, false));
        }
    }

    if (c.value("equal_vertical_spacing", false)) {
        double g = c.value("equal_vertical_spacing_value", ctx.grid);
        for (size_t i = 0; i + 1 < ctx.rects.size(); i++) {
            ctx.ccs.push_back(new cola::SeparationConstraint(
                vpsc::VERTICAL, i, i + 1, g, false));
        }
    }

    if (c.value("distribute_horizontally", false)) {
        double g = c.value("distribute_horizontal_spacing", ctx.grid);
        for (size_t i = 0; i + 1 < ctx.rects.size(); i++) {
            ctx.ccs.push_back(new cola::SeparationConstraint(
                vpsc::HORIZONTAL, i, i + 1, g, false));
        }
    }

    if (c.value("distribute_vertically", false)) {
        double g = c.value("distribute_vertical_spacing", ctx.grid);
        for (size_t i = 0; i + 1 < ctx.rects.size(); i++) {
            ctx.ccs.push_back(new cola::SeparationConstraint(
                vpsc::VERTICAL, i, i + 1, g, false));
        }
    }
}

static void apply_page_constraints(Context &ctx, const json &c) {
    if (!c.value("page_bounds", false))
        return;

    double left   = c.value("page_left",   -500.0);
    double right  = c.value("page_right",   500.0);
    double top    = c.value("page_top",     500.0);
    double bottom = c.value("page_bottom", -500.0);
    double margin = c.value("page_margin",   10.0);

    left   += margin;
    right  -= margin;
    top    -= margin;
    bottom += margin;

    ctx.input["__page_bounds_internal"] = {
        {"left", left}, {"right", right}, {"top", top}, {"bottom", bottom}
    };
}

static void apply_cluster_constraints(Context &ctx, const json &c) {
    if (!c.contains("clusters"))
        return;

    if (c.value("fixed_relative", false)) {
        for (auto &cl : c["clusters"]) {
            std::vector<unsigned> ids;
            for (auto &nid : cl["nodes"]) {
                ids.push_back(ctx.idx[nid]);
            }
            for (size_t i = 0; i + 1 < ids.size(); i++) {
                ctx.ccs.push_back(new cola::SeparationConstraint(
                    vpsc::HORIZONTAL, ids[i], ids[i + 1], 10.0, false));
                ctx.ccs.push_back(new cola::SeparationConstraint(
                    vpsc::VERTICAL, ids[i], ids[i + 1], 10.0, false));
            }
        }
    }
}

static void apply_boundary_constraints(Context &ctx, const json &c) {
    if (c.value("boundary_constraint", false)) {
        ctx.input["__boundary_constraint_internal"] = true;
    }

    if (c.value("multi_separation", false)) {
        double g = c.value("multi_separation_value", ctx.grid);
        for (size_t i = 0; i < ctx.rects.size(); i++) {
            for (size_t j = i + 1; j < ctx.rects.size(); j++) {
                ctx.ccs.push_back(new cola::SeparationConstraint(
                    vpsc::HORIZONTAL, i, j, g, false));
            }
        }
    }

    if (c.value("distribution", false)) {
        double g = c.value("distribution_spacing", ctx.grid);
        for (size_t i = 0; i + 1 < ctx.rects.size(); i++) {
            ctx.ccs.push_back(new cola::SeparationConstraint(
                vpsc::HORIZONTAL, i, i + 1, g, false));
            ctx.ccs.push_back(new cola::SeparationConstraint(
                vpsc::VERTICAL, i, i + 1, g, false));
        }
    }
}

static void apply_postprocessing(Context &ctx, const json &c) {
    std::string grid_mode = c.value("grid_mode", "none");

    bool snap_after      = (grid_mode == "snap" || c.value("snap_after_layout", false));
    bool snap_x_after    = (grid_mode == "snap_x" || c.value("snap_x_after", false));
    bool snap_y_after    = (grid_mode == "snap_y" || c.value("snap_y_after", false));

    for (auto *r : ctx.rects) {
        double cx = r->getCentreX();
        double cy = r->getCentreY();

        if (snap_after || snap_x_after)
            cx = snap(cx, ctx.grid);
        if (snap_after || snap_y_after)
            cy = snap(cy, ctx.grid);

        r->moveCentre(cx, cy);
    }

    if (ctx.input.contains("__page_bounds_internal")) {
        auto b = ctx.input["__page_bounds_internal"];
        double left   = b["left"];
        double right  = b["right"];
        double top    = b["top"];
        double bottom = b["bottom"];

        for (auto *r : ctx.rects) {
            double cx = r->getCentreX();
            double cy = r->getCentreY();
            double hw = r->width() / 2.0;
            double hh = r->height() / 2.0;

            if (cx - hw < left)   cx = left + hw;
            if (cx + hw > right)  cx = right - hw;
            if (cy - hh < bottom) cy = bottom + hh;
            if (cy + hh > top)    cy = top - hh;

            r->moveCentre(cx, cy);
        }
    }

    if (ctx.input.value("__boundary_constraint_internal", false)) {
        for (auto *r : ctx.rects) {
            double cx = r->getCentreX();
            double cy = r->getCentreY();
            double hw = r->width() / 2.0;
            double hh = r->height() / 2.0;

            if (cx - hw < 0) cx = hw;
            if (cy - hh < 0) cy = hh;

            r->moveCentre(cx, cy);
        }
    }

    if (c.value("clamp_to_region", false)) {
        double left   = c.value("clamp_left",   -std::numeric_limits<double>::infinity());
        double right  = c.value("clamp_right",   std::numeric_limits<double>::infinity());
        double top    = c.value("clamp_top",     std::numeric_limits<double>::infinity());
        double bottom = c.value("clamp_bottom", -std::numeric_limits<double>::infinity());

        for (auto *r : ctx.rects) {
            double cx = r->getCentreX();
            double cy = r->getCentreY();
            double hw = r->width() / 2.0;
            double hh = r->height() / 2.0;

            if (cx - hw < left)   cx = left + hw;
            if (cx + hw > right)  cx = right - hw;
            if (cy - hh < bottom) cy = bottom + hh;
            if (cy + hh > top)    cy = top - hh;

            r->moveCentre(cx, cy);
        }
    }
}

static void apply_routing_with_libavoid(Context &ctx, const json &c, json &out) {
    std::string routing = c.value("routing", "none");
    if (routing == "none") {
        out["edges"] = json::array();
        for (auto &e : ctx.input["edges"]) {
            json je;
            je["source"] = e["source"];
            je["target"] = e["target"];
            out["edges"].push_back(je);
        }
        return;
    }

    RouterFlag flags = RouterFlag_None;
    if (routing == "orthogonal" || routing == "multi_edge") {
        flags = RouterFlag_OrthogonalRouting;
    } else {
        flags = RouterFlag_PolyLineRouting;
    }

    Router router(flags);

    std::vector<ShapeRef *> shapes(ctx.rects.size(), nullptr);
    for (auto &pair : ctx.idx) {
        const std::string &id = pair.first;
        unsigned i = pair.second;
        vpsc::Rectangle *r = ctx.rects[i];

        double l = r->getMinX();
        double b = r->getMinY();
        double rt = r->getMaxX();
        double t = r->getMaxY();

        Polygon poly;
        poly.addPoint(Point(l, b));
        poly.addPoint(Point(rt, b));
        poly.addPoint(Point(rt, t));
        poly.addPoint(Point(l, t));

        ShapeRef *shape = new ShapeRef(&router, poly);
        shapes[i] = shape;
    }

    std::vector<ConnRef *> conns;
    for (auto &e : ctx.input["edges"]) {
        std::string sid = e["source"];
        std::string tid = e["target"];
        unsigned si = ctx.idx[sid];
        unsigned ti = ctx.idx[tid];

        ConnRef *conn = new ConnRef(&router, shapes[si], shapes[ti]);
        if (routing == "orthogonal" || routing == "obstacle" || routing == "multi_edge") {
            conn->setRoutingType(ConnType_Orthogonal);
        } else {
            conn->setRoutingType(ConnType_PolyLine);
        }
        conns.push_back(conn);
    }

    router.processTransaction();

    out["edges"] = json::array();
    for (size_t k = 0; k < ctx.input["edges"].size(); ++k) {
        auto &e = ctx.input["edges"][k];
        ConnRef *conn = conns[k];

        json je;
        je["source"] = e["source"];
        je["target"] = e["target"];
        je["route"] = json::array();

        const PolyLine &pl = conn->displayRoute();
        for (size_t i = 0; i < pl.size(); ++i) {
            const Point &p = pl.at(i);
            je["route"].push_back(json::array({p.x, p.y}));
        }

        out["edges"].push_back(je);
    }
}

static bool read_request(std::istream &in,
                         std::string &buffer,
                         const std::string &input_separator) {
    buffer.clear();
    std::string line;
    bool got_any = false;

    while (std::getline(in, line)) {
        if (!input_separator.empty()) {
            if (line == input_separator) {
                if (got_any) return true;
                else continue;
            }
        } else {
            if (line.empty()) {
                if (got_any) return true;
                else continue;
            }
        }
        buffer += line;
        buffer += "\n";
        got_any = true;
    }

    return got_any;
}

int main(int argc, char **argv) {
    std::string input_separator;
    std::string output_separator;

    for (int i = 1; i < argc; ++i) {
        std::string arg = argv[i];
        if (arg.rfind("--input-separator=", 0) == 0) {
            input_separator = arg.substr(std::string("--input-separator=").size());
        } else if (arg.rfind("--separator=", 0) == 0) {
            output_separator = arg.substr(std::string("--separator=").size());
        }
    }

    std::string buf;
    while (read_request(std::cin, buf, input_separator)) {
        json input;
        try {
            input = json::parse(buf);
        } catch (...) {
            continue;
        }

        if (input.contains("command") && input["command"] == "exit") {
            break;
        }

        Context ctx;
        ctx.input = input;

        const json &c = ctx.input.contains("constraints")
            ? ctx.input["constraints"]
            : json::object();

        bool do_layout = c.value("layout", true);

        build_nodes_and_edges(ctx);
        if (do_layout) {
            apply_grid_constraints(ctx, c);
            apply_rank_constraints(ctx, c);
            apply_alignment_constraints(ctx, c);
            apply_spacing_constraints(ctx, c);
            apply_page_constraints(ctx, c);
            apply_cluster_constraints(ctx, c);
            apply_boundary_constraints(ctx, c);

            cola::ConstrainedFDLayout layout(
                ctx.rects,
                ctx.edges,
                50.0
            );

            layout.setConstraints(ctx.ccs);

            if (ctx.use_desired)
                layout.setDesiredPositions(&ctx.desired);

            layout.run();

            apply_postprocessing(ctx, c);
        }

        json out;
        if (ctx.input.contains("id"))
            out["id"] = ctx.input["id"];

        out["nodes"] = json::array();
        for (auto &n : ctx.input["nodes"]) {
            unsigned i = ctx.idx[n["id"]];
            vpsc::Rectangle *r = ctx.rects[i];

            json j;
            j["id"] = n["id"];
            j["x"] = r->getCentreX();
            j["y"] = r->getCentreY();
            j["width"] = n.value("width", 60.0);
            j["height"] = n.value("height", 40.0);

            out["nodes"].push_back(j);
        }

        apply_routing_with_libavoid(ctx, c, out);

        std::cout << out.dump(2) << std::endl;
        if (!output_separator.empty()) {
            std::cout << output_separator << std::endl;
        }
        std::cout.flush();
    }

    return 0;
}
