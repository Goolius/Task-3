from pathlib import Path
import re

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import mm
from reportlab.platypus import (
    Flowable,
    PageBreak,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "output" / "pdf" / "RentRepairLog_RequiredDocument.pdf"


class ArchitectureDiagram(Flowable):
    def __init__(self):
        super().__init__()
        self.width = landscape(A4)[0] - 36 * mm
        self.height = landscape(A4)[1] - 42 * mm

    def draw(self):
        c = self.canv
        c.setFont("Helvetica-Bold", 16)
        c.drawString(0, self.height - 8, "Architecture Diagram: RentRepair Log")
        c.setFont("Helvetica", 8)
        c.setFillColor(colors.HexColor("#475569"))
        c.drawString(0, self.height - 21, "Primary data flow: renter reports a repair -> use case applies rules -> repository persists -> UI and widget refresh.")

        def box(x, y, w, h, title, body, fill="#F8FAFC", stroke="#0F766E"):
            c.setStrokeColor(colors.HexColor(stroke))
            c.setFillColor(colors.HexColor(fill))
            c.roundRect(x, y, w, h, 5, stroke=1, fill=1)
            c.setFillColor(colors.HexColor("#0F172A"))
            c.setFont("Helvetica-Bold", 8)
            c.drawString(x + 6, y + h - 12, title)
            c.setFont("Helvetica", 6.2)
            text = c.beginText(x + 6, y + h - 24)
            text.setLeading(7.2)
            for line in body.split("\n"):
                text.textLine(line)
            c.drawText(text)

        def arrow(x1, y1, x2, y2, label=None):
            c.setStrokeColor(colors.HexColor("#334155"))
            c.line(x1, y1, x2, y2)
            c.setFillColor(colors.HexColor("#334155"))
            if x2 >= x1:
                c.line(x2, y2, x2 - 5, y2 + 3)
                c.line(x2, y2, x2 - 5, y2 - 3)
            else:
                c.line(x2, y2, x2 + 5, y2 + 3)
                c.line(x2, y2, x2 + 5, y2 - 3)
            if label:
                c.setFont("Helvetica", 6.5)
                c.drawCentredString((x1 + x2) / 2, y1 + 5, label)

        y = self.height - 112
        layer_w = 100
        h = 72
        xs = [0, 116, 232, 348, 464, 580]
        titles = [
            "Human Boundary",
            "SwiftUI Views",
            "ViewModels",
            "Use Cases",
            "Repository",
            "Core Data",
        ]
        bodies = [
            "NSW renter\nrecords repairs,\nevidence, follow-ups",
            "Dashboard\nRepairs\nDetail\nNew Repair\nInbox\nProperty",
            "DashboardVM\nRepairListVM\nDetailVM\nInboxVM\nPropertyVM",
            "ReportRepair\nAddEvidence\nScheduleFollowUp\nResolveRepair\nImportEvidence",
            "RepairRepository\nprotocol\nCoreData repository\nMock repository",
            "RentalPropertyRecord\nRepairIssueRecord\nEvidenceItemRecord\nFollowUpRecord",
        ]
        for x, title, body in zip(xs, titles, bodies):
            box(x, y, layer_w, h, title, body)
        for i in range(len(xs) - 1):
            arrow(xs[i] + layer_w, y + h / 2, xs[i + 1], y + h / 2)

        app_group_y = y - 106
        box(125, app_group_y, 210, 70, "App Group: group.com.example.rentrepairlog", "repair-summary.json\nnext follow-up for widget\n\nevidence-inbox.json\nShare Extension inbox", "#ECFEFF", "#0891B2")
        box(0, app_group_y, 105, 70, "Widget Extension", "RentRepairWidget\nsystemSmall\nsystemMedium\nreads summary JSON", "#F0FDF4", "#16A34A")
        box(360, app_group_y, 126, 70, "Share Extension", "Accepts shared text,\nURLs, images, PDFs\nwrites inbox JSON\ndismisses cleanly", "#FEFCE8", "#CA8A04")
        box(508, app_group_y, 180, 70, "Main App Response", "Writes widget snapshot\nafter domain changes\nreloads WidgetCenter\nimports shared evidence", "#FDF2F8", "#DB2777")
        arrow(125, app_group_y + 38, 105, app_group_y + 38, "reads")
        arrow(360, app_group_y + 38, 335, app_group_y + 38, "writes")
        arrow(630, y, 630, app_group_y + 70)

        schema_y = app_group_y - 94
        box(0, schema_y, 155, 55, "Schema Relationships", "Property 1 -> many Repairs\nRepair 1 -> many Evidence\nRepair 1 -> many Follow-ups", "#F8FAFC", "#475569")
        box(175, schema_y, 155, 55, "Meaningful Predicate", "Fetch urgent unresolved repairs\nwhere targetFollowUpDate\nis on or before today", "#F8FAFC", "#475569")
        box(350, schema_y, 155, 55, "Business Rules", "No repair without property\nNo evidence on resolved repair\nNo follow-up before first report\nNo resolve without evidence", "#F8FAFC", "#475569")
        box(525, schema_y, 155, 55, "Testing Evidence", "RentRepairUseCaseTests\nMockRepairRepository\nhappy path, boundary,\ndomain failure scenarios", "#F8FAFC", "#475569")


def styles():
    base = getSampleStyleSheet()
    base["Title"].fontName = "Helvetica-Bold"
    base["Title"].fontSize = 24
    base["Title"].alignment = TA_CENTER
    base["Heading1"].fontName = "Helvetica-Bold"
    base["Heading1"].fontSize = 15
    base["Heading1"].spaceBefore = 8
    base["Heading1"].spaceAfter = 8
    base["Heading2"].fontName = "Helvetica-Bold"
    base["Heading2"].fontSize = 11
    base["BodyText"].fontName = "Helvetica"
    base["BodyText"].fontSize = 9.5
    base["BodyText"].leading = 13
    base.add(ParagraphStyle(name="Small", parent=base["BodyText"], fontSize=8, leading=10))
    base.add(ParagraphStyle(name="CenterSmall", parent=base["Small"], alignment=TA_CENTER))
    return base


def para(text, style):
    return Paragraph(text, style)


def table(data, widths):
    t = Table(data, colWidths=widths, repeatRows=1)
    t.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#0F766E")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
                ("FONTNAME", (0, 1), (-1, -1), "Helvetica"),
                ("FONTSIZE", (0, 0), (-1, -1), 7.5),
                ("LEADING", (0, 0), (-1, -1), 9),
                ("GRID", (0, 0), (-1, -1), 0.25, colors.HexColor("#CBD5E1")),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#F8FAFC")]),
                ("LEFTPADDING", (0, 0), (-1, -1), 5),
                ("RIGHTPADDING", (0, 0), (-1, -1), 5),
                ("TOPPADDING", (0, 0), (-1, -1), 4),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
            ]
        )
    )
    return t


