Website Redesign Prompt — Teenagers' Outreach Ministries (TOM)

ROLE: You are a senior UI/UX designer and full-stack frontend developer specialising in faith-based, youth-oriented digital experiences.

PROJECT OVERVIEW
Redesign this current website for Teenagers' Outreach Ministries (TOM) — a Christian ministry dedicated to reaching, discipling, and empowering teenagers. The redesign must retain all existing content (text and images) while elevating the visual experience to be vibrant, modern, and deeply appealing to a teenage audience.

DESIGN SYSTEM
Theme Colour: Maintain current colour. Add complimentary accents where necessary.

Theme Mode: Light (white/off-white backgrounds)

Visual Style: Glassmorphism applied throughout — frosted glass cards, translucent navbars, blurred panel overlays — all tinted with the dark green palette

Typography: Bold, expressive headings (suggest: Poppins or Sora); clean readable body text

Buttons: All buttons must have border-radius: 50px (fully pill-shaped)
Container Width: Max 1100px, centred — never full-bleed text content

Animations & Transitions:
Smooth scroll behaviour
Fade-in + slide-up on scroll (Intersection Observer or AOS.js)
Hover transitions on cards, buttons, nav links (scale, glow, colour shift)
Hero section: animated gradient or subtle particle/wave background
Page load entrance animations
Micro-interactions on form fields and buttons

Teen-Oriented Aesthetic: Energetic, bold, colourful accents against the green base. Use large section imagery, bold typography hierarchies, diagonal section breaks or curved dividers, and dynamic layout grids that feel alive — not corporate.

PAGES TO REDESIGN
These are just descriptive. Keep current content and sections. But you can ADD to them.
Add page header section for each page.

1. 🏠 HOME

- Hero Section: Full-viewport hero with animated background (gradient mesh or subtle moving particles in green tones). Large bold headline + subtext + two CTA buttons ("Join Us" / "Learn More"). Glassmorphic overlay card on the hero image.
- Mission Strip: A full-width colour band with a one-line mission statement in large italic type
- About Snapshot: 3-column glassmorphic cards summarising Who We Are, What We Do, Our Vision
- Featured Events: Horizontal scroll or grid of upcoming event cards with date badges, glassmorphic card style
- Stats Counter Section: Animated number counters (e.g. Years in Ministry, Teens Reached, States Active, Training Graduates) — bold numbers on a dark green background
- Testimonials Carousel: Glassmorphic quote cards with teen photos and names, auto-sliding with dot navigation
- Latest Blog Posts: 3-card grid with category tags, read-time badge, and hover zoom on images
- CTA Banner: Bold section with background image + green overlay + big headline + Donate/Join button
- Footer Preview Strip: Quick links, social icons, newsletter signup

2. 📖 ABOUT

- Page Hero: Full-width banner with page title + breadcrumb, glassmorphic title overlay
- Our Story: Split layout — rich text left, image collage right. Timeline component showing key milestones in TOM's history
- Vision & Mission Cards: Side-by-side glassmorphic cards with icon + bold title + body text
- Core Values: Icon grid (6–8 values) with animated hover glow cards
- Leadership/Team Section: Profile cards with photo, name, role, and subtle social links. Glassmorphic card with green tint on hover
- Affiliations / Partners Strip: Logo row (greyscale → colour on hover)
Volunteer CTA: Full-width section with bold call to serve

3. 📅 EVENTS

- Page Hero: Animated banner with event theme feel
Filter Bar: Pill-shaped filter buttons (All, Upcoming, Past, Camps, Training) — active state in green
- Events Grid: Masonry or 3-col card grid. Each card: event image, date badge (glassmorphic), title, location, short description, "Register" pill button
- Featured/Spotlight Event: Large hero-style card at top for the next major event (e.g. AURA Camp) — full bleed image, glassmorphic detail overlay
- Past Events Gallery Strip: Horizontal scroll of thumbnail images from past events with lightbox on click
- Event Registration Modal: Clicking "Register" opens a smooth animated modal with a simple form

4. 🎓 TRAINING

- Page Hero: Bold, academic-meets-youthful feel
- Programme Overview: Intro text + key highlights in a 3-icon row
- Certificate Course Cards: Card for each course/module — title, description, duration, level badge, "Enrol" button. Glassmorphic card with hover lift
- Curriculum Accordion: Expandable topic list per course with smooth open/close animation
- Trainer Profiles: Compact profile cards — photo, name, subject area
- Testimonials: 2–3 graduate quotes in styled blockquote cards
- Enrolment CTA: Bold section with enrolment form or redirect button

