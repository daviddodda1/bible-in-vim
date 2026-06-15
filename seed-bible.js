#!/usr/bin/env node

// Seed a Vim-friendly local Markdown Bible from the Berean Standard Bible text file.
// Source: https://bereanbible.com/bsb.txt
// The source text states: "This text of God's Word has been dedicated to the public domain."

const fs = require('node:fs/promises');
const path = require('node:path');

const SOURCE_URL = 'https://bereanbible.com/bsb.txt';
const ROOT = __dirname;

const BOOKS = [
  'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy', 'Joshua', 'Judges', 'Ruth',
  '1 Samuel', '2 Samuel', '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles', 'Ezra', 'Nehemiah',
  'Esther', 'Job', 'Psalms', 'Proverbs', 'Ecclesiastes', 'Song of Solomon', 'Isaiah', 'Jeremiah',
  'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Joel', 'Amos', 'Obadiah', 'Jonah', 'Micah',
  'Nahum', 'Habakkuk', 'Zephaniah', 'Haggai', 'Zechariah', 'Malachi', 'Matthew', 'Mark', 'Luke',
  'John', 'Acts', 'Romans', '1 Corinthians', '2 Corinthians', 'Galatians', 'Ephesians', 'Philippians',
  'Colossians', '1 Thessalonians', '2 Thessalonians', '1 Timothy', '2 Timothy', 'Titus', 'Philemon',
  'Hebrews', 'James', '1 Peter', '2 Peter', '1 John', '2 John', '3 John', 'Jude', 'Revelation'
];

const SOURCE_BOOK_NAMES = new Map([
  ['Psalm', 'Psalms']
]);

const args = new Set(process.argv.slice(2));
const force = args.has('--force');

function pad(n, width = 2) {
  return String(n).padStart(width, '0');
}

function slugify(book) {
  return book.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

function folderName(book) {
  return `${pad(BOOKS.indexOf(book) + 1)}-${slugify(book)}`;
}

function escapeMd(s) {
  return s.replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

async function exists(file) {
  try { await fs.access(file); return true; } catch { return false; }
}

async function downloadSource() {
  const cacheDir = path.join(ROOT, '.cache');
  const cacheFile = path.join(cacheDir, 'bsb.txt');
  await fs.mkdir(cacheDir, { recursive: true });

  if (!force && await exists(cacheFile)) {
    return fs.readFile(cacheFile, 'utf8');
  }

  console.log(`Downloading ${SOURCE_URL}`);
  const res = await fetch(SOURCE_URL, { headers: { 'user-agent': 'terminal-bible-seeder/1.0' } });
  if (!res.ok) throw new Error(`Failed to download BSB text: HTTP ${res.status}`);
  const text = await res.text();
  await fs.writeFile(cacheFile, text, 'utf8');
  return text;
}

function parseBsb(text) {
  const sourceBookNames = [...BOOKS, ...SOURCE_BOOK_NAMES.keys()];
  const bookPattern = sourceBookNames.map(b => b.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('|');
  const lineRegex = new RegExp(`^(${bookPattern}) (\\d+):(\\d+)\\t(.+)$`);
  const bible = new Map();

  for (const rawLine of text.replace(/^\uFEFF/, '').split(/\r?\n/)) {
    const line = rawLine.trimEnd();
    const match = line.match(lineRegex);
    if (!match) continue;
    const [, sourceBook, chapter, verse, verseText] = match;
    const book = SOURCE_BOOK_NAMES.get(sourceBook) || sourceBook;

    if (!bible.has(book)) bible.set(book, new Map());
    const chapters = bible.get(book);
    const chapterNum = Number(chapter);
    if (!chapters.has(chapterNum)) chapters.set(chapterNum, []);
    chapters.get(chapterNum).push({ verse: Number(verse), text: verseText });
  }

  for (const book of BOOKS) {
    if (!bible.has(book)) throw new Error(`Missing book in source text: ${book}`);
  }

  return bible;
}

async function writeChapter(book, chapterNum, verses) {
  const dir = path.join(ROOT, folderName(book));
  await fs.mkdir(dir, { recursive: true });
  const file = path.join(dir, `${pad(chapterNum, 3)}.md`);

  const lines = [
    `# ${book} ${chapterNum}`,
    '',
    ...verses.flatMap(({ verse, text }) => [`**${verse}** ${escapeMd(text)}`, ''])
  ];

  await fs.writeFile(file, lines.join('\n'), 'utf8');
}

async function writeBookReadme(book, chapters) {
  const dir = path.join(ROOT, folderName(book));
  const lines = [`# ${book}`, '', ...[...chapters.keys()].map(ch => `- [${book} ${ch}](${pad(ch, 3)}.md)`), ''];
  await fs.writeFile(path.join(dir, 'README.md'), lines.join('\n'), 'utf8');
}

async function writeRootReadme(bible) {
  const lines = [
    '# Bible',
    '',
    'Berean Standard Bible (BSB), generated as local Markdown for terminal/Vim reading.',
    '',
    'Run:',
    '',
    '```bash',
    'node seed-bible.js',
    '```',
    '',
    'Search:',
    '',
    '```bash',
    'rg "God so loved" .',
    '```',
    '',
    '## Books',
    ''
  ];

  for (const book of BOOKS) {
    const chapters = bible.get(book);
    lines.push(`- [${book}](${folderName(book)}/) — ${chapters.size} chapters`);
  }

  lines.push('', '## Source', '', `Text downloaded from ${SOURCE_URL}.`, 'The BSB source file states that the text has been dedicated to the public domain.', '');
  await fs.writeFile(path.join(ROOT, 'README.md'), lines.join('\n'), 'utf8');
}

async function main() {
  if (args.has('--help') || args.has('-h')) {
    console.log('Usage: node seed-bible.js [--force]\n\nCreates/updates BSB Markdown files in this folder.');
    return;
  }

  const text = await downloadSource();
  const bible = parseBsb(text);

  let chapterCount = 0;
  let verseCount = 0;
  for (const book of BOOKS) {
    const chapters = bible.get(book);
    for (const [chapterNum, verses] of chapters) {
      await writeChapter(book, chapterNum, verses);
      chapterCount += 1;
      verseCount += verses.length;
    }
    await writeBookReadme(book, chapters);
  }
  await writeRootReadme(bible);

  console.log(`Seeded ${BOOKS.length} books, ${chapterCount} chapters, ${verseCount} verses into ${ROOT}`);
}

main().catch(err => {
  console.error(err.stack || err.message);
  process.exit(1);
});
