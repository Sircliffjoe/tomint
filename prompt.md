# PRODUCTION IMPLEMENTATION PROMPT: TOM ASK

You are a senior Ruby on Rails architect, product engineer, UX designer, security engineer and safeguarding-aware systems designer.

You are working on the existing **TOM International website/application**.

Your task is to **design, implement, test and integrate a production-ready TOM ASK system directly into the existing TOM website**.

Do NOT create a separate application.

Do NOT create a standalone Node.js backend.

Do NOT use Tally, Slido, Mentimeter, Google Forms or Microsoft Forms as the production backend.

Those products may be studied for UX inspiration, but TOM must own the data, workflows, moderation system and user experience.

The result must feel like a native part of the existing TOM website.

---

# 1. PRODUCT NAME

## TOM ASK

### Tagline

**You can ask. We will listen.**

TOM ASK is TOM International's anonymous teen engagement, Q&A and support platform.

It allows teenagers to:

* Ask questions anonymously.
* Talk about things bothering them.
* Request a private response.
* Ask someone to listen.
* Request help.
* Participate anonymously in live TOM Q&A sessions.
* Read approved answers to previously submitted questions.

The system must also provide TOM staff with a controlled moderation, response, escalation and safeguarding workflow.

---

# 2. IMPORTANT PRODUCT PRINCIPLE

Do not treat TOM ASK as merely an anonymous question form.

The system must distinguish between:

### A. General Questions

Example:

> "Why does God allow bad things to happen?"

These may be answered publicly.

### B. Personal Concerns

Example:

> "I'm having problems with my parents."

These may require a private response.

### C. Safeguarding Disclosures

Example:

> "Someone in my church is touching me."

These must NEVER enter the normal public Q&A workflow.

They must be restricted to authorised safeguarding personnel.

### D. Urgent Concerns

Example:

> "I am currently in danger."

These require immediate escalation according to TOM's safeguarding procedures.

The system architecture must support these distinctions from the beginning.

---

# 3. FIRST TASK: INSPECT THE EXISTING APPLICATION

Before writing code, thoroughly inspect the existing TOM website.

Determine:

* Rails version.
* Ruby version.
* Database.
* Authentication system.
* Existing user/admin roles.
* Existing authorization system.
* Existing UI framework.
* Tailwind configuration.
* Hotwire/Turbo/Stimulus configuration.
* Existing JavaScript architecture.
* Existing component system.
* Existing navigation.
* Existing admin dashboard.
* Existing notification system.
* Existing background-job system.
* Existing file-upload system.
* Existing analytics.
* Existing event/camp models.
* Existing user/member models.
* Existing CMS/content models.
* Existing deployment configuration.
* Existing testing framework.
* Existing security mechanisms.
* Existing design language.

Do not duplicate functionality that already exists.

Reuse existing architecture and conventions wherever possible.

Do not introduce a new framework merely because it is convenient.

If the application already has a suitable abstraction for users, roles, events, notifications, etc., extend it rather than creating parallel systems.

---

# 4. ARCHITECTURAL REQUIREMENT

Implement TOM ASK as a modular domain inside the existing Rails monolith.

Prefer a structure such as:

```text
TOM ASK
├── Questions
├── Categories
├── Responses
├── Moderation
├── Assignments
├── Escalations
├── Safeguarding
├── Live Sessions
├── Voting
├── Public Library
├── Notifications
└── Analytics
```

Follow the existing project's architectural conventions.

Do not blindly create the exact class/module names below if the existing codebase has a better convention.

---

# 5. CORE DATA MODEL

Design a proper relational data model.

At minimum, support concepts equivalent to:

## AskQuestion

Fields should include appropriate equivalents of:

* id
* public_reference
* anonymous_identifier
* question/body
* category
* submission_type
* response_preference
* visibility
* status
* priority
* safeguarding_flag
* urgent_flag
* live_session_id
* submitted_at
* reviewed_at
* answered_at
* closed_at
* optional contact information
* metadata required for abuse prevention
* timestamps

Do NOT store unnecessary personally identifiable information.

---

## AskCategory

Support configurable categories such as:

* Faith & God
* Family
* Friendship
* School
* Relationships & Dating
* Body & Growing Up
* Emotions
* Peer Pressure
* Identity & Purpose
* Something Happened
* Something Else

Administrators must be able to manage categories.

---

## AskResponse

Support:

* question
* responder
* response body
* response type
* public/private visibility
* draft status
* published status
* sent_at
* timestamps