5. 📝 BLOG

- Page Hero: Editorial-style hero with large featured post
- Category Filter: Pill filter tabs (All, Devotionals, News, Events, Tips, Stories)
- Blog Grid: 3-column masonry grid — post thumbnail, category badge, title, excerpt, author avatar + name, read time, "Read More" button
- Featured Post: Large card at top spanning full width — bold image, glassmorphic overlay with post details
- Sidebar (optional on desktop): Recent Posts, Popular Tags, Newsletter signup box
- Pagination / Infinite Scroll

6. 📬 CONTACT

- Page Hero: Friendly, welcoming tone — "We'd love to hear from you"
- Contact Cards Row: 3 glassmorphic cards — 📍 Address, 📞 Phone, 📧 Email — with icon, label, and value. Hover: green glow
- Contact Form: Name, Email, Phone, Subject (dropdown), Message — styled with floating labels, green focus rings, pill-shaped submit button with loading state animation
- Embedded Google Map: Full-width or card-embedded interactive Google Map showing TOM's base — styled with a green map theme if possible
- Social Media Links: Large icon buttons row below the form — Instagram, Facebook, WhatsApp, YouTube
- Office Hours Section: Simple icon + text display of available hours

7. 💚 DONATE

- Page Hero: Emotionally resonant — impactful image of teens + bold headline: "Your Gift Changes a Life"
= Impact Stats: Animated counter cards — e.g. "₦5,000 sponsors a teen for a workshop", "₦20,000 funds a camp slot"
- Giving Tiers: 3–4 glassmorphic tier cards (Seed, Growth, Champion, Partner) — each with a suggested amount, what it funds, and a "Give This Amount" button
- Donation Form: Name, Email, Amount (preset pill buttons + custom input), Payment Method selector, Message field — clean, trustworthy design
- Bank Details Card: Glassmorphic card with Account Name, Bank, Account Number + a copy-to-clipboard button
- Why Give Section: 3-column icon cards — transparency, impact, accountability
- Recurring Giving Toggle: Monthly / One-time toggle on the donation form
- Supporter Wall: Scrolling strip of first names/initials of recent donors (e.g. "Tolu A., Chisom E., David O. just gave...")


GLOBAL COMPONENTS

- Navbar: Sticky, glassmorphic frosted-glass effect, logo left, nav links centre/right, "Donate" as a green pill CTA button. Mobile: hamburger with smooth slide-down menu
- Footer: Dark green background, 4-column layout — Logo + tagline, Quick Links, Contact Info, Newsletter signup. Social icons row. Copyright line.
- Back-to-Top Button: Floating pill button, appears on scroll
- Cookie/Notification Banner: Slim glassmorphic bar at bottom
- Loading Screen: Brief animated logo loader on first visit
- Newsletter popup (or volunteer signup or important news flash)


TECHNICAL REQUIREMENTS

- Glassmorphism: backdrop-filter: blur(), background: rgba(), subtle border: 1px solid rgba(255,255,255,0.2), soft box-shadow
- Animations: AOS.js or custom Intersection Observer; GSAP for hero animations if needed
- Fonts: Google Fonts — Poppins (headings) + Inter or DM Sans (body)
- Icons: Remix Icons or Lucide Icons
- Map: Google Maps Embed API or Leaflet.js
- Responsive: Fully mobile-first responsive across all breakpoints
- Performance: Lazy-load images, minify CSS/JS, optimise for Nigerian mobile network conditions
- Accessibility: ARIA labels, sufficient colour contrast, keyboard navigable


TONE & FEEL

Think: A teenage Bible camp met a modern tech startup. Energetic. Faith-filled. Trustworthy. Bold. Warm. Not stuffy — not childish. Somewhere between a youth magazine and a faith movement.


CONTENT RULES

✅ Keep ALL existing text content verbatim
✅ Keep ALL existing images
✅ You may ADD new placeholder text and stock images for new sections
✅ New images should reflect Nigerian teenage Christian ministry context
❌ Do not remove any existing content
❌ Do not change the ministry name, tagline, or branding copy