import sys
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.dml.color import RGBColor
from pptx.enum.shapes import MSO_SHAPE

prs = Presentation()
prs.slide_width = Inches(13.333)
prs.slide_height = Inches(7.5)

# Color Palette: Deep Navy & Cyber Security Accents
C_BG_DARK = RGBColor(11, 19, 43)        # #0B132B Deep Cyber Navy
C_BG_CARD = RGBColor(28, 37, 65)        # #1C2541 Slate Card Navy
C_ACCENT_CYAN = RGBColor(0, 212, 255)   # #00D4FF Electric Cyan
C_ACCENT_ORANGE = RGBColor(255, 154, 60) # Safety Orange
C_ACCENT_GREEN = RGBColor(16, 185, 129)  # Safe Green
C_TEXT_WHITE = RGBColor(255, 255, 255)
C_TEXT_MUTED = RGBColor(160, 174, 192)  # Gray text
C_CARD_BORDER = RGBColor(45, 55, 72)

def set_slide_dark_background(slide):
    bg_shape = slide.shapes.add_shape(
        MSO_SHAPE.RECTANGLE, 0, 0, prs.slide_width, prs.slide_height
    )
    bg_shape.fill.solid()
    bg_shape.fill.fore_color.rgb = C_BG_DARK
    bg_shape.line.fill.background()
    return bg_shape

def add_header(slide, title_text, category_text="DIGITAL KAVACH (डिजिटल कवच)"):
    tb = slide.shapes.add_textbox(Inches(0.8), Inches(0.4), Inches(11.7), Inches(1.1))
    tf = tb.text_frame
    tf.word_wrap = True
    tf.margin_left = tf.margin_top = tf.margin_right = tf.margin_bottom = 0
    
    p0 = tf.paragraphs[0]
    p0.text = category_text.upper()
    p0.font.size = Pt(11)
    p0.font.bold = True
    p0.font.color.rgb = C_ACCENT_CYAN
    
    p1 = tf.add_paragraph()
    p1.text = title_text
    p1.font.size = Pt(24)
    p1.font.bold = True
    p1.font.color.rgb = C_TEXT_WHITE

def add_card(slide, left, top, width, height, title, body_bullets, title_color=C_ACCENT_CYAN, bg_color=C_BG_CARD):
    card = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left, top, width, height)
    card.fill.solid()
    card.fill.fore_color.rgb = bg_color
    card.line.color.rgb = C_CARD_BORDER
    card.line.width = Pt(1.2)
    
    tb = slide.shapes.add_textbox(left + Inches(0.2), top + Inches(0.2), width - Inches(0.4), height - Inches(0.4))
    tf = tb.text_frame
    tf.word_wrap = True
    tf.margin_left = tf.margin_top = tf.margin_right = tf.margin_bottom = 0
    
    if title:
        p0 = tf.paragraphs[0]
        p0.text = title
        p0.font.size = Pt(16)
        p0.font.bold = True
        p0.font.color.rgb = title_color
        p0.space_after = Pt(8)
        first_bullet = True
    else:
        first_bullet = False
        
    for item in body_bullets:
        if first_bullet and not title:
            p = tf.paragraphs[0]
            first_bullet = False
        else:
            p = tf.add_paragraph()
        p.text = "• " + item
        p.font.size = Pt(13)
        p.font.color.rgb = C_TEXT_WHITE
        p.space_after = Pt(5)
    return card

# ==========================================
# SLIDE 1: TITLE SLIDE
# ==========================================
slide1 = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_dark_background(slide1)

tb1 = slide1.shapes.add_textbox(Inches(1.0), Inches(1.8), Inches(11.3), Inches(3.8))
tf1 = tb1.text_frame
tf1.word_wrap = True

p = tf1.paragraphs[0]
p.text = "DIGITAL KAVACH (डिजिटल कवच)"
p.font.size = Pt(40)
p.font.bold = True
p.font.color.rgb = C_ACCENT_CYAN
p.space_after = Pt(10)

p2 = tf1.add_paragraph()
p2.text = "An Edge-First, AI-Powered Threat Forensics & Anti-Fraud Shield"
p2.font.size = Pt(22)
p2.font.color.rgb = C_TEXT_WHITE
p2.space_after = Pt(18)

p3 = tf1.add_paragraph()
p3.text = '"Defending Every Indian from Digital Fraud — Privately, Instantly, in Their Mother Tongue."'
p3.font.size = Pt(16)
p3.font.italic = True
p3.font.color.rgb = C_ACCENT_ORANGE
p3.space_after = Pt(25)

