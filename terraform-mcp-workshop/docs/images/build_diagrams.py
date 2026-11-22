"""Generate the five session-slide diagrams as static, self-contained SVGs."""
import os

OUT = os.path.dirname(os.path.abspath(__file__))


FONT = "system-ui, -apple-system, 'Segoe UI', Helvetica, Arial, sans-serif"
STY = {
    "blue": ("#DBEAFE", "#1D4ED8"),
    "gray": ("#F1F5F9", "#64748B"),
    "amber": ("#FEF3C7", "#B45309"),
    "ext": ("#FFFFFF", "#64748B"),
}
MARK = {"s": "arr", "a": "arrA", "g": "arrG"}
COL = {"s": "#334155", "a": "#B45309", "g": "#15803D"}


def esc(t):
    return t.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


class Svg:
    def __init__(self, W, H, title, desc):
        self.W, self.H, self.title, self.desc = W, H, title, desc
        self.b = []

    def box(self, x, y, w, h, lines, kind="blue", dashed=False):
        fill, stroke = STY[kind]
        d = ' stroke-dasharray="6 5"' if dashed else ""
        self.b.append(
            f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="8" fill="{fill}" stroke="{stroke}" stroke-width="2"{d}/>'
        )
        lh = 20
        y0 = y + h / 2 - (len(lines) - 1) * lh / 2 + 5
        for i, t in enumerate(lines):
            if i == 0:
                self.b.append(
                    f'<text x="{x + w / 2}" y="{y0 + i * lh}" font-size="17" font-weight="700" fill="#0F172A" text-anchor="middle">{esc(t)}</text>'
                )
            else:
                self.b.append(
                    f'<text x="{x + w / 2}" y="{y0 + i * lh}" font-size="14" fill="#334155" text-anchor="middle">{esc(t)}</text>'
                )

    def arrow(self, pts, c="s", both=False, dash=False):
        d = "M" + " L".join(f"{x} {y}" for x, y in pts)
        m = f' marker-end="url(#{MARK[c]})"'
        if both:
            m += f' marker-start="url(#{MARK[c]})"'
        da = ' stroke-dasharray="7 5"' if dash else ""
        self.b.append(
            f'<path d="{d}" fill="none" stroke="{COL[c]}" stroke-width="2"{da}{m} stroke-linejoin="round"/>'
        )

    def label(self, x, y, t, size=14, bg=True, anchor="middle", color="#334155", bold=False):
        """Text label; y is the text baseline. Optional opaque pad so lines never strike through it."""
        w = len(t) * size * 0.56 + 10
        if bg:
            rx = x - w / 2 if anchor == "middle" else x - 5
            self.b.append(
                f'<rect x="{rx:.1f}" y="{y - size:.1f}" width="{w:.1f}" height="{size + 7}" fill="#F8FAFC"/>'
            )
        fw = ' font-weight="700"' if bold else ""
        self.b.append(
            f'<text x="{x}" y="{y}" font-size="{size}" fill="{color}" text-anchor="{anchor}"{fw}>{esc(t)}</text>'
        )

    def raw(self, s):
        self.b.append(s)

    def legend(self, items, y, x=24):
        for kind, t in items:
            fill, stroke = STY[kind]
            self.b.append(
                f'<rect x="{x}" y="{y - 13}" width="18" height="18" rx="4" fill="{fill}" stroke="{stroke}" stroke-width="2"/>'
            )
            self.b.append(f'<text x="{x + 26}" y="{y + 1}" font-size="14" fill="#334155">{esc(t)}</text>')
            x += 26 + len(t) * 8 + 30

    def save(self, name):
        defs = "".join(
            f'<marker id="{i}" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="8" markerHeight="8" orient="auto-start-reverse"><path d="M0 0 L10 5 L0 10 z" fill="{c}"/></marker>'
            for i, c in (("arr", "#334155"), ("arrA", "#B45309"), ("arrG", "#15803D"))
        )
        s = (
            f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {self.W} {self.H}" width="{self.W}" height="{self.H}" '
            f'role="img" aria-label="{esc(self.desc)}" font-family="{FONT}">\n'
            f"<title>{esc(self.title)}</title>\n<defs>{defs}</defs>\n"
            f'<rect x="1" y="1" width="{self.W - 2}" height="{self.H - 2}" rx="14" fill="#F8FAFC" stroke="#CBD5E1" stroke-width="2"/>\n'
            + "\n".join(self.b)
            + "\n</svg>\n"
        )
        open(os.path.join(OUT, name), "w").write(s)


