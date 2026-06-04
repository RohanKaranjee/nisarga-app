from __future__ import annotations

import html
import io
import math
import re
import textwrap
import zipfile
from dataclasses import dataclass
from datetime import datetime, timedelta
from pathlib import Path
from typing import Iterable

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
README = ROOT / "README.md"
OUTPUT = ROOT / "Nisarga_Project_Report.docx"


def xml_text(value: object) -> str:
    text = "" if value is None else str(value)
    text = "".join(
        ch
        for ch in text
        if ch in "\t\n\r" or ord(ch) >= 32
    )
    return html.escape(text, quote=False)


def clean_inline(text: str) -> str:
    text = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", text)
    text = text.replace("**", "")
    text = text.replace("`", "")
    return text.strip()


def wrap_label(text: str, width: int = 18) -> str:
    text = clean_inline(text)
    if len(text) <= width:
        return text
    return "\n".join(textwrap.wrap(text, width=width, break_long_words=False))


@dataclass
class ImagePart:
    rel_id: str
    name: str
    data: bytes
    width_px: int
    height_px: int


class DocxBuilder:
    def __init__(self) -> None:
        self.body: list[str] = []
        self.images: list[ImagePart] = []
        self._image_index = 1

    def add_paragraph(
        self,
        text: str = "",
        style: str | None = None,
        bold: bool = False,
        italic: bool = False,
        align: str | None = None,
        indent_twips: int = 0,
    ) -> None:
        text = clean_inline(text)
        ppr: list[str] = []
        if style:
            ppr.append(f'<w:pStyle w:val="{style}"/>')
        if align:
            ppr.append(f'<w:jc w:val="{align}"/>')
        if indent_twips:
            ppr.append(f'<w:ind w:left="{indent_twips}"/>')
        rpr: list[str] = []
        if bold:
            rpr.append("<w:b/>")
        if italic:
            rpr.append("<w:i/>")
        text_attr = ' xml:space="preserve"' if text.startswith(" ") or text.endswith(" ") else ""
        self.body.append(
            "<w:p>"
            + (f"<w:pPr>{''.join(ppr)}</w:pPr>" if ppr else "")
            + "<w:r>"
            + (f"<w:rPr>{''.join(rpr)}</w:rPr>" if rpr else "")
            + f"<w:t{text_attr}>{xml_text(text)}</w:t>"
            + "</w:r></w:p>"
        )

    def add_heading(self, text: str, level: int) -> None:
        if level <= 1 and not self.body:
            self.add_paragraph(text, style="Title", align="center")
            self.add_paragraph(
                f"Generated from README.md on {datetime.now().strftime('%d %B %Y')}",
                style="Caption",
                align="center",
            )
            self.add_paragraph()
            return
        style = f"Heading{min(max(level, 1), 4)}"
        self.add_paragraph(text, style=style)

    def add_code_block(self, lines: Iterable[str]) -> None:
        for line in lines:
            self.add_paragraph(line.rstrip("\n"), style="Code")
        self.add_paragraph()

    def add_table(self, rows: list[list[str]]) -> None:
        if not rows:
            return
        grid_cols = max(len(row) for row in rows)
        tbl = [
            "<w:tbl>",
            "<w:tblPr>",
            '<w:tblStyle w:val="TableGrid"/>',
            '<w:tblW w:w="0" w:type="auto"/>',
            "<w:tblBorders>"
            '<w:top w:val="single" w:sz="6" w:space="0" w:color="B8B8B8"/>'
            '<w:left w:val="single" w:sz="6" w:space="0" w:color="B8B8B8"/>'
            '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="B8B8B8"/>'
            '<w:right w:val="single" w:sz="6" w:space="0" w:color="B8B8B8"/>'
            '<w:insideH w:val="single" w:sz="6" w:space="0" w:color="B8B8B8"/>'
            '<w:insideV w:val="single" w:sz="6" w:space="0" w:color="B8B8B8"/>'
            "</w:tblBorders>",
            "</w:tblPr>",
            "<w:tblGrid>",
        ]
        for _ in range(grid_cols):
            tbl.append('<w:gridCol w:w="2400"/>')
        tbl.append("</w:tblGrid>")
        for row_index, row in enumerate(rows):
            tbl.append("<w:tr>")
            for cell in row + [""] * (grid_cols - len(row)):
                shading = '<w:shd w:fill="FCE8EF"/>' if row_index == 0 else ""
                tbl.append(
                    "<w:tc>"
                    f"<w:tcPr>{shading}</w:tcPr>"
                    "<w:p><w:r>"
                    + ("<w:rPr><w:b/></w:rPr>" if row_index == 0 else "")
                    + f"<w:t>{xml_text(clean_inline(cell))}</w:t>"
                    + "</w:r></w:p></w:tc>"
                )
            tbl.append("</w:tr>")
        tbl.append("</w:tbl>")
        self.body.append("".join(tbl))
        self.add_paragraph()

    def add_image(self, png_data: bytes, caption: str | None = None) -> None:
        with Image.open(io.BytesIO(png_data)) as image:
            width_px, height_px = image.size
        rel_id = f"rId{len(self.images) + 2}"
        name = f"image{self._image_index}.png"
        self._image_index += 1
        self.images.append(ImagePart(rel_id, name, png_data, width_px, height_px))

        max_width_in = 6.3
        image_width_in = min(max_width_in, width_px / 150)
        image_height_in = image_width_in * height_px / max(width_px, 1)
        cx = int(image_width_in * 914400)
        cy = int(image_height_in * 914400)
        doc_pr_id = len(self.images)
        self.body.append(
            '<w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:drawing>'
            '<wp:inline distT="0" distB="0" distL="0" distR="0">'
            f'<wp:extent cx="{cx}" cy="{cy}"/>'
            f'<wp:docPr id="{doc_pr_id}" name="{xml_text(name)}"/>'
            '<wp:cNvGraphicFramePr><a:graphicFrameLocks noChangeAspect="1"/></wp:cNvGraphicFramePr>'
            '<a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">'
            '<pic:pic>'
            '<pic:nvPicPr>'
            f'<pic:cNvPr id="{doc_pr_id}" name="{xml_text(name)}"/>'
            '<pic:cNvPicPr/>'
            '</pic:nvPicPr>'
            '<pic:blipFill>'
            f'<a:blip r:embed="{rel_id}"/>'
            '<a:stretch><a:fillRect/></a:stretch>'
            '</pic:blipFill>'
            '<pic:spPr>'
            '<a:xfrm><a:off x="0" y="0"/>'
            f'<a:ext cx="{cx}" cy="{cy}"/></a:xfrm>'
            '<a:prstGeom prst="rect"><a:avLst/></a:prstGeom>'
            '</pic:spPr>'
            '</pic:pic>'
            '</a:graphicData></a:graphic>'
            '</wp:inline></w:drawing></w:r></w:p>'
        )
        if caption:
            self.add_paragraph(caption, style="Caption", align="center")
        self.add_paragraph()

    def save(self, path: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        document_xml = self._document_xml()
        with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as zf:
            zf.writestr("[Content_Types].xml", self._content_types_xml())
            zf.writestr("_rels/.rels", self._package_rels_xml())
            zf.writestr("docProps/core.xml", self._core_xml())
            zf.writestr("docProps/app.xml", self._app_xml())
            zf.writestr("word/document.xml", document_xml)
            zf.writestr("word/styles.xml", self._styles_xml())
            zf.writestr("word/_rels/document.xml.rels", self._document_rels_xml())
            for image in self.images:
                zf.writestr(f"word/media/{image.name}", image.data)

    def _document_xml(self) -> str:
        return (
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" '
            'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" '
            'xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" '
            'xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" '
            'xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">'
            "<w:body>"
            + "".join(self.body)
            + '<w:sectPr><w:pgSz w:w="11906" w:h="16838"/>'
            '<w:pgMar w:top="1134" w:right="1134" w:bottom="1134" w:left="1134" '
            'w:header="708" w:footer="708" w:gutter="0"/></w:sectPr>'
            "</w:body></w:document>"
        )

    def _content_types_xml(self) -> str:
        return (
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
            '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
            '<Default Extension="xml" ContentType="application/xml"/>'
            '<Default Extension="png" ContentType="image/png"/>'
            '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
            '<Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>'
            '<Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>'
            '<Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>'
            "</Types>"
        )

    def _package_rels_xml(self) -> str:
        return (
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>'
            '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>'
            '<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>'
            "</Relationships>"
        )

    def _document_rels_xml(self) -> str:
        rels = [
            '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
        ]
        for image in self.images:
            rels.append(
                f'<Relationship Id="{image.rel_id}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/{image.name}"/>'
            )
        return (
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            + "".join(rels)
            + "</Relationships>"
        )

    def _core_xml(self) -> str:
        created = datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
        return (
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            '<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" '
            'xmlns:dc="http://purl.org/dc/elements/1.1/" '
            'xmlns:dcterms="http://purl.org/dc/terms/" '
            'xmlns:dcmitype="http://purl.org/dc/dcmitype/" '
            'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
            '<dc:title>Nisarga Project Report</dc:title>'
            '<dc:creator>Codex</dc:creator>'
            f'<dcterms:created xsi:type="dcterms:W3CDTF">{created}</dcterms:created>'
            f'<dcterms:modified xsi:type="dcterms:W3CDTF">{created}</dcterms:modified>'
            "</cp:coreProperties>"
        )

    def _app_xml(self) -> str:
        return (
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            '<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" '
            'xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">'
            "<Application>Codex DOCX Generator</Application>"
            "</Properties>"
        )

    def _styles_xml(self) -> str:
        return """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults>
    <w:rPrDefault><w:rPr><w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/><w:sz w:val="22"/></w:rPr></w:rPrDefault>
    <w:pPrDefault><w:pPr><w:spacing w:after="120" w:line="276" w:lineRule="auto"/></w:pPr></w:pPrDefault>
  </w:docDefaults>
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/></w:style>
  <w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:after="240"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:color w:val="B3315C"/><w:sz w:val="40"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="360" w:after="180"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:color w:val="9A2450"/><w:sz w:val="32"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="240" w:after="120"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:color w:val="B3315C"/><w:sz w:val="28"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="180" w:after="100"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:color w:val="7E3A52"/><w:sz w:val="24"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading4"><w:name w:val="heading 4"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="120" w:after="80"/><w:outlineLvl w:val="3"/></w:pPr><w:rPr><w:b/><w:color w:val="7E3A52"/><w:sz w:val="22"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Caption"><w:name w:val="Caption"/><w:basedOn w:val="Normal"/><w:rPr><w:i/><w:color w:val="666666"/><w:sz w:val="18"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Code"><w:name w:val="Code"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0"/><w:shd w:fill="F5F5F5"/></w:pPr><w:rPr><w:rFonts w:ascii="Consolas" w:hAnsi="Consolas"/><w:sz w:val="18"/></w:rPr></w:style>
</w:styles>"""


def parse_node_token(token: str, labels: dict[str, str]) -> str:
    token = token.strip().rstrip(";")
    token = re.sub(r"\s+", " ", token)
    match = re.match(r"([A-Za-z0-9_]+)(.*)$", token)
    if not match:
        labels.setdefault(token, clean_inline(token))
        return token
    node_id, rest = match.group(1), match.group(2).strip()
    label = None
    for pattern in (
        r"\[\((.*?)\)\]",
        r"\(\[(.*?)\]\)",
        r"\(\((.*?)\)\)",
        r"\[(.*?)\]",
        r"\{(.*?)\}",
        r"\((.*?)\)",
    ):
        found = re.search(pattern, rest)
        if found:
            label = found.group(1)
            break
    labels.setdefault(node_id, clean_inline(label or node_id))
    return node_id


def split_flow_edge(line: str) -> tuple[str, str, str] | None:
    line = line.strip().rstrip(";")
    pipe = re.match(r"(.+?)\s*-->\|([^|]+)\|\s*(.+)$", line)
    if pipe:
        return pipe.group(1), pipe.group(3), pipe.group(2)
    labeled = re.match(r"(.+?)\s*--\s*([^>-]+?)\s*-->\s*(.+)$", line)
    if labeled:
        return labeled.group(1), labeled.group(3), labeled.group(2)
    if "-->" in line:
        left, right = line.split("-->", 1)
        return left, right, ""
    return None


def render_flow_diagram(source: str) -> bytes:
    lines = [line.strip() for line in source.splitlines() if line.strip()]
    direction = "LR" if lines and " LR" in lines[0] else "TD"
    labels: dict[str, str] = {}
    edges: list[tuple[str, str, str]] = []
    order: list[str] = []

    for line in lines[1:]:
        edge = split_flow_edge(line)
        if edge:
            left, right, edge_label = edge
            start = parse_node_token(left, labels)
            end = parse_node_token(right, labels)
            edges.append((start, end, clean_inline(edge_label)))
            for node in (start, end):
                if node not in order:
                    order.append(node)
        else:
            node = parse_node_token(line, labels)
            if node not in order:
                order.append(node)

    layers: dict[str, int] = {}
    for node in order:
        layers.setdefault(node, 0)
    for start, end, _ in edges:
        layers.setdefault(start, 0)
        if end not in layers or layers[end] == 0 and start != end:
            layers[end] = layers[start] + 1

    grouped: dict[int, list[str]] = {}
    for node in order:
        grouped.setdefault(layers.get(node, 0), []).append(node)

    max_layer = max(grouped, default=0)
    max_count = max((len(nodes) for nodes in grouped.values()), default=1)
    width = max(8.5, (max_layer + 1) * 2.6 if direction == "LR" else max_count * 2.8)
    height = max(5.0, max_count * 1.2 if direction == "LR" else (max_layer + 1) * 1.35)
    fig, ax = plt.subplots(figsize=(width, height), dpi=160)
    ax.axis("off")
    positions: dict[str, tuple[float, float]] = {}

    for layer, nodes in grouped.items():
        count = len(nodes)
        for index, node in enumerate(nodes):
            if direction == "LR":
                x = layer * 2.6
                y = (count - 1) / 2 - index
            else:
                x = index * 2.8 - (count - 1) * 1.4
                y = -layer * 1.35
            positions[node] = (x, y)

    for start, end, edge_label in edges:
        if start not in positions or end not in positions:
            continue
        sx, sy = positions[start]
        ex, ey = positions[end]
        arrow = FancyArrowPatch(
            (sx, sy),
            (ex, ey),
            arrowstyle="-|>",
            mutation_scale=12,
            linewidth=1.1,
            color="#5F4B52",
            shrinkA=30,
            shrinkB=30,
            connectionstyle="arc3,rad=0.05",
        )
        ax.add_patch(arrow)
        if edge_label:
            ax.text(
                (sx + ex) / 2,
                (sy + ey) / 2 + 0.12,
                wrap_label(edge_label, 16),
                ha="center",
                va="center",
                fontsize=7,
                color="#555555",
                bbox=dict(boxstyle="round,pad=0.12", fc="white", ec="none", alpha=0.85),
            )

    for node, (x, y) in positions.items():
        label = wrap_label(labels.get(node, node), 18)
        ax.text(
            x,
            y,
            label,
            ha="center",
            va="center",
            fontsize=8.5,
            color="#3A2D32",
            bbox=dict(
                boxstyle="round,pad=0.35",
                fc="#FFF5F8",
                ec="#C95B83",
                lw=1.2,
            ),
        )

    if positions:
        xs = [p[0] for p in positions.values()]
        ys = [p[1] for p in positions.values()]
        ax.set_xlim(min(xs) - 1.4, max(xs) + 1.4)
        ax.set_ylim(min(ys) - 1.0, max(ys) + 1.0)
    return fig_to_png(fig)


def render_er_diagram(source: str) -> bytes:
    labels: dict[str, str] = {}
    edges: list[tuple[str, str, str]] = []
    for line in source.splitlines()[1:]:
        line = line.strip()
        if not line:
            continue
        match = re.match(r"([A-Za-z0-9_]+)\s+.+?\s+([A-Za-z0-9_]+)\s*:\s*(.+)$", line)
        if not match:
            continue
        start, end, rel = match.groups()
        labels[start] = start.replace("_", " ").title()
        labels[end] = end.replace("_", " ").title()
        edges.append((start, end, rel))

    nodes = list(labels)
    count = max(len(nodes), 1)
    radius = max(2.4, count * 0.28)
    fig, ax = plt.subplots(figsize=(10, 7), dpi=160)
    ax.axis("off")
    positions: dict[str, tuple[float, float]] = {}
    for index, node in enumerate(nodes):
        angle = 2 * math.pi * index / count
        positions[node] = (math.cos(angle) * radius, math.sin(angle) * radius)

    for start, end, rel in edges:
        sx, sy = positions[start]
        ex, ey = positions[end]
        arrow = FancyArrowPatch(
            (sx, sy),
            (ex, ey),
            arrowstyle="-",
            linewidth=1.0,
            color="#5F4B52",
            shrinkA=28,
            shrinkB=28,
            connectionstyle="arc3,rad=0.08",
        )
        ax.add_patch(arrow)
        ax.text(
            (sx + ex) / 2,
            (sy + ey) / 2,
            clean_inline(rel),
            fontsize=7,
            ha="center",
            va="center",
            color="#555555",
            bbox=dict(boxstyle="round,pad=0.12", fc="white", ec="none", alpha=0.85),
        )

    for node, (x, y) in positions.items():
        ax.text(
            x,
            y,
            wrap_label(labels[node], 16),
            ha="center",
            va="center",
            fontsize=8.5,
            bbox=dict(boxstyle="round,pad=0.35", fc="#FFF5F8", ec="#C95B83", lw=1.2),
        )
    ax.set_xlim(-radius - 1.6, radius + 1.6)
    ax.set_ylim(-radius - 1.3, radius + 1.3)
    return fig_to_png(fig)


def render_gantt(source: str) -> bytes:
    tasks: list[tuple[str, str, datetime, int]] = []
    task_end_by_id: dict[str, datetime] = {}
    current_section = "Project"
    current_date = datetime(2026, 5, 1)

    for raw in source.splitlines():
        line = raw.strip()
        if not line or line.startswith("gantt") or line.startswith("title") or line.startswith("dateFormat"):
            continue
        if line.startswith("section"):
            current_section = line.replace("section", "", 1).strip()
            continue
        if ":" not in line:
            continue
        name, spec = line.split(":", 1)
        parts = [part.strip() for part in spec.split(",")]
        status_offset = 1 if parts and parts[0] in {"done", "active", "crit"} else 0
        task_id = parts[status_offset] if len(parts) > status_offset else f"task{len(tasks)}"
        start_part = parts[status_offset + 1] if len(parts) > status_offset + 1 else ""
        duration_part = parts[status_offset + 2] if len(parts) > status_offset + 2 else "1d"
        if re.match(r"\d{4}-\d{2}-\d{2}", start_part):
            start = datetime.strptime(start_part, "%Y-%m-%d")
        elif start_part.startswith("after "):
            start = task_end_by_id.get(start_part.split(" ", 1)[1], current_date)
        else:
            start = current_date
        duration_match = re.search(r"(\d+)d", duration_part)
        duration = int(duration_match.group(1)) if duration_match else 1
        tasks.append((clean_inline(name), current_section, start, duration))
        task_end_by_id[task_id] = start + timedelta(days=duration)
        current_date = start + timedelta(days=duration)

    if not tasks:
        return render_text_image(source, "Gantt Chart")

    min_date = min(task[2] for task in tasks)
    fig, ax = plt.subplots(figsize=(10, max(4.5, len(tasks) * 0.42)), dpi=160)
    colors = ["#E55C8A", "#7E57C2", "#26A69A", "#FFB74D"]
    section_colors: dict[str, str] = {}
    for i, (name, section, start, duration) in enumerate(tasks):
        section_colors.setdefault(section, colors[len(section_colors) % len(colors)])
        y = len(tasks) - i - 1
        ax.barh(
            y,
            duration,
            left=(start - min_date).days,
            color=section_colors[section],
            edgecolor="#5F4B52",
            height=0.55,
        )
        ax.text((start - min_date).days + duration + 0.15, y, name, va="center", fontsize=8)

    ax.set_yticks([])
    ax.set_xlabel("Project days")
    ax.set_title("Nisarga Project Timeline", color="#9A2450", weight="bold")
    ax.grid(axis="x", alpha=0.25)
    ax.spines[["top", "right", "left"]].set_visible(False)
    return fig_to_png(fig)


def render_text_image(source: str, title: str) -> bytes:
    lines = source.splitlines()
    fig, ax = plt.subplots(figsize=(10, max(4, len(lines) * 0.22)), dpi=160)
    ax.axis("off")
    ax.text(0.02, 0.98, title, ha="left", va="top", fontsize=12, weight="bold", color="#9A2450")
    ax.text(
        0.02,
        0.9,
        "\n".join(lines),
        ha="left",
        va="top",
        fontsize=8,
        family="monospace",
        bbox=dict(boxstyle="round,pad=0.4", fc="#FFF5F8", ec="#C95B83"),
    )
    return fig_to_png(fig)


def fig_to_png(fig) -> bytes:
    buffer = io.BytesIO()
    fig.tight_layout()
    fig.savefig(buffer, format="png", bbox_inches="tight", facecolor="white")
    plt.close(fig)
    return buffer.getvalue()


def render_mermaid(source: str) -> bytes:
    stripped = source.lstrip()
    if stripped.startswith("erDiagram"):
        return render_er_diagram(source)
    if stripped.startswith("gantt"):
        return render_gantt(source)
    if stripped.startswith("graph") or stripped.startswith("flowchart"):
        return render_flow_diagram(source)
    return render_text_image(source, "Mermaid Diagram")


def parse_table(lines: list[str], start: int) -> tuple[list[list[str]], int]:
    rows: list[list[str]] = []
    index = start
    while index < len(lines) and lines[index].strip().startswith("|"):
        line = lines[index].strip()
        cells = [cell.strip() for cell in line.strip("|").split("|")]
        is_separator = all(re.fullmatch(r":?-{3,}:?", cell or "") for cell in cells)
        if not is_separator:
            rows.append(cells)
        index += 1
    return rows, index


def build_docx_from_readme() -> None:
    if not README.exists():
        raise FileNotFoundError(f"README not found: {README}")
    lines = README.read_text(encoding="utf-8").splitlines()
    doc = DocxBuilder()
    index = 0
    figure_index = 1

    while index < len(lines):
        line = lines[index]
        stripped = line.strip()

        if not stripped:
            index += 1
            continue

        if stripped == "---":
            doc.add_paragraph()
            index += 1
            continue

        if stripped.startswith("```"):
            lang = stripped[3:].strip().lower()
            index += 1
            code_lines: list[str] = []
            while index < len(lines) and not lines[index].strip().startswith("```"):
                code_lines.append(lines[index])
                index += 1
            index += 1
            if lang == "mermaid":
                png = render_mermaid("\n".join(code_lines))
                doc.add_image(png, caption=f"Figure {figure_index} - Rendered diagram")
                figure_index += 1
            else:
                doc.add_code_block(code_lines)
            continue

        heading = re.match(r"^(#{1,6})\s+(.+)$", stripped)
        if heading:
            level = len(heading.group(1))
            doc.add_heading(heading.group(2), level)
            index += 1
            continue

        if stripped.startswith("|"):
            rows, index = parse_table(lines, index)
            doc.add_table(rows)
            continue

        bullet = re.match(r"^[-*]\s+(.+)$", stripped)
        if bullet:
            doc.add_paragraph("- " + bullet.group(1), indent_twips=360)
            index += 1
            continue

        numbered = re.match(r"^(\d+)\.\s+(.+)$", stripped)
        if numbered:
            doc.add_paragraph(f"{numbered.group(1)}. {numbered.group(2)}", indent_twips=360)
            index += 1
            continue

        doc.add_paragraph(stripped)
        index += 1

    doc.save(OUTPUT)
    print(OUTPUT)


if __name__ == "__main__":
    build_docx_from_readme()