reflection = """
I chose rental repairs because it is a small, concrete problem where the technical requirements do not feel artificial. NSW renter guidance already expects repair issues to be communicated clearly, escalated through Fair Trading or the Tribunal if unresolved, and supported by records and evidence. That made the stakeholder precise: a NSW private renter trying to manage one home, one agent or landlord, and a timeline of defects. I did not need to invent a dramatic scenario. The everyday friction is enough: photos sit in Photos, messages sit in Messages, emails sit in Mail, and the follow-up date often lives only in the renter's memory.

My understanding changed while building the app. At first the obvious feature seemed to be a generic repair list. The more important feature became chronology. A renter does not just need to know that a window is broken; they need to show when it was first reported, what evidence existed, when they followed up, and whether the issue remained urgent. That is why the detail screen is evidence-heavy and why resolving a repair requires at least one evidence item. This rule is slightly strict, but it protects the core value of the system: a defensible timeline.

The WidgetKit extension serves the moment when the renter is busy and does not want to open the app just to check what needs attention. Removing the widget would not break the database, but it would make the app easier to forget, which is exactly the failure pattern the solution is meant to reduce. The widget reads only a summary from the App Group rather than opening Core Data directly, because extensions should stay small and because the main app already owns the domain rules.

The Share Extension is more important than the widget. Repair evidence usually starts outside the app: a text from the agent, an email, a PDF quote, a Safari link, or a photo. If the renter must manually copy everything later, the evidence trail becomes unreliable. The extension writes shared evidence metadata into an App Group inbox, and the main app asks the renter which repair it belongs to. I deliberately did not let the extension attach evidence directly to a repair, because the extension does not have enough context to choose safely.

I chose Core Data instead of CloudKit because the data is private, single-user, and useful offline. A repair dispute timeline may include sensitive home details, contact names, and evidence notes. Sync would be convenient, but it is not required for the stakeholder workflow and would add account, merge, and privacy complexity. The key schema decision was making `RepairIssueRecord` the centre of the model, with evidence and follow-ups as child records. That matches the renter's mental model: everything exists because it supports a particular repair issue.

The main architecture pressure came from extensions. The cleanest domain architecture keeps all data behind use cases and repositories, but WidgetKit and Share Extensions cannot simply use the app's ViewModels. I resolved this by using the App Group as a boundary. The main app writes a widget snapshot after relevant data changes, and the Share Extension writes inbox items that the app later imports through a use case. This keeps extension code simple while preserving the app's layered architecture.

The other pressure was between speed and proof. A renter wants to capture evidence quickly, especially when sharing from another app, but the assessment also requires meaningful domain rules. I chose to let the Share Extension capture evidence into an inbox first, then require the main app to attach it to a specific repair. That adds one review step, but it prevents evidence being filed under the wrong issue and keeps the timeline trustworthy.

AI assistance was used throughout the build for planning, code generation, documentation drafting, and review. The useful parts were rapid scaffolding and cross-checking the rubric against the implementation. The parts that needed careful evaluation were Xcode project target wiring, extension Info.plist behavior, and date-sensitive unit test data. I verified the output by building the app, running the unit tests, checking target membership, and comparing the README, report, and code against the canonical specification. I would not submit the AI output unreviewed, because small inconsistencies in bundle identifiers, App Group names, or entity names would be easy to miss and costly in marking.
""".strip()