p4 = tf1.add_paragraph()
p4.text = "570+ Verified Offline Rules  |  Dynamic Few-Shot RAG Threat Memory  |  10 Indian Languages  |  Elder Mode"
p4.font.size = Pt(13)
p4.font.bold = True
p4.font.color.rgb = C_TEXT_MUTED

# Presenter box bottom right
add_card(slide1, Inches(1.0), Inches(5.6), Inches(11.3), Inches(1.2), "", [
    "Department of Computer Science & Engineering",
    "Presenter: Final Year Mini Project | Target: Academic Seminar & Department Evaluation"
], title_color=C_ACCENT_CYAN)

# ==========================================
# SLIDE 2: THE CYBER FRAUD CRISIS
# ==========================================
slide2 = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_dark_background(slide2)
add_header(slide2, "The Cyber Fraud Crisis in India (2025–2026)")

add_card(slide2, Inches(0.8), Inches(1.7), Inches(3.6), Inches(5.2), "🚨 28+ Lakh Cases", [
    "Over 28 Lakh cybercrimes registered via I4C in 2025 alone.",
    "300% surge in financial fraud over the last 3 years.",
    "Targeting Tier-2, Tier-3 cities & regional language speakers.",
    "Senior citizens & non-English speakers suffer 70%+ of losses."
], title_color=C_ACCENT_ORANGE)

add_card(slide2, Inches(4.8), Inches(1.7), Inches(3.8), Inches(5.2), "⚔️ Modern Modus Operandi", [
    "Digital Arrest: Fake CBI/Police video interrogation via Skype/WhatsApp.",
    "Nighttime Urgency: 'Electricity disconnected at 9:30 PM tonight'.",
    "Malicious APKs: PM-Yojana, fake bank updates that hijack SMS & OTPs.",
    "Telegram Task Scams: 'Like YouTube videos / rate Google Maps'."
], title_color=C_ACCENT_CYAN)

add_card(slide2, Inches(8.9), Inches(1.7), Inches(3.6), Inches(5.2), "⏳ The Golden Hour Crisis", [
    "Victims have only 24–48 hours to freeze siphoned funds via 1930.",
    "Panic & confusion paralyze victims; they don't know who to call.",
    "Evidence (transaction IDs, URLs, numbers) is lost or deleted.",
    "Existing apps only block phone numbers, ignoring chat fraud."
], title_color=C_ACCENT_GREEN)

# ==========================================
# SLIDE 3: WHAT IS DIGITAL KAVACH?
# ==========================================
slide3 = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_dark_background(slide3)
add_header(slide3, "What is Digital Kavach? (Dual Protection Mechanism)")

add_card(slide3, Inches(0.8), Inches(1.7), Inches(5.6), Inches(5.2), "🛡️ Kavach Sentinel (Automated 24x7)", [
    "Background Android Notification Listener Service.",
    "Intercepts WhatsApp, SMS, & Telegram alerts in real time.",
    "Scans threats before the user even taps or opens the scam link.",
    "Zero battery drain: executes in <15ms on-device without waking cloud APIs.",
    "Instant heads-up alarm triggers if suspicious payload is detected."
], title_color=C_ACCENT_CYAN)

add_card(slide3, Inches(6.8), Inches(1.7), Inches(5.7), Inches(5.2), "🔍 Active Forensic Scanner (On-Demand)", [
    "Share Sheet Integration: User forwards any message/link to Kavach.",
    "Devanagari & Latin OCR: Google ML Kit extracts text from screenshots.",
    "Client-Side PII Sanitizer: Masks Aadhaar, PAN, and UPI IDs locally.",
    "Multi-Lingual Verdict: Explains threats in 10 Indian regional languages.",
    "Audio Narration: Reads warnings aloud for elderly and rural users."
], title_color=C_ACCENT_ORANGE)

# ==========================================
# SLIDE 4: DUAL-TIER HYBRID ARCHITECTURE
# ==========================================
slide4 = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_dark_background(slide4)
add_header(slide4, "Dual-Tier Hybrid Edge Architecture")

add_card(slide4, Inches(0.8), Inches(1.7), Inches(5.6), Inches(5.2), "⚡ Tier 1: On-Device Engine (Offline)", [
    "570+ Verified Regex Threat Rules compiled from I4C & CERT-In.",
    "Heuristic Risk Scoring (0 to 100) across 5 risk dimensions.",
    "Works 100% offline with ZERO internet requirement.",
    "Sub-15ms response latency: zero cloud dependencies.",
    "Handles ~80% of routine scam messages directly on-device."
], title_color=C_ACCENT_GREEN)