---

## AskAssignment

Support assigning questions/cases to authorised TOM team members.

Track:

* assignee
* assigned_by
* assigned_at
* completed_at
* reassignment history

---

## AskInternalNote

Internal notes must NEVER be visible to teenagers.

Track:

* author
* content
* question/case
* timestamps

---

## AskModerationAction

Create an audit trail for moderation actions.

Examples:

* approved
* rejected
* edited
* categorised
* flagged
* assigned
* escalated
* published
* unpublished
* closed

Track who performed each action and when.

---

## AskEscalation

Support escalation workflows.

Fields/concepts:

* escalation type
* severity
* reason
* assigned safeguarding lead
* status
* internal notes
* created_at
* resolved_at

---

## AskLiveSession

Support live Q&A events.

Fields/concepts:

* title
* description
* event association
* start_at
* end_at
* status
* public access token/slug
* anonymous mode
* moderation required
* voting enabled
* display mode
* moderators
* timestamps

---

## AskVote

Allow participants to upvote live questions.

Important:

Prevent one participant/device/session from abusing voting.

Do not require a teenager to create an account merely to vote.

---

# 6. ANONYMITY

Anonymity is a core product requirement.

Teenagers should NOT be required to:

* Create an account.
* Enter their name.
* Enter their email.
* Enter a phone number.

A teenager may voluntarily provide contact information if they request a private response.

Make this distinction extremely clear:

### Anonymous

The teenager does not provide identifying information.

### Private

The teenager may voluntarily provide a contact method and the information is accessible only to authorised TOM personnel.

Never promise absolute confidentiality where safeguarding obligations may require escalation.

---

# 7. PUBLIC TEEN EXPERIENCE

Create a polished TOM-branded page:

```text
/ask
```

The experience should begin with:

# TOM ASK

### You can ask. We will listen.

Supporting copy:

> You don't need to have the right words.
>
> Ask us about something you're struggling with, something you don't understand, or something that's bothering you.
>
> You can remain anonymous.

Provide two primary actions:

### ASK A QUESTION

### I NEED HELP

If there is currently an active live session, also display:

### JOIN LIVE Q&A

---

# 8. QUESTION SUBMISSION FLOW

The flow should be short, mobile-first and teen-friendly.

Do not make it feel like a corporate survey.

Suggested flow:

## Step 1

### What's bothering you?

Large text area.

Allow enough space for a teenager to explain themselves.

---

## Step 2

### What is this about?

Display selectable categories.

Use accessible cards/buttons rather than an ugly default select if consistent with the existing design system.

---

## Step 3

### What would you like TOM to do?

Options:

* Answer my question.
* Respond to me privately.
* I just need someone to listen.
* I need help.

---

## Step 4

Conditional behaviour.

If "Respond privately" is selected:

Ask optionally:

> How can TOM contact you?

Options:

* WhatsApp
* Email
* Other safe contact method

No contact information should ever be mandatory.

---

# 9. SAFEGUARDING BRANCH

If the submission appears to indicate:

* abuse
* sexual abuse
* exploitation
* harassment
* violence
* threats
* self-harm
* suicide
* immediate danger
* serious safety concerns
* another person being harmed

the question must NOT be treated as an ordinary Q&A.

The system should:

1. Mark the submission as potentially sensitive.
2. Prevent automatic public publication.
3. Restrict access.
4. Notify authorised personnel according to the configured safeguarding workflow.
5. Create an escalation/case record where appropriate.
6. Preserve an audit trail.

IMPORTANT:

AI may assist with flagging.

AI must NOT make the final safeguarding decision.

A human authorised TOM safeguarding person must review the matter.

Do not invent safeguarding policies or legal procedures. Build configurable infrastructure that TOM can adapt to its formally approved safeguarding policy.

---

# 10. PRIVACY NOTICE

Before submission, show a concise explanation.

Suggested concept:

> **Your privacy matters to us.**
>
> You don't have to provide your name or contact information to ask a question.
>
> However, if you tell us that you or someone else may be in serious danger, TOM may need to take appropriate steps to help protect you or someone else.

Ensure the final wording can be edited from the admin system.

---

# 11. MODERATION SYSTEM

Create a dedicated TOM ASK moderation dashboard.

The moderator should see:

```text
TOM ASK
──────────────────────────────

New                 12
Under Review         7
Awaiting Response    5
Follow-up            3
Safeguarding        2
Urgent              1
Answered           124
Closed              87
```

Provide filters for:

* Status
* Category
* Priority
* Submission type
* Live session
* Date
* Assigned responder
* Safeguarding status

---

# 12. QUESTION DETAIL PAGE

When a moderator opens a submission, show:

* Question
* Category
* Submission type
* Response preference
* Submission date/time
* Anonymous status
* Contact information if voluntarily supplied
* Moderation status
* Assigned responder
* Priority
* Safeguarding flag
* Internal notes
* Response history
* Moderation history
* Escalation information where authorised

Do not expose sensitive information to users who lack permission.

---

# 13. QUESTION STATUSES

Support a structured lifecycle.

### Intake

* New

### Moderation

* Under Review

### Response

* Awaiting Response
* Response Drafted
* Answered

### Follow-up

* Follow-up Required
* Private Conversation

### Safeguarding

* Safeguarding Review
* Safeguarding Escalated
* Urgent

### Completion

* Resolved
* Closed

Make statuses configurable only where appropriate, but maintain a controlled state machine so invalid transitions cannot occur.

---

# 14. ROLE-BASED ACCESS CONTROL

Do NOT give every TOM administrator access to every question.

Support roles equivalent to:

## Super Admin

Full access.

## TOM ASK Moderator

Can:

* Review questions
* Categorise
* Approve/reject
* Assign
* Moderate
* Add notes

## TOM ASK Responder

Can access questions assigned to them.

## Event Moderator

Can manage live Q&A sessions.

## Safeguarding Lead

Can access safeguarding cases.

## Analytics Viewer

Can access aggregated statistics without exposing sensitive submissions.

Use the application's existing authorization framework if available.

---

# 15. PUBLIC Q&A LIBRARY

Create:

```text
/ask/questions
```

or an equivalent route.

Show only approved public questions.

Features:

* Search
* Category filters
* Pagination
* Related questions
* Featured questions
* Recently answered
* Popular questions

Example:

> **How do I know God's will for my life?**

TOM's approved response appears underneath.

Do not publish:

* private submissions
* safeguarding submissions
* identifying information
* contact information
* internal notes

---

# 16. PUBLICATION WORKFLOW

A question must NEVER become public automatically merely because it was submitted.

Use:

```text
Submitted
    ↓
Moderated
    ↓
Approved for Public
    ↓
Response Prepared
    ↓
Response Approved
    ↓
Published
```

Allow moderators to edit/anonymise content before publication.

The system should make it easy to remove:

* names
* phone numbers
* school names
* addresses
* identifiable third-party information

---

# 17. TOM ASK LIVE

Build a second operating mode:

# TOM ASK LIVE

This is the real-time Q&A system.

It should work for:

* TOM camps
* conferences
* workshops
* Bible studies
* seminars
* youth meetings
* online events

A session moderator creates a live session.

Example:

```text
TOM Camp Warri 2026
→ Friday Night
→ Ask Anything
```

The system generates a public session URL and QR code.

---

# 18. LIVE PARTICIPANT EXPERIENCE

A participant visits something like:

```text
/ask/live/:session
```

They see:

# TOM ASK LIVE

### Ask anything.

> Your name is not required.

Text box:

> Type your question...

Optional:

### Submit anonymously

Then submit.

Do not require account creation.

---

# 19. LIVE MODERATION

Questions must enter:

```text
PENDING
```

before becoming publicly visible.

Moderator dashboard:

```text
TOM ASK LIVE

Session: Ask Anything

Participants: 204
Questions: 87
Pending: 19
Approved: 54
Rejected: 14

────────────────────

Why does God allow suffering?
▲ 84

How do I know my purpose?
▲ 71

Is dating wrong at my age?
▲ 53

[sensitive question]
⚠ FLAGGED
```

Moderator actions:

* Approve
* Reject
* Edit
* Flag
* Categorise
* Hide
* Pin
* Archive

---

# 20. LIVE DISPLAY

Create a dedicated presentation/display mode.

Example:

```text
/ask/live/:session/display
```

It should be designed for:

* Projectors
* TVs
* Large screens
* Zoom/Google Meet screen sharing

Display:

# TOM ASK LIVE

> **QUESTION**
>
> How do I know what God wants me to do with my life?
>
> — Anonymous

Allow moderator to:

* Show next question
* Pin question
* Hide question
* Move to answered
* Display category
* Display vote count if desired

The display must NOT expose sensitive/private questions.

---

# 21. REAL-TIME UPDATES

Use the existing Rails real-time capabilities.

Prefer:

* Hotwire
* Turbo Streams
* Action Cable

or the existing real-time technology if the application already has one.

When a teenager submits a question:

```text
Teenager
   ↓
Rails
   ↓
Database
   ↓
Turbo Stream
   ↓
Moderator dashboard
```

When moderator approves:

```text
Moderator
   ↓
Rails
   ↓
Turbo Stream
   ↓
Live display
```

Do not introduce a separate real-time backend unless absolutely necessary.

---

# 22. LIVE VOTING

Allow anonymous participants to upvote questions.

Example:

```text
How do I know my purpose?
▲ 84
```

Prevent abuse.

Possible mechanisms:

* Session token
* Secure cookie
* Rate limiting
* Server-side vote validation
* Duplicate vote prevention

Do not require account creation merely to vote.

---

# 23. SESSION MANAGEMENT

Admins/moderators should be able to:

* Create session
* Edit session
* Start session
* Pause session
* End session
* Reopen session if authorised
* Assign moderators
* Enable/disable voting
* Enable/disable anonymous submissions
* Configure moderation
* Generate QR code
* Copy participant URL
* Open presentation mode

A session should have a clear lifecycle.

---

# 24. QR CODE

Every live session should have a generated QR code.

Provide:

### Download QR Code

and:

### Display QR Code

The QR should lead directly to the live session.

Use a secure, non-guessable public session identifier.

---

# 25. SPAM AND ABUSE PROTECTION

Because the system allows anonymous submissions, abuse prevention is mandatory.

Implement:

* Rate limiting
* Submission throttling
* Duplicate submission detection where appropriate
* Spam detection
* Profanity filtering
* Suspicious activity detection
* CAPTCHA/Turnstile when necessary
* Temporary blocking
* Moderator blocking
* Audit logs

Do not make the experience unnecessarily difficult for legitimate teenagers.

Use progressive protection.

---

# 26. AI ASSISTANCE

Design the architecture so AI can be added later.

Potential AI-assisted features:

### Automatic categorisation

Suggest:

> Faith & God

### Sensitive-content flagging

Flag potentially concerning content.

### Duplicate detection

Suggest:

> "This question is similar to an existing TOM ASK question."

### Response assistance

Provide a draft for a human responder.

### Moderation assistance

Highlight potential identifying information.

BUT:

AI must never automatically:

* decide a safeguarding case
* determine that a teenager is safe
* provide an unsupervised safeguarding response
* publish a sensitive question
* contact emergency services
* override a human moderator

AI is an assistant, not the authority.

---

# 27. NOTIFICATIONS

Implement notification infrastructure.

Examples:

### New Question

→ TOM ASK Moderator

### Assigned Question

→ Responder

### Safeguarding Flag

→ Authorised Safeguarding Lead

### Urgent Case

→ Configured urgent notification mechanism

### Response Required

→ Assigned responder

Start with email if that is what the existing system supports.

Architect the system so additional channels can be added later.

---

# 28. ANALYTICS

Create a TOM ASK analytics dashboard.

Show aggregated metrics:

* Total questions
* Questions by category
* Questions by month
* Questions answered
* Average response time
* Private response requests
* Follow-up requests
* Live sessions
* Live questions
* Most upvoted questions
* Most common topics
* Safeguarding flags
* Urgent submissions

Do NOT expose sensitive individual data in general analytics.

---

# 29. SECURITY

Treat this as a sensitive system.

Implement:

* Authorization on every protected action
* Strong parameter handling
* CSRF protection
* Rate limiting
* Secure session handling
* Audit logging
* Access logging where appropriate
* Secure contact-information storage
* No sensitive information in URLs
* No sensitive information in notification subjects
* No sensitive information in analytics
* No sensitive information in browser/local storage unless necessary
* Secure public identifiers
* Protection against enumeration
* Protection against mass assignment
* Protection against IDOR
* Proper XSS sanitisation
* Safe HTML rendering
* Secure file upload handling if files are eventually supported

Do not expose database IDs publicly where avoidable.

---

# 30. DATA RETENTION

Do not arbitrarily delete or retain sensitive information.

Build configurable retention policies.

Different classes of data may require different retention:

* Anonymous general questions
* Published questions
* Private conversations
* Safeguarding cases
* Audit logs

Make retention configurable and document the assumptions.

Do not invent legal requirements.

Where the existing TOM organisation has a safeguarding/privacy policy, align the implementation with it.

---

# 31. ACCESSIBILITY

The teen-facing experience must be accessible.

Support:

* Keyboard navigation
* Screen readers
* Proper labels
* Good contrast
* Large touch targets
* Focus states
* Accessible form errors
* Reduced-motion preferences
* Responsive layouts

Do not rely solely on colour to communicate status.

---

# 32. MOBILE-FIRST DESIGN

Assume most teenagers will use:

* Android phones
* Mobile Chrome
* Affordable devices
* Mobile data
* Variable network quality

The public experience must therefore:

* Load quickly.
* Minimise JavaScript.
* Work well on narrow screens.
* Avoid unnecessarily large images.
* Have obvious CTAs.
* Recover gracefully from connection problems.
* Avoid requiring app installation.

---

# 33. NETWORK RESILIENCE

For live sessions especially, design for imperfect Nigerian mobile networks.

Participant submission should:

* Clearly show submitting state.
* Prevent accidental duplicate submissions.
* Confirm successful submission.
* Handle network failure gracefully.
* Allow retry.

Moderator screens should gracefully reconnect if the real-time connection drops.

---

# 34. CONTENT MANAGEMENT

Administrators should be able to configure:

* Introductory text
* Privacy notice
* Categories
* Response options
* Safeguarding warning
* Help text
* Public library settings
* Featured questions
* Session settings

Do not hard-code every piece of user-facing copy.

---

# 35. ADMIN UX

Follow the existing TOM admin design.

Do not create a completely different visual language.

Use existing:

* Navigation
* Buttons
* Cards
* Tables
* Modals
* Alerts
* Form components
* Typography
* Colours
* Icons

If a design system does not exist, establish reusable components rather than styling each screen independently.

---

# 36. ROUTES

Use clean, human-readable routes.

Potential examples:

```text
/ask
/ask/questions
/ask/questions/:slug
/ask/live
/ask/live/:slug
/ask/live/:slug/display
```

Admin routes should follow the existing admin convention, e.g.:

```text
/admin/ask
/admin/ask/questions
/admin/ask/live
/admin/ask/categories
/admin/ask/escalations
/admin/ask/analytics
```

Adapt these to the existing application's routing conventions.

---

# 37. TESTING

Do not consider the feature complete without tests.

Implement:

### Model tests

* Validations
* Associations
* State transitions
* Permissions

### Request/controller tests

Test:

* Anonymous submission
* Private response flow
* Public publication
* Moderation
* Escalation
* Authorization

### System tests

Test the actual teenager journey:

```text
Open TOM ASK
→ Submit anonymous question
→ Confirmation
```

Test:

```text
Question
→ Moderator
→ Assign responder
→ Draft response
→ Approve
→ Publish
```

Test:

```text
Sensitive submission
→ Flag
→ Restrict
→ Safeguarding workflow
```

Test live flow:

```text
Create session
→ Participant joins
→ Submit question
→ Moderator sees question
→ Approves
→ Display receives question
→ Participant votes
```

### Security tests

Test for:

* IDOR
* Unauthorized access
* Role escalation
* XSS
* CSRF
* Rate limiting
* Enumeration
* Unauthorized safeguarding access

---

# 38. SEED DATA

Create appropriate development/test seed data.

Include:

* Categories
* Example questions
* Example responses
* Example live session
* Test moderator
* Test responder
* Test safeguarding lead

Clearly mark seed/demo data.

Never seed fake real-world safeguarding cases.

---

# 39. OBSERVABILITY

Add appropriate logging and monitoring.

Track system events such as:

* Submission failures
* Notification failures
* Real-time connection failures
* Moderation errors
* Authorization failures
* Background-job failures

Do not log the full contents of sensitive questions unnecessarily.

Never put sensitive question content into ordinary application logs.

---

# 40. PERFORMANCE

The system should comfortably support TOM events with several hundred simultaneous teenagers.

Optimise:

* Database indexes
* Live session queries
* Vote counting
* Moderator queue
* Turbo Stream broadcasts
* Pagination
* Search
* Analytics queries

Do not calculate expensive analytics synchronously on every request.

Use background jobs/caching where appropriate.

---

# 41. PRODUCTION DEPLOYMENT

Do not assume a new server/application is required.

Integrate with the existing TOM deployment.

Before deployment:

* Run migrations safely.
* Run the complete test suite.
* Check environment variables.
* Check background jobs.
* Check Action Cable configuration.
* Check production asset handling.
* Check email delivery.
* Check HTTPS.
* Check database indexes.
* Check authorization.
* Check logs.
* Check rollback procedure.