LEG = [("amber", "Engineer"), ("blue", "AI tool or MCP"), ("gray", "Terraform CLI or registry")]

# ---------------------------------------------------------------- 1. manual
s = Svg(1280, 240, "Manual IaC development",
        "Manual IaC development: the engineer reads provider docs, writes HCL by hand and runs terraform validate. "
        "An error sends the engineer back to the docs. When validate passes, terraform plan runs, the engineer reviews the plan, then terraform apply.")
w, h, g, y = 150, 84, 26, 56
x0 = (1280 - (7 * w + 6 * g)) / 2
xs = [x0 + i * (w + g) for i in range(7)]
spec = [(["Engineer"], "amber"), (["Read provider", "docs"], "amber"), (["Write HCL", "by hand"], "amber"),
        (["terraform", "validate"], "gray"), (["terraform", "plan"], "gray"),
        (["Engineer", "reviews plan"], "amber"), (["terraform", "apply"], "gray")]
for x, (l, k) in zip(xs, spec):
    s.box(x, y, w, h, l, k)
for i in range(6):
    s.arrow([(xs[i] + w + 1, y + h / 2), (xs[i + 1] - 1, y + h / 2)])
s.label(xs[3] + w + g / 2, y + h / 2 - 8, "ok", 13)
s.arrow([(xs[3] + w / 2, y + h + 1), (xs[3] + w / 2, y + h + 38), (xs[1] + w / 2, y + h + 38), (xs[1] + w / 2, y + h + 1)], "a")
s.label((xs[1] + xs[3] + w) / 2, y + h + 43, "error", 14, color="#B45309", bold=True)
s.legend(LEG, 214)
s.save("manual-iac.svg")

# ---------------------------------------------------------------- 2. AI-driven
s = Svg(1310, 470, "AI-driven IaC development with MCP",
        "AI-driven IaC development: the engineer asks the AI coding tool in plain language. The tool calls the Terraform MCP server, "
        "which fetches current docs and versions from the Terraform Registry and returns the result. The AI drafts HCL from the retrieved docs "
        "and runs terraform validate. An error goes back to the AI. When validate passes, terraform plan runs, the engineer reviews the plan "
        "and approves terraform apply.")
w, h = 200, 84
r1 = [(40, ["Engineer"], "amber"), (370, ["AI coding tool"], "blue"),
      (700, ["Terraform MCP", "server"], "blue"), (1030, ["Terraform", "Registry"], "gray")]
y1 = 46
for x, l, k in r1:
    s.box(x, y1, w, h, l, k)
# engineer -> AI
s.arrow([(241, y1 + 56), (369, y1 + 56)])
s.label(305, y1 + 24, "asks in plain", 13, bg=False)
s.label(305, y1 + 39, "language", 13, bg=False)
# AI <-> MCP, MCP <-> registry
for xa in (570, 900):
    s.arrow([(xa + 1, y1 + 30), (xa + 129, y1 + 30)])
    s.arrow([(xa + 129, y1 + 58), (xa + 1, y1 + 58)])
s.label(635, y1 + 22, "tool call", 13, bg=False)
s.label(635, y1 + 78, "result", 13, bg=False)
s.label(965, y1 + 22, "fetches", 13, bg=False)
s.label(965, y1 + 78, "current docs,", 13, bg=False)
s.label(965, y1 + 93, "versions", 13, bg=False)
# row 2
y2 = 290
r2 = [(370, ["Drafts HCL", "from retrieved", "docs"], "blue"), (560, ["terraform", "validate"], "gray"),
      (750, ["terraform", "plan"], "gray"), (940, ["Engineer", "reviews plan"], "amber"),
      (1130, ["terraform apply", "(engineer approves)"], "amber")]
