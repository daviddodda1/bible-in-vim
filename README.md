# Bible

![Bible reading Neovim demo](bible-reading-demo-keys.gif)

## Neovim shortcuts

Project-local shortcuts from `.nvim.lua`:

| Shortcut | Action |
| --- | --- |
| `<C-p>` | Find Bible files, including gitignored files |
| `]C` | Next chapter |
| `[C` | Previous chapter |
| `]v` | Next verse |
| `[v` | Previous verse |
| `<leader>zr` | Toggle reading mode |
| `<leader>zj` | Jump/pick Bible chapter |
| `<leader>zs` | Search Bible text |
| `<leader>zw` | Search word under cursor |
| `<leader>zy` | Copy current verse with reference |
| `<leader>zN` | Open chapter notes |
| `<leader>zn` | Open verse note |
| `<leader>zh` | Show footnotes |
| `<leader>zt` | Show current verse in other translations |

`<leader>` is Space in this Neovim config. To auto-load `.nvim.lua`, Neovim needs `set exrc secure` enabled; if prompted, run `:trust` once.

Berean Standard Bible (BSB), generated as local Markdown for terminal/Vim reading.

Run:

```bash
node seed-bible.js
```

Search:

```bash
rg "God so loved" .
```

## Books

- [Genesis](01-genesis/) — 50 chapters
- [Exodus](02-exodus/) — 40 chapters
- [Leviticus](03-leviticus/) — 27 chapters
- [Numbers](04-numbers/) — 36 chapters
- [Deuteronomy](05-deuteronomy/) — 34 chapters
- [Joshua](06-joshua/) — 24 chapters
- [Judges](07-judges/) — 21 chapters
- [Ruth](08-ruth/) — 4 chapters
- [1 Samuel](09-1-samuel/) — 31 chapters
- [2 Samuel](10-2-samuel/) — 24 chapters
- [1 Kings](11-1-kings/) — 22 chapters
- [2 Kings](12-2-kings/) — 25 chapters
- [1 Chronicles](13-1-chronicles/) — 29 chapters
- [2 Chronicles](14-2-chronicles/) — 36 chapters
- [Ezra](15-ezra/) — 10 chapters
- [Nehemiah](16-nehemiah/) — 13 chapters
- [Esther](17-esther/) — 10 chapters
- [Job](18-job/) — 42 chapters
- [Psalms](19-psalms/) — 150 chapters
- [Proverbs](20-proverbs/) — 31 chapters
- [Ecclesiastes](21-ecclesiastes/) — 12 chapters
- [Song of Solomon](22-song-of-solomon/) — 8 chapters
- [Isaiah](23-isaiah/) — 66 chapters
- [Jeremiah](24-jeremiah/) — 52 chapters
- [Lamentations](25-lamentations/) — 5 chapters
- [Ezekiel](26-ezekiel/) — 48 chapters
- [Daniel](27-daniel/) — 12 chapters
- [Hosea](28-hosea/) — 14 chapters
- [Joel](29-joel/) — 3 chapters
- [Amos](30-amos/) — 9 chapters
- [Obadiah](31-obadiah/) — 1 chapters
- [Jonah](32-jonah/) — 4 chapters
- [Micah](33-micah/) — 7 chapters
- [Nahum](34-nahum/) — 3 chapters
- [Habakkuk](35-habakkuk/) — 3 chapters
- [Zephaniah](36-zephaniah/) — 3 chapters
- [Haggai](37-haggai/) — 2 chapters
- [Zechariah](38-zechariah/) — 14 chapters
- [Malachi](39-malachi/) — 4 chapters
- [Matthew](40-matthew/) — 28 chapters
- [Mark](41-mark/) — 16 chapters
- [Luke](42-luke/) — 24 chapters
- [John](43-john/) — 21 chapters
- [Acts](44-acts/) — 28 chapters
- [Romans](45-romans/) — 16 chapters
- [1 Corinthians](46-1-corinthians/) — 16 chapters
- [2 Corinthians](47-2-corinthians/) — 13 chapters
- [Galatians](48-galatians/) — 6 chapters
- [Ephesians](49-ephesians/) — 6 chapters
- [Philippians](50-philippians/) — 4 chapters
- [Colossians](51-colossians/) — 4 chapters
- [1 Thessalonians](52-1-thessalonians/) — 5 chapters
- [2 Thessalonians](53-2-thessalonians/) — 3 chapters
- [1 Timothy](54-1-timothy/) — 6 chapters
- [2 Timothy](55-2-timothy/) — 4 chapters
- [Titus](56-titus/) — 3 chapters
- [Philemon](57-philemon/) — 1 chapters
- [Hebrews](58-hebrews/) — 13 chapters
- [James](59-james/) — 5 chapters
- [1 Peter](60-1-peter/) — 5 chapters
- [2 Peter](61-2-peter/) — 3 chapters
- [1 John](62-1-john/) — 5 chapters
- [2 John](63-2-john/) — 1 chapters
- [3 John](64-3-john/) — 1 chapters
- [Jude](65-jude/) — 1 chapters
- [Revelation](66-revelation/) — 22 chapters

## Source

Text downloaded from https://bereanbible.com/bsb.txt.
The BSB source file states that the text has been dedicated to the public domain.