Do not make destructive database changes without explicit approval.

---

# 42. IMPLEMENTATION PROCESS

Follow this sequence.

## Phase 1 — Discovery

Inspect the existing TOM application thoroughly.

Produce a short architecture assessment before modifying code.

Identify:

* Existing architecture
* Existing models
* Existing authentication
* Existing authorization
* Existing design system
* Existing event infrastructure
* Existing notification system
* Existing background jobs
* Existing deployment

---

## Phase 2 — Technical Design

Create:

* Domain model
* Database schema
* State transitions
* Authorization matrix
* Routing design
* UI flow
* Real-time architecture
* Notification architecture

Do not start blindly coding.

---

## Phase 3 — Core TOM ASK

Implement:

* Public landing page
* Anonymous submission
* Categories
* Response preferences
* Optional contact information
* Moderation
* Assignment
* Responses
* Status workflow
* Public Q&A library
* Notifications
* Audit trail

---

## Phase 4 — TOM ASK LIVE

Implement:

* Sessions
* Participant interface
* QR codes
* Live submission
* Moderation queue
* Real-time updates
* Presentation display
* Voting
* Session management

---

## Phase 5 — Safeguarding

Implement the restricted workflow.

Ensure:

* Sensitive cases cannot accidentally become public.
* Only authorised personnel can access them.
* Actions are audited.
* Notifications are controlled.
* Escalation is explicit.

---

## Phase 6 — Testing

Run:

* Unit tests
* Integration tests
* System tests
* Authorization tests
* Security tests
* Performance checks

Fix all failures.

---

## Phase 7 — UX Polish

Review every screen on:

* Desktop
* Tablet
* Mobile
* Small Android screen

Make the experience feel like a polished TOM product rather than an admin CRUD interface.

---

# 43. IMPORTANT IMPLEMENTATION RULES

### Rule 1

Do not create a separate application.

### Rule 2

Do not replace existing architecture unnecessarily.

### Rule 3

Do not introduce unnecessary dependencies.

### Rule 4

Reuse existing TOM authentication, authorization, UI and infrastructure.

### Rule 5

Do not expose anonymous submitters unnecessarily.

### Rule 6

Never automatically publish submissions.

### Rule 7

Never expose safeguarding submissions to ordinary moderators.

### Rule 8

Never allow AI to make final safeguarding decisions.

### Rule 9

Do not put sensitive question content into logs or notifications unnecessarily.

### Rule 10

Do not compromise the existing TOM website while implementing this feature.

---

# 44. DEFINITION OF DONE

TOM ASK is complete only when a teenager can:

1. Visit TOM's website.
2. Open TOM ASK.
3. Understand that they can remain anonymous.
4. Submit a question without creating an account.
5. Select what the question is about.
6. Choose what kind of response they want.
7. Optionally provide contact information.
8. Receive confirmation.
9. Have their question safely enter moderation.
10. Receive an appropriate response where applicable.

And TOM staff can:

1. Review submissions.
2. Categorise them.
3. Assign responders.
4. Draft responses.
5. Approve responses.
6. Publish appropriate answers.
7. Handle private requests.
8. Escalate sensitive cases.
9. Restrict safeguarding information.
10. Maintain an audit trail.
11. Run live Q&A sessions.
12. Moderate questions in real time.
13. Display approved questions.
14. Allow anonymous voting.
15. Review analytics.

---

# 45. FINAL PRODUCT VISION

The finished TOM website should effectively provide:

```text
                    TOM ASK
              You can ask.
             We will listen.
                    │
        ┌───────────┴───────────┐
        │                       │
     ASK ANYTIME             ASK LIVE
        │                       │
 Anonymous Questions       Live Q&A Sessions
        │                       │
        └───────────┬───────────┘
                    │
              TOM MODERATION
                    │
       ┌────────────┼────────────┐
       │            │            │
     Answer       Support    Safeguard
       │            │            │
       └────────────┼────────────┘
                    │
             TOM RESPONSE
                    │
              PUBLIC LIBRARY
```

The long-term vision is for TOM ASK to become a trusted digital doorway through which teenagers can ask questions, express concerns, participate in TOM programmes and connect with appropriate TOM support.

Build this as a **production system**, not an MVP or proof of concept.

Before changing code, inspect the existing application and explain the implementation approach based on what is actually present in the repository. Then implement the system incrementally, testing each major component as you go.

Do not stop at scaffolding. Complete the integration, UI, backend, authorization, database, real-time functionality, tests and production readiness.
