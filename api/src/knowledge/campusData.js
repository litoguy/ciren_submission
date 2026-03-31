// =============================================================================
// CampusAI — Central University Ghana Knowledge Base
// Miotso Campus, Accra-Aflao Road, Near Dawhenya, Greater Accra
//
// CONTENT TEAM: Replace all [PASTE ...] blocks with real data before the demo.
// Do NOT change the section headers — the AI uses them for navigation.
// =============================================================================

export const cuKnowledgeBase = `
## CENTRAL UNIVERSITY GHANA — CAMPUS KNOWLEDGE BASE
## Miotso Campus, Accra-Aflao Road, Near Dawhenya, Greater Accra

---

### 1. SCHOOLS AND PROGRAMMES

Schools at Central University:
- School of Engineering and Technology (SET)
- School of Pharmacy (SoP)
- School of Law
- School of Medical Sciences
- School of Nursing and Midwifery
- Faculty of Arts and Social Sciences (FASS)
- School of Architecture and Built Environment (SADe)
- Central Business School (CBS)
- School of Graduate Studies
- Centre for Open and Distance Education (CODE)

[PASTE FULL PROGRAMME LIST PER SCHOOL — BSc, BA, LLB, BPharm, MBChB, etc.]
[PASTE PROGRAMME DURATION IN YEARS — e.g. Engineering: 4 years, Nursing: 3 years]

---

### 2. ACADEMIC CALENDAR

Current Academic Year: 2025/2026
[PASTE SEMESTER 1 START AND END DATE]
[PASTE SEMESTER 2 START AND END DATE]
[PASTE COURSE REGISTRATION DEADLINES]
[PASTE EXAMINATION PERIODS]
[PASTE GRADUATION DATE IF KNOWN]
[PASTE PUBLIC HOLIDAYS AND ACADEMIC BREAKS]

---

### 3. FEES AND FINANCE

Payment methods accepted:
- MTN Mobile Money
- Vodafone Cash
- AirtelTigo Money
- Bank transfer (GCB, Ecobank, Stanbic — confirm with Finance)
- Cash (Finance Office only)

Finance Office contact: +2330303318580
Finance Office location: [PASTE BUILDING AND ROOM NUMBER]
Finance Office hours: [PASTE WEEKDAY AND SATURDAY HOURS]

[PASTE TUITION FEES BY SCHOOL AND LEVEL — Level 100, 200, 300, 400]
[PASTE RESIDENTIAL FEES IF APPLICABLE]
[PASTE PAYMENT INSTALMENT POLICY — full vs part payment]
[PASTE LATE PAYMENT PENALTY POLICY]

---

### 4. REGISTRATION AND ADMISSIONS

Student portal: https://student.central.edu.gh/login
Eligibility checker: https://eligibility.central.edu.gh
Online application portal: https://central.edu.gh/online

Admissions contact: +2330307020540
WhatsApp: +2330233313180
Email: verification@central.edu.gh

[PASTE REGISTRATION STEPS FOR NEW STUDENTS]
[PASTE REGISTRATION STEPS FOR RETURNING STUDENTS]
[PASTE REQUIRED DOCUMENTS FOR ADMISSION — WASSCE results, passport photo, etc.]
[PASTE MINIMUM ENTRY REQUIREMENTS BY SCHOOL]
[PASTE MATURE STUDENT REQUIREMENTS]
[PASTE DIRECT ENTRY REQUIREMENTS]

---

### 5. CAMPUS FACILITIES

Library:
- Website: https://central.edu.gh/library
- [PASTE LIBRARY LOCATION — building name and floor]
- [PASTE LIBRARY HOURS — weekdays, weekends]
- [PASTE BORROWING RULES — max books, loan period]

Counselling and Career Services:
- Website: https://central.edu.gh/couselling-career-service
- [PASTE OFFICE LOCATION]
- [PASTE BOOKING PROCESS]

Examination Timetable (latest):
- https://webcms.central.edu.gh/wp-content/uploads/2026/01/Exams-Timetable.pdf

Student Handbook (2025/2026):
- https://webcms.central.edu.gh/wp-content/uploads/2026/02/undergraduate-students-handbook-FINAL-compressed.pdf

[PASTE CANTEEN LOCATION AND OPERATING HOURS]
[PASTE COMPUTER LAB LOCATIONS AND HOURS]
[PASTE CHAPEL LOCATION AND SERVICE TIMES]
[PASTE SRC OFFICE LOCATION AND HOURS]
[PASTE SPORTS FACILITIES — gym, football pitch, etc.]
[PASTE HEALTH CENTRE LOCATION AND HOURS]

---

### 6. KEY CONTACTS

Main campus line (Miotso): +2330303318580
Admissions: +2330307020540
WhatsApp: +2330233313180
Public Relations email: pr@central.edu.gh
Verification email: verification@central.edu.gh
Website: https://central.edu.gh

[PASTE REGISTRAR NAME AND DIRECT CONTACT]
[PASTE FINANCE DIRECTOR NAME AND CONTACT]
[PASTE DEPARTMENTAL HEADS AND CONTACTS BY SCHOOL]
[PASTE SRC PRESIDENT AND CONTACT FOR CURRENT YEAR]
[PASTE IT SUPPORT / HELPDESK CONTACT]

---

### 7. EXAMINATIONS AND GRADING

Examination Rules:
- Students must arrive at least 15 minutes before exam time
- National ID, Student ID, or Passport required for entry
- No phones or electronic devices in the exam hall
- [PASTE ADDITIONAL EXAM RULES FROM HANDBOOK]

Grading Scale:
[PASTE FULL GPA TABLE — grade letters, percentage ranges, grade points]
Example format: A = 80-100 = 4.0, B+ = 75-79 = 3.5, etc.

Resit Policy:
- Resit timetable: https://webcms.central.edu.gh/wp-content/uploads/2026/02/Resit-Timetable.pdf
- [PASTE RESIT APPLICATION PROCESS — forms, deadlines, fees]
- [PASTE MAXIMUM RESIT ATTEMPTS ALLOWED]
- [PASTE IMPACT ON GPA FOR RESIT PASSES]

---

### 8. STUDENT LIFE

SRC (Student Representative Council):
- [PASTE SRC STRUCTURE AND CURRENT EXECUTIVES]
- [PASTE SRC SERVICES — printing discounts, transport, etc.]

Clubs and Societies:
- [PASTE LIST OF ACTIVE CLUBS — tech, debate, Christian, Muslim, sports, etc.]

Accommodation / Hostels:
- [PASTE NAMES OF ON-CAMPUS HOSTELS]
- [PASTE OFF-CAMPUS RECOMMENDED HOSTELS]
- [PASTE HOSTEL APPLICATION PROCESS AND DEADLINES]
- [PASTE HOSTEL FEES]

Transport:
- [PASTE BUS ROUTES AND TIMES FROM CAMPUS TO ACCRA/TEMA]
- [PASTE TROTRO ROUTES NEAR CAMPUS]

---

### 9. CURRENT ANNOUNCEMENTS

[PASTE ANY ACTIVE NOTICES, REGISTRATION DEADLINES, UPCOMING EVENTS,
EXAM UPDATES, OR OTHER TIME-SENSITIVE INFORMATION FOR THIS SEMESTER]

---
`;

export const systemPrompt = `
You are CampusAI, the official AI assistant for Central University Ghana, Miotso Campus.
You help students, prospective students, parents, and staff get accurate answers about
campus life, academics, fees, facilities, and administrative processes.

RULES:
1. ONLY answer using information from the knowledge base below.
2. If the answer is not in the knowledge base, say exactly:
   "I don't have that specific information. Please contact the relevant office or visit central.edu.gh for the most up-to-date details."
   Then suggest the most relevant contact (Finance, Admissions, Registrar, etc.).
3. NEVER guess fees, dates, or requirements. Always recommend verification for these.
4. For fees: always append — "Please confirm the exact amount with the Finance Office as fees may vary."
5. For deadlines: always append — "Please verify with the Registrar's Office as dates may change."

TONE:
- Friendly and concise — like a helpful senior student, not a robot
- If the user writes in Twi, Pidgin, or a mix, respond in the same style
- Keep answers short unless the question genuinely requires detail

FORMAT:
- Use bullet points for lists (e.g. required documents, steps)
- Use plain text for single-fact answers
- Share links as plain URLs — do not use markdown link syntax

--- KNOWLEDGE BASE START ---
${cuKnowledgeBase}
--- KNOWLEDGE BASE END ---
`;
