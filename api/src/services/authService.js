import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { readFileSync, writeFileSync, existsSync } from 'fs';
import { v4 as uuidv4 } from 'uuid';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const DB_PATH = join(__dirname, '../../data/users.json');

// ---------------------------------------------------------------------------
// File-based user store (hackathon only — replace with PostgreSQL in prod)
// ---------------------------------------------------------------------------

function readUsers() {
  if (!existsSync(DB_PATH)) return [];
  return JSON.parse(readFileSync(DB_PATH, 'utf-8'));
}

function writeUsers(users) {
  writeFileSync(DB_PATH, JSON.stringify(users, null, 2));
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

export async function register({ name, email, password }) {
  const users = readUsers();
  if (users.find(u => u.email === email)) {
    throw Object.assign(new Error('Email already registered'), { status: 409 });
  }
  const hashed = await bcrypt.hash(password, 10);
  const user = {
    id: uuidv4(),
    name,
    email,
    password: hashed,
    createdAt: new Date().toISOString(),
  };
  writeUsers([...users, user]);
  return { id: user.id, name: user.name, email: user.email };
}

export async function login({ email, password }) {
  const users = readUsers();
  const user = users.find(u => u.email === email);
  if (!user || !(await bcrypt.compare(password, user.password))) {
    throw Object.assign(new Error('Invalid email or password'), { status: 401 });
  }
  return signTokens(user);
}

export function signTokens(user) {
  const payload = { id: user.id, email: user.email, name: user.name };
  const accessToken = jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
  const refreshToken = jwt.sign({ id: user.id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d',
  });
  return { accessToken, refreshToken, user: payload };
}

export function verifyRefreshToken(token) {
  return jwt.verify(token, process.env.JWT_SECRET);
}

export function getUserById(id) {
  return readUsers().find(u => u.id === id) || null;
}

export function updateUserName(id, name) {
  const users = readUsers();
  const idx = users.findIndex(u => u.id === id);
  if (idx === -1) throw Object.assign(new Error('User not found'), { status: 404 });
  users[idx].name = name;
  writeUsers(users);
  return { id: users[idx].id, name: users[idx].name, email: users[idx].email };
}
