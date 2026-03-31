import { GoogleGenerativeAI } from '@google/generative-ai';

let _genAI = null;

export function getGenAI() {
  if (!_genAI) {
    if (!process.env.GEMINI_API_KEY) {
      throw new Error('GEMINI_API_KEY not set in environment');
    }
    _genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
  }
  return _genAI;
}