add_card(slide4, Inches(6.8), Inches(1.7), Inches(5.7), Inches(5.2), "🧠 Tier 2: Dynamic Few-Shot RAG AI", [
    "Triggered only on borderline/ambiguous messages (score 25–65).",
    "ThreatMemoryStore: Local vector cache of confirmed scam playbooks.",
    "Dynamic Few-Shot RAG: Injects real Indian scam precedents into prompt.",
    "Self-Learning: New confirmed scams are saved locally to Threat Memory.",
    "Strict JSON Schema Output with sanitized user-facing reasoning."
], title_color=C_ACCENT_CYAN)

# ==========================================
# SLIDE 5: SECURITY & PRIVACY ENGINEERING
# ==========================================
slide5 = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_dark_background(slide5)
add_header(slide5, "Security & Privacy Engineering (Zero-Trust Design)")

add_card(slide5, Inches(0.8), Inches(1.7), Inches(3.6), Inches(5.2), "🔒 PII Sanitizer Engine", [
    "Aadhaar Redaction: Scans 12-digit UID patterns and masks with [AADHAAR].",
    "PAN Redaction: Detects 10-character alphanumeric PAN format.",
    "Financial Redaction: Masks Indian phone numbers and UPI VPA IDs.",
    "Private user identity NEVER leaves the device or reaches AI."
], title_color=C_ACCENT_CYAN)

add_card(slide5, Inches(4.8), Inches(1.7), Inches(3.8), Inches(5.2), "🛡️ Zero UI Key Exposure", [
    "Complete removal of all API key input forms from the client UI.",
    "Eliminates reverse-engineering risks from APK decompilation.",
    "API credentials configured via compile-time environment flags.",
    "Prevents unauthorized token harvesting and quota drainage."
], title_color=C_ACCENT_ORANGE)

add_card(slide5, Inches(8.9), Inches(1.7), Inches(3.6), Inches(5.2), "⚡ Fault-Tolerant Circuit Breakers", [
    "Automatic failover: If Gemini is rate-limited, Tier 1 takes over.",
    "Deduplication Hash Cache: Hive stores verdict hashes to save 90%+ API calls.",
    "Zero Crash Guarantee: Sanitized error displays prevent raw API leakages.",
    "Works reliably in poor rural network environments."
], title_color=C_ACCENT_GREEN)

# ==========================================
# SLIDE 6: 5 PILLARS OF COMPLETE PROTECTION
# ==========================================
slide6 = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_dark_background(slide6)
add_header(slide6, "5 Core Pillars of Digital Kavach")

add_card(slide6, Inches(0.8), Inches(1.7), Inches(3.6), Inches(2.4), "1. Scam Scanner & Sentinel", [
    "24x7 Notification interception + Screenshot OCR (Devanagari + Latin).",
    "Instant threat verdicts in <15ms."
], title_color=C_ACCENT_CYAN)

add_card(slide6, Inches(4.8), Inches(1.7), Inches(3.8), Inches(2.4), "2. Golden Hour Recovery", [
    "1-Tap direct dialing to 1930 Cyber Helpline.",
    "Auto-drafts legal cyber complaints with cryptographic evidence hash."
], title_color=C_ACCENT_ORANGE)

add_card(slide6, Inches(8.9), Inches(1.7), Inches(3.6), Inches(2.4), "3. Family Shield", [
    "Alerts adult children when an elderly parent receives high-risk messages.",
    "Prevents fraud before money is sent."
], title_color=C_ACCENT_GREEN)

add_card(slide6, Inches(0.8), Inches(4.4), Inches(5.6), Inches(2.5), "4. Accessibility & Elder Mode", [
    "1.4x enlarged typography with oversized 64dp touch targets.",
    "Built-in Text-To-Speech (TTS) reads warnings out loud automatically.",
    "High-contrast color-coded cards (Red = Danger, Green = Safe)."
], title_color=C_ACCENT_CYAN)

add_card(slide6, Inches(6.8), Inches(4.4), Inches(5.7), Inches(2.5), "5. 10 Regional Indian Languages", [
    "Native UI & explanations for: Hindi, Marathi, Tamil, Telugu, Bengali, Gujarati, Kannada, Malayalam, Punjabi, and English.",
    "Zero English-only barriers for Tier-2/3 & rural Indian users."
], title_color=C_ACCENT_ORANGE)

# ==========================================
# SLIDE 7: TECH STACK & PRODUCTION READINESS
# ==========================================
slide7 = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_dark_background(slide7)
add_header(slide7, "Technology Stack & Production Readiness")

