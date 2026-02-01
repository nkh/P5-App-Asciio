#include <iostream>
#include <vector>
#include <map>

#include <nlohmann/json.hpp>

#include <cola.h>
#include <box.h>
#include <constraints.h>
#include <constrainedfdlayout.h>
#include <separation.h>

using json = nlohmann::json;

int main() {
    json input;
    std::cin >> input;

    // --- Build node boxes ---
    std::vector<cola::Box> boxes;
    std::map<std::string, int> idx;

    for (size_t i = 0; i < input["nodes"].size(); i++) {
        auto &n = input["nodes"][i];
        double w = n.value("width", 60.0);
        double h = n.value("height", 40.0);

        boxes.emplace_back(0.0, 0.0, w, h);
        idx[n["id"]] = static_cast<int>(i);
    }

    // --- Build edges ---
    std::vector<cola::Edge> edges;
    for (auto &e : input["edges"]) {
        edges.emplace_back(idx[e["source"]], idx[e["target"]]);
    }

    // --- Constraints ---
    cola::CompoundConstraints cc;

    // Non-overlap
    auto *noc = new cola::NonOverlapConstraints(boxes);
    cc.add(noc);

    // Optional grid constraint
    if (input.contains("constraints") && input["constraints"].contains("grid")) {
        double grid = input["constraints"]["grid"];
        for (size_t i = 0; i < boxes.size(); i++) {
            cc.add(new cola::SeparationConstraint(i, i, grid));
        }
    }

    // --- Run layout ---
    cola::ConstrainedFDLayout layout(boxes, edges, cc);
    layout.run();

    // --- Output ---
    json out;
    out["nodes"] = json::array();

    for (auto &n : input["nodes"]) {
        int i = idx[n["id"]];
        cola::Box &b = boxes[i];

        json j;
        j["id"] = n["id"];
        j["x"] = b.left;
        j["y"] = b.top;
        j["width"] = n["width"];
        j["height"] = n["height"];

        out["nodes"].push_back(j);
    }

    std::cout << out.dump(2) << std::endl;
    return 0;
}