w2 = 150
for x, l, k in r2:
    s.box(x, y2, 150 if x != 1130 else 170, h, l, k)
s.arrow([(420, y1 + h + 1), (420, y2 - 1)])
for xa, xb in ((520, 560), (710, 750), (900, 940), (1090, 1130)):
    s.arrow([(xa + 1, y2 + h / 2), (xb - 1, y2 + h / 2)])
s.label(730, y2 + h / 2 - 8, "ok", 13)
s.arrow([(640, y2 - 1), (640, 212), (530, 212), (530, y1 + h + 1)], "a")
s.label(585, 207, "error", 14, color="#B45309", bold=True)
s.raw(f'<text x="40" y="318" font-size="16" font-weight="700" fill="#0F172A">The lookup moved.</text>')
s.raw(f'<text x="40" y="341" font-size="14" fill="#334155">Review and approval did not.</text>')
s.legend(LEG, 444)
s.save("ai-driven-iac.svg")

# ---------------------------------------------------------------- 3. who does each step
s = Svg(1290, 330, "Who does each step",
        "Side by side comparison of five steps. Manual: the engineer finds docs, writes HCL, fixes errors, reviews the plan and approves apply. "
        "AI-driven with MCP: the AI finds docs through MCP and writes HCL, the AI fixes errors with the engineer checking, "
        "and the engineer still reviews the plan and approves apply.")
w, h, g, x0 = 196, 92, 28, 170
steps = ["Find docs", "Write HCL", "Fix errors", "Review plan", "Approve apply"]
man = ["engineer"] * 5
ai = [("AI via MCP", "blue"), ("AI", "blue"), ("AI, engineer checks", "blue"), ("engineer", "amber"), ("engineer", "amber")]
for lane, (ly, label) in enumerate([(40, ["MANUAL"]), (176, ["AI-DRIVEN", "WITH MCP"])]):
    for j, t in enumerate(label):
        s.raw(f'<text x="24" y="{ly + h / 2 + 5 + (j - (len(label) - 1) / 2) * 18}" font-size="15" font-weight="700" fill="#334155">{t}</text>')
    for i in range(5):
        x = x0 + i * (w + g)
        who, k = ("engineer", "amber") if lane == 0 else ai[i]
        s.box(x, ly, w, h, [steps[i], who], k)
        if i < 4:
            s.arrow([(x + w + 1, ly + h / 2), (x + w + g - 1, ly + h / 2)])
s.raw('<line x1="20" y1="154" x2="1270" y2="154" stroke="#94A3B8" stroke-width="1.5" stroke-dasharray="6 6"/>')
s.legend([("amber", "Engineer"), ("blue", "AI")], 300)
s.save("who-does-each-step.svg")

# ---------------------------------------------------------------- 4. architecture
s = Svg(1290, 436, "Architecture: where the Terraform MCP server sits",
        "Inside your machine: the engineer talks to an AI coding tool, which is the MCP host and client. It speaks MCP, JSON-RPC over stdio, "
        "to the Terraform MCP server running as a Docker container, and runs the Terraform CLI through a terminal tool. The Terraform CLI drives "
        "the Docker engine. Outside the machine: the MCP server reaches registry.terraform.io over HTTPS, and the AI tool calls an AI model service over its model API.")