def word_count(text):
    return len(re.findall(r"\b[\w']+\b", text))


def build():
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    s = styles()
    doc = SimpleDocTemplate(
        str(OUTPUT),
        pagesize=landscape(A4),
        rightMargin=16 * mm,
        leftMargin=16 * mm,
        topMargin=14 * mm,
        bottomMargin=14 * mm,
        title="RentRepair Log Required Document",
    )
    story = []

    story.append(para("RentRepair Log", s["Title"]))
    story.append(para("Required Document - Assessment Task 3", s["CenterSmall"]))
    story.append(Spacer(1, 8 * mm))
    story.append(para("Section 1: Problem Statement", s["Heading1"]))
    story.append(
        para(
            "The problem is that NSW private renters often need to manage repairs across scattered evidence: messages, emails, photos, files, dates, and verbal follow-up notes. When a repair is delayed, the renter needs a clear written timeline that shows what was reported, when it was reported, what evidence exists, and what follow-up action is due. Without that timeline, escalation becomes slower and more stressful because the renter must reconstruct events from several apps.",
            s["BodyText"],
        )
    )
    story.append(
        para(
            "The primary stakeholder is a NSW private renter managing repair communication with a landlord or property manager. The context is ordinary residential tenancy, not commercial property management. The human cost is practical and personal: lost time, missed follow-ups, uncertainty about urgent repairs, and weaker evidence if the dispute reaches Fair Trading or the Tribunal.",
            s["BodyText"],
        )
    )
    story.append(
        para(
            "Real-world evidence: NSW Government renter guidance describes how tenants get repairs done, distinguishes urgent repairs, and describes dispute pathways. NSW Government dispute guidance also advises tenants to keep records and evidence where disputes may arise. Sources: https://www.nsw.gov.au/housing-and-construction/renting-a-place-to-live/getting-repairs-done, https://www.nsw.gov.au/housing-and-construction/rules/urgent-repairs-residential-rental-properties, and https://www.nsw.gov.au/housing-and-construction/renting-a-place-to-live/resolving-residential-tenancy-disputes.",
            s["Small"],
        )
    )

    story.append(para("Section 2: Design Justification", s["Heading1"]))
    story.append(
        para(
            "An iOS app is appropriate because the renter records evidence at the moment it appears. Photos, shared messages, PDFs, and links are already on the phone. Offline access matters because a repair timeline should remain available during inspections, calls, or unreliable connectivity. A website could store the same data, but it would not integrate as directly with the Share sheet or Home Screen widget.",
            s["BodyText"],
        )
    )
    story.append(
        para(
            "The widget exists for a specific scenario: the renter needs to see the next repair follow-up without opening the app. It reads a small App Group snapshot and supports systemSmall and systemMedium families. The Share Extension exists for another scenario: evidence starts in Messages, Mail, Photos, Files, or Safari. It writes evidence inbox items to the App Group so the app can attach them to the correct repair.",
            s["BodyText"],
        )
    )
    story.append(
        para(
            "Core Data was selected because this data is private, single-user, structured, and useful offline. The schema has one rental property with many repair issues, and each repair issue has many evidence items and follow-up notes. The repository query for urgent unresolved repairs due for follow-up reflects the domain need: the renter needs to know what requires attention now.",
            s["BodyText"],
        )
    )
    story.append(
        table(
            [
                ["Entity", "Purpose", "Relationships", "Business Rule / Use"],
                ["RentalPropertyRecord", "Address and agent contact", "Has many repairs", "A repair cannot be reported until a property exists"],
                ["RepairIssueRecord", "Repair title, urgency, status, and follow-up date", "Belongs to property; has evidence and follow-ups", "Urgent unresolved due repairs appear on dashboard and widget"],
                ["EvidenceItemRecord", "Evidence imported or entered by renter", "Belongs to one repair", "Cannot be added to a resolved repair"],
                ["FollowUpRecord", "Follow-up due date and note", "Belongs to one repair", "Cannot be before the first report date"],
            ],
            [38 * mm, 54 * mm, 62 * mm, 76 * mm],
        )
    )

    story.append(PageBreak())
    story.append(ArchitectureDiagram())

    story.append(PageBreak())
    story.append(para("Section 4: Reflective Report", s["Heading1"]))
    story.append(para(f"Word count: {word_count(reflection)}", s["Small"]))
    for paragraph in reflection.split("\n\n"):
        story.append(para(paragraph, s["BodyText"]))
        story.append(Spacer(1, 2.4 * mm))

    story.append(para("References", s["Heading1"]))
    refs = [
        "NSW Government. Getting repairs done on a rental property. https://www.nsw.gov.au/housing-and-construction/renting-a-place-to-live/getting-repairs-done",
        "NSW Government. Urgent repairs in residential rental properties. https://www.nsw.gov.au/housing-and-construction/rules/urgent-repairs-residential-rental-properties",
        "NSW Government. Resolving residential tenancy disputes. https://www.nsw.gov.au/housing-and-construction/renting-a-place-to-live/resolving-residential-tenancy-disputes",
    ]
    for ref in refs:
        story.append(para(ref, s["Small"]))

    def footer(canvas, document):
        canvas.saveState()
        canvas.setFont("Helvetica", 7)
        canvas.setFillColor(colors.HexColor("#64748B"))
        canvas.drawString(16 * mm, 8 * mm, "RentRepair Log - Required Document")
        canvas.drawRightString(landscape(A4)[0] - 16 * mm, 8 * mm, f"Page {document.page}")
        canvas.restoreState()

    doc.build(story, onFirstPage=footer, onLaterPages=footer)


if __name__ == "__main__":
    build()
    print(OUTPUT)
