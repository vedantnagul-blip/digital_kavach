import pptx
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN

prs = pptx.Presentation()
prs.slide_width = Inches(13.333)
prs.slide_height = Inches(7.5)
blank_layout = prs.slide_layouts[6]

DARK_NAVY = RGBColor(10, 25, 47)
WHITE = RGBColor(255, 255, 255)
CYAN = RGBColor(0, 229, 255)
LIGHT_BLUE = RGBColor(220, 240, 255)

# SLIDE 1 (image-2.jpeg: Title Slide)
s1 = prs.slides.add_slide(blank_layout)
s1.shapes.add_picture('/tmp/arena-coding-uploads/image-2.jpeg', 0, 0, width=Inches(13.333), height=Inches(7.5))

tb1 = s1.shapes.add_textbox(Inches(3.2), Inches(2.05), Inches(8.5), Inches(3.6))
tf1 = tb1.text_frame
tf1.word_wrap = True
tf1.margin_left = tf1.margin_right = tf1.margin_top = tf1.margin_bottom = 0

entries = [
    ("Team KavachX", Pt(20)),
    ("Vedant Nagul", Pt(20)),
    ("Fabtech Technical Campus, Sangola", Pt(20)),
    ("Cybersecurity / Mobile Defense", Pt(20)),
    ("Digital Kavach", Pt(24))
]

for idx, (text, font_size) in enumerate(entries):
    p = tf1.paragraphs[0] if idx == 0 else tf1.add_paragraph()
    p.space_after = Pt(14)
    run = p.add_run()
    run.text = text
    run.font.name = 'Arial'
    run.font.size = font_size
    run.font.bold = True
    run.font.color.rgb = DARK_NAVY

# SLIDE 2 (image-3.jpeg: Problem Statement)
s2 = prs.slides.add_slide(blank_layout)
s2.shapes.add_picture('/tmp/arena-coding-uploads/image-3.jpeg', 0, 0, width=Inches(13.333), height=Inches(7.5))

tb2 = s2.shapes.add_textbox(Inches(0.8), Inches(2.6), Inches(11.7), Inches(4.3))
tf2 = tb2.text_frame
tf2.word_wrap = True
tf2.margin_left = tf2.margin_right = tf2.margin_top = tf2.margin_bottom = 0

p2_items = [
    ("Problem:", " Vernacular cyber-frauds, Devanagari scams & spoofed UPI QR codes bypass standard security tools."),
    ("Target Audience:", " 800M+ Indian UPI users, senior citizens & vernacular speakers across Tier-2/3 regions."),
    ("Impact:", " Stops financial loss in real time & recovers funds during the critical 24-hr Golden Hour window.")
]

for idx, (title, desc) in enumerate(p2_items):
    p = tf2.paragraphs[0] if idx == 0 else tf2.add_paragraph()
    p.space_after = Pt(20)
    
    r1 = p.add_run()
    r1.text = "• " + title
    r1.font.name = 'Arial'
    r1.font.size = Pt(20)
    r1.font.bold = True
    r1.font.color.rgb = DARK_NAVY
    
    r2 = p.add_run()
    r2.text = desc
    r2.font.name = 'Arial'
    r2.font.size = Pt(20)
    r2.font.color.rgb = DARK_NAVY

# SLIDE 3 (image-4.jpeg: Solution)
s3 = prs.slides.add_slide(blank_layout)
s3.shapes.add_picture('/tmp/arena-coding-uploads/image-4.jpeg', 0, 0, width=Inches(13.333), height=Inches(7.5))

tb3 = s3.shapes.add_textbox(Inches(0.8), Inches(2.6), Inches(11.7), Inches(4.3))
tf3 = tb3.text_frame
tf3.word_wrap = True
tf3.margin_left = tf3.margin_right = tf3.margin_top = tf3.margin_bottom = 0

p3_items = [
    ("Solution:", " Zero-trust mobile shield with background notification interception & on-device AI."),
    ("Prototype:", " Functional Flutter Android app with real-time Sentinel, OCR & 1930 recovery wizard."),
    ("Tech-Stack:", " Flutter, Riverpod, Hive, Google ML Kit (Devanagari OCR), Few-Shot RAG Threat Memory."),
    ("Workflow:", " Notification Intercept ➔ 570+ Rules & OCR ➔ Ghost QR Check ➔ 1930 Golden Hour Action.")
]