s.raw('<rect x="20" y="40" width="1000" height="372" rx="12" fill="#FFFFFF" stroke="#94A3B8" stroke-width="2" stroke-dasharray="8 6"/>')
s.label(44, 70, "YOUR MACHINE", 15, bg=False, anchor="start", color="#334155", bold=True)
s.box(50, 190, 150, 80, ["Engineer"], "amber")
s.box(280, 170, 230, 120, ["AI coding tool", "(MCP host and client)"], "blue")
s.box(640, 70, 280, 90, ["Terraform MCP server", "(Docker container, stdio)"], "blue")
s.box(640, 290, 150, 80, ["Terraform CLI"], "gray")
s.box(850, 290, 150, 80, ["Docker engine"], "gray")
s.box(1070, 70, 200, 90, ["Terraform Registry", "registry.terraform.io"], "ext")
s.box(1070, 290, 200, 80, ["AI model service"], "ext", dashed=True)
s.arrow([(201, 230), (279, 230)], both=True)
s.arrow([(511, 205), (575, 205), (575, 115), (639, 115)], both=True)
s.label(565, 100, "MCP: JSON-RPC over stdio", 14, bg=False, anchor="end")
s.arrow([(511, 258), (575, 258), (575, 330), (639, 330)])
s.label(565, 330, "runs via terminal tool", 14, bg=False, anchor="end")
s.arrow([(791, 330), (849, 330)])
s.arrow([(921, 115), (1069, 115)], both=True)
s.label(965, 104, "HTTPS", 14, bg=False)
s.arrow([(395, 291), (395, 392), (1170, 392), (1170, 371)], both=True)
s.label(780, 386, "model API", 14, color="#334155")
s.save("mcp-architecture.svg")

# ---------------------------------------------------------------- 5. multi-agent shape
s = Svg(1350, 520, "Several agents building modules, with human gates",
        "A human approves an interface contract with inputs, outputs and tests. The orchestrator agent fans out to one agent per module, each in its own "
        "worktree. Their reports, boundary check and independent re-run are collected. Any red result goes back to the orchestrator. When all are green, the "
        "integration agent composes the root module and makes a plan only. A failure goes back to the owning module. Otherwise the plan reaches a human gate "
        "for plan, cost and target. The human approves the saved plan and a human runs apply.")
h = 76
s.box(20, 20, 200, h, ["Human", "owns contract, approvals"], "amber")
s.box(290, 20, 200, h, ["Interface contract", "inputs, outputs, tests"], "gray")
s.arrow([(221, 58), (289, 58)], "a")
s.label(255, 44, "approves", 13, bg=False)
s.box(290, 215, 200, h, ["Orchestrator agent"], "blue")
s.arrow([(390, 97), (390, 214)])
ay = [105, 220, 335]
for n, y in zip("ABC", ay):
    s.box(580, y, 190, 66, [f"Agent: module {n}", "own worktree"], "blue")
    s.arrow([(540, y + 33), (579, y + 33)])
s.raw('<path d="M491 253 L540 253 M540 138 L540 368" fill="none" stroke="#334155" stroke-width="2"/>')
s.box(840, 215, 190, h, ["Reports", "boundary check, re-run"], "blue")
s.raw('<path d="M771 138 L805 138 L805 368 M771 368 L805 368 M771 253 L805 253" fill="none" stroke="#334155" stroke-width="2"/>')
s.arrow([(805, 253), (839, 253)])
s.box(1120, 215, 190, h, ["Integration agent", "root composition, plan only"], "blue")
s.arrow([(1031, 253), (1119, 253)], "g")
s.label(1075, 240, "all green", 13, color="#15803D", bold=True)
s.box(1120, 20, 190, h, ["Human gate", "plan, cost, target"], "amber")
s.arrow([(1215, 214), (1215, 97)])
s.box(840, 20, 190, h, ["Human runs apply", "the saved plan"], "amber")
s.arrow([(1119, 58), (1031, 58)], "a")
s.label(1075, 44, "approves", 13, bg=False)
# feedback lanes
s.arrow([(935, 292), (935, 440), (360, 440), (360, 292)], "a")
s.label(650, 434, "any red: back to the orchestrator", 14, color="#B45309", bold=True)
s.arrow([(1215, 292), (1215, 478), (420, 478), (420, 292)], "a")
s.label(800, 472, "failure goes back to the owning module", 14, color="#B45309", bold=True)
s.legend([("amber", "Human"), ("blue", "Agent"), ("gray", "Approved contract")], 500, x=24)
s.save("multi-agent-shape.svg")
print("ok")
