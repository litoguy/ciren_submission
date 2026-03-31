import { Router } from 'express';
const router = Router();

const topics = [
  {
    id: 'fees',
    label: 'Fees & Payments',
    icon: '💰',
    prompt: 'What are the tuition fees for this academic year?',
  },
  {
    id: 'exams',
    label: 'Exam Dates',
    icon: '📅',
    prompt: 'When are the upcoming examinations?',
  },
  {
    id: 'registration',
    label: 'Registration',
    icon: '📝',
    prompt: 'How do I register for courses this semester?',
  },
  {
    id: 'facilities',
    label: 'Campus Facilities',
    icon: '🏛️',
    prompt: 'What facilities are available on the Miotso campus?',
  },
  {
    id: 'handbook',
    label: 'Student Handbook',
    icon: '📖',
    prompt: 'Where can I find the student handbook?',
  },
  {
    id: 'contacts',
    label: 'Key Contacts',
    icon: '📞',
    prompt: 'What are the key office contacts at Central University?',
  },
  {
    id: 'admissions',
    label: 'Admissions',
    icon: '🎓',
    prompt: 'What are the admission requirements for Central University?',
  },
  {
    id: 'hostels',
    label: 'Accommodation',
    icon: '🏠',
    prompt: 'Tell me about hostels and accommodation at Central University.',
  },
];

const faqs = [
  { id: 1, question: 'How much are Level 200 Engineering fees?' },
  { id: 2, question: 'When does second semester registration close?' },
  { id: 3, question: 'Where is the library and what are its hours?' },
  { id: 4, question: 'How do I check my admission status?' },
  { id: 5, question: 'What is the GPA grading scale at Central University?' },
  { id: 6, question: 'How do I apply for a resit examination?' },
  { id: 7, question: 'Where is the Finance Office?' },
  { id: 8, question: 'What Mobile Money options are accepted for fees?' },
  { id: 9, question: 'How do I access the student portal?' },
  { id: 10, question: 'What clubs and societies are available?' },
];

// GET /api/topics
router.get('/topics', (req, res) => {
  res.json({ success: true, data: { topics } });
});

// GET /api/faqs
router.get('/faqs', (req, res) => {
  res.json({ success: true, data: { faqs } });
});

export { router as topicsRouter };