for idx, (title, desc) in enumerate(p3_items):
    p = tf3.paragraphs[0] if idx == 0 else tf3.add_paragraph()
    p.space_after = Pt(16)
    
    r1 = p.add_run()
    r1.text = "• " + title
    r1.font.name = 'Arial'
    r1.font.size = Pt(19)
    r1.font.bold = True
    r1.font.color.rgb = DARK_NAVY
    
    r2 = p.add_run()
    r2.text = desc
    r2.font.name = 'Arial'
    r2.font.size = Pt(19)
    r2.font.color.rgb = DARK_NAVY

# SLIDE 4 (image-5.jpeg: Innovation)
s4 = prs.slides.add_slide(blank_layout)
s4.shapes.add_picture('/tmp/arena-coding-uploads/image-5.jpeg', 0, 0, width=Inches(13.333), height=Inches(7.5))

tb4 = s4.shapes.add_textbox(Inches(0.8), Inches(2.6), Inches(11.7), Inches(4.3))
tf4 = tb4.text_frame
tf4.word_wrap = True
tf4.margin_left = tf4.margin_right = tf4.margin_top = tf4.margin_bottom = 0

p4_items = [
    ("Ghost UPI Shield:", " Detects forged merchant names masking private VPAs before payment triggers."),
    ("AI ScamBaiter Bot:", " Proactively stalls fraudsters with decoy personas to extract mule account details."),
    ("10 Indian Languages:", " True native vernacular support across all screens, rules & OCR analysis."),
    ("Zero-Key Security:", " Fully client-side protected architecture with zero exposed API keys or PII.")
]

for idx, (title, desc) in enumerate(p4_items):
    p = tf4.paragraphs[0] if idx == 0 else tf4.add_paragraph()
    p.space_after = Pt(16)
    
    r1 = p.add_run()
    r1.text = "• " + title
    r1.font.name = 'Arial'
    r1.font.size = Pt(19)
    r1.font.bold = True
    r1.font.color.rgb = DARK_NAVY
    
    r2 = p.add_run()
    r2.text = desc
    r2.font.name = 'Arial'
    r2.font.size = Pt(19)
    r2.font.color.rgb = DARK_NAVY

# SLIDE 5 (image-1.jpeg: Market Analysis)
s5 = prs.slides.add_slide(blank_layout)
s5.shapes.add_picture('/tmp/arena-coding-uploads/image-1.jpeg', 0, 0, width=Inches(13.333), height=Inches(7.5))

tb5 = s5.shapes.add_textbox(Inches(0.8), Inches(2.6), Inches(11.7), Inches(4.3))
tf5 = tb5.text_frame
tf5.word_wrap = True
tf5.margin_left = tf5.margin_right = tf5.margin_top = tf5.margin_bottom = 0

p5_items = [
    ("Why Existing Apps Fail:", " Antivirus tools only check English links post-click; ignore SMS/WhatsApp & UPI QRs."),
    ("Digital Kavach Differentiator:", " Proactive notification interception + Ghost UPI QR shield + Active ScamBaiting."),
    ("Post-Scam Legal Automation:", " Only app with a 24-hr Golden Hour wizard auto-drafting NCRP & RBI dispute FIRs."),
    ("Complete Life-Cycle:", " Protects citizens Before (Sentinel), During (Anti-Quishing), and After (Recovery).")
]

for idx, (title, desc) in enumerate(p5_items):
    p = tf5.paragraphs[0] if idx == 0 else tf5.add_paragraph()
    p.space_after = Pt(16)
    
    r1 = p.add_run()
    r1.text = "• " + title
    r1.font.name = 'Arial'
    r1.font.size = Pt(19)
    r1.font.bold = True
    r1.font.color.rgb = DARK_NAVY
    
    r2 = p.add_run()
    r2.text = desc
    r2.font.name = 'Arial'
    r2.font.size = Pt(19)
    r2.font.color.rgb = DARK_NAVY

output_path = '/home/user/digital_kavach/Digital_Kavach_Kurukshetra_Hackathon.pptx'
prs.save(output_path)
print(f'Successfully generated: {output_path}')