add_card(slide7, Inches(0.8), Inches(1.7), Inches(3.6), Inches(5.2), "📱 Frontend & Core", [
    "Framework: Flutter SDK (Dart 3.x).",
    "Architecture: Riverpod 2.x State Management.",
    "Local Storage: Hive NoSQL (Microsecond cached verdict lookup).",
    "Platform: Android Native NotificationListenerService Integration."
], title_color=C_ACCENT_CYAN)

add_card(slide7, Inches(4.8), Inches(1.7), Inches(3.8), Inches(5.2), "👁️ Vision & NLP Engine", [
    "Google ML Kit Text Recognition with specialized Devanagari script model.",
    "Tier 1: 570+ Compiled Regular Expressions & Token Analyzers.",
    "PII Redaction: Custom regex sanitizers for Aadhaar, PAN, UPI, and Phones.",
    "Dynamic RAG: ThreatMemoryStore vector storage."
], title_color=C_ACCENT_ORANGE)

add_card(slide7, Inches(8.9), Inches(1.7), Inches(3.6), Inches(5.2), "💰 ₹0 Operational Cost", [
    "80%+ of scans resolved on-device via Tier 1 without calling cloud APIs.",
    "Free-Tier Google Gemini API used strictly for ambiguous messages.",
    "Result Caching: If 1,000 users get the same scam, only 1 API call is used.",
    "100% production-ready for student deployment."
], title_color=C_ACCENT_GREEN)

# ==========================================
# SLIDE 8: HOW DIGITAL KAVACH COMPUTES & COMPARES
# ==========================================
slide8 = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_dark_background(slide8)
add_header(slide8, "Comparative Analysis: Why Digital Kavach Wins")

add_card(slide8, Inches(0.8), Inches(1.7), Inches(3.6), Inches(5.2), "❌ Truecaller", [
    "Only identifies known phone numbers during incoming calls.",
    "Completely blind to WhatsApp, Telegram, and SMS body text.",
    "Cannot inspect screenshots, QR codes, or payment receipts.",
    "Zero post-fraud recovery assistance."
], title_color=RGBColor(239, 68, 68))

add_card(slide8, Inches(4.8), Inches(1.7), Inches(3.8), Inches(5.2), "⚠️ Traditional Antivirus", [
    "Looks for virus signatures in APK files and system permissions.",
    "Cannot detect social engineering, urgency, or digital arrest scams.",
    "Heavy background battery and memory drain.",
    "Available only in English with complex technical jargon."
], title_color=C_ACCENT_ORANGE)

add_card(slide8, Inches(8.9), Inches(1.7), Inches(3.6), Inches(5.2), "✅ Digital Kavach", [
    "Analyzes message semantics, psychological urgency, and threats.",
    "Inspects WhatsApp, Telegram, SMS, screenshots, and QR codes.",
    "Self-learning RAG threat memory dynamically evolves with new scams.",
    "Full support for 10 Indian languages + 1930 Golden Hour Recovery."
], title_color=C_ACCENT_GREEN)

# ==========================================
# SLIDE 9: CONCLUSION & LIVE DEMO
# ==========================================
slide9 = prs.slides.add_slide(prs.slide_layouts[6])
set_slide_dark_background(slide9)
add_header(slide9, "Conclusion & Live Demonstration")

add_card(slide9, Inches(0.8), Inches(1.7), Inches(5.6), Inches(5.2), "🎯 Summary of Achievements", [
    "Edge-First Defense: 570+ rules detect threats instantly with zero internet.",
    "Privacy-Guaranteed: On-device PII masking protects citizen privacy.",
    "Vernacular & Elder Accessibility: Voice narration & 10 Indian languages.",
    "End-to-End Lifecycle: Threat detection to post-fraud 1930 recovery.",
    "Self-Learning Intelligence: ThreatMemoryStore keeps Kavach always ahead."
], title_color=C_ACCENT_CYAN)

add_card(slide9, Inches(6.8), Inches(1.7), Inches(5.7), Inches(5.2), "🧪 Live Demo Scenarios Ready for Panel", [
    "1. Digital Arrest Scam: Fake CBI/Police video warrant interception.",
    "2. Electricity Disconnection: Fake officer contact with APK download link.",
    "3. Work-From-Home Task: YouTube like & Google Maps review scam.",
    "4. Bank KYC Phishing: Suspicious link claiming account suspension.",
    "5. Genuine Bank Debit Alert: Demonstrates ZERO false positives."
], title_color=C_ACCENT_GREEN)

output_path = "/home/user/digital_kavach/Digital_Kavach_Final_Presentation.pptx"
prs.save(output_path)
print(f"PPT successfully created at {output_path}")
