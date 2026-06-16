-- Project-local Neovim config for this Bible Markdown repository.
-- Neovim may ask you to review/trust this file once: run :trust if you want it enabled.

local source = debug.getinfo(1, "S").source
local root = source:sub(1, 1) == "@" and vim.fn.fnamemodify(source:sub(2), ":p:h") or vim.fn.getcwd()
local notes_dir = root .. "/.notes"

local books = {
  { "Genesis", "01-genesis" }, { "Exodus", "02-exodus" }, { "Leviticus", "03-leviticus" },
  { "Numbers", "04-numbers" }, { "Deuteronomy", "05-deuteronomy" }, { "Joshua", "06-joshua" },
  { "Judges", "07-judges" }, { "Ruth", "08-ruth" }, { "1 Samuel", "09-1-samuel" },
  { "2 Samuel", "10-2-samuel" }, { "1 Kings", "11-1-kings" }, { "2 Kings", "12-2-kings" },
  { "1 Chronicles", "13-1-chronicles" }, { "2 Chronicles", "14-2-chronicles" }, { "Ezra", "15-ezra" },
  { "Nehemiah", "16-nehemiah" }, { "Esther", "17-esther" }, { "Job", "18-job" },
  { "Psalms", "19-psalms" }, { "Proverbs", "20-proverbs" }, { "Ecclesiastes", "21-ecclesiastes" },
  { "Song of Solomon", "22-song-of-solomon" }, { "Isaiah", "23-isaiah" }, { "Jeremiah", "24-jeremiah" },
  { "Lamentations", "25-lamentations" }, { "Ezekiel", "26-ezekiel" }, { "Daniel", "27-daniel" },
  { "Hosea", "28-hosea" }, { "Joel", "29-joel" }, { "Amos", "30-amos" },
  { "Obadiah", "31-obadiah" }, { "Jonah", "32-jonah" }, { "Micah", "33-micah" },
  { "Nahum", "34-nahum" }, { "Habakkuk", "35-habakkuk" }, { "Zephaniah", "36-zephaniah" },
  { "Haggai", "37-haggai" }, { "Zechariah", "38-zechariah" }, { "Malachi", "39-malachi" },
  { "Matthew", "40-matthew" }, { "Mark", "41-mark" }, { "Luke", "42-luke" },
  { "John", "43-john" }, { "Acts", "44-acts" }, { "Romans", "45-romans" },
  { "1 Corinthians", "46-1-corinthians" }, { "2 Corinthians", "47-2-corinthians" }, { "Galatians", "48-galatians" },
  { "Ephesians", "49-ephesians" }, { "Philippians", "50-philippians" }, { "Colossians", "51-colossians" },
  { "1 Thessalonians", "52-1-thessalonians" }, { "2 Thessalonians", "53-2-thessalonians" }, { "1 Timothy", "54-1-timothy" },
  { "2 Timothy", "55-2-timothy" }, { "Titus", "56-titus" }, { "Philemon", "57-philemon" },
  { "Hebrews", "58-hebrews" }, { "James", "59-james" }, { "1 Peter", "60-1-peter" },
  { "2 Peter", "61-2-peter" }, { "1 John", "62-1-john" }, { "2 John", "63-2-john" },
  { "3 John", "64-3-john" }, { "Jude", "65-jude" }, { "Revelation", "66-revelation" },
}

local dir_to_book, dir_to_idx = {}, {}
for i, book in ipairs(books) do
  dir_to_book[book[2]] = book[1]
  dir_to_idx[book[2]] = i
end

local reading = false

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "Bible" })
end

local function map(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
end

local function chapter_path(idx, chapter)
  local book = books[idx]
  if not book then return nil end
  return string.format("%s/%s/%03d.md", root, book[2], chapter)
end

local function verse_under_cursor()
  for line = vim.fn.line("."), 1, -1 do
    local verse = (vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1] or ""):match("^%*%*(%d+)%*%*")
    if verse then return tonumber(verse) end
  end
  return nil
end

local function current_ref()
  if vim.b.bible_ref then
    local ref = vim.tbl_extend("force", {}, vim.b.bible_ref)
    ref.verse = verse_under_cursor()
    return ref
  end

  local dir = vim.fn.expand("%:p:h:t")
  local chapter = tonumber(vim.fn.expand("%:t:r"))
  if not dir_to_book[dir] or not chapter then return nil end

  return {
    dir = dir,
    book = dir_to_book[dir],
    idx = dir_to_idx[dir],
    chapter = chapter,
    verse = verse_under_cursor(),
  }
end

local function jump_to_verse(verse)
  if verse then
    vim.fn.search("^\\*\\*" .. verse .. "\\*\\*", "W")
  end
end

local function apply_reading_options()
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true
  vim.opt_local.breakindent = true
  vim.opt_local.spell = false
  vim.opt_local.conceallevel = 2
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
end

local function open_reader(idx, chapter, verse)
  local book = books[idx]
  local path = chapter_path(idx, chapter)
  if not book or not path or vim.fn.filereadable(path) == 0 then return false end

  local lines = vim.fn.readfile(path)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].modifiable = false
  vim.b[buf].bible_ref = { dir = book[2], book = book[1], idx = idx, chapter = chapter, source_path = path }
  pcall(vim.api.nvim_buf_set_name, buf, string.format("Bible Reader: %s %d", book[1], chapter))

  vim.api.nvim_set_current_buf(buf)
  apply_reading_options()
  jump_to_verse(verse)
  return true
end

local function open_chapter(idx, chapter, verse)
  local path = chapter_path(idx, chapter)
  if not path or vim.fn.filereadable(path) == 0 then return false end

  if reading then
    return open_reader(idx, chapter, verse)
  end

  vim.cmd.edit(vim.fn.fnameescape(path))
  jump_to_verse(verse)
  return true
end

local function chapter_delta(delta)
  local ref = current_ref()
  if not ref then return notify("Open a Bible chapter first", vim.log.levels.WARN) end

  if open_chapter(ref.idx, ref.chapter + delta) then return end

  local next_idx = ref.idx + (delta > 0 and 1 or -1)
  if not books[next_idx] then return end

  local chapter = delta > 0 and 1 or #vim.fn.glob(root .. "/" .. books[next_idx][2] .. "/*.md", false, true)
  open_chapter(next_idx, chapter)
end

local function popup(title, lines)
  local max_width = math.max(1, vim.o.columns - 4)
  local max_height = math.max(1, vim.o.lines - 4)
  local width = math.min(100, max_width)
  local height = math.min(math.max(#lines, 3), max_height)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
    col = math.max(0, math.floor((vim.o.columns - width) / 2)),
    border = "rounded",
    title = title,
  })

  vim.keymap.set("n", "q", function() pcall(vim.api.nvim_win_close, win, true) end, { buffer = buf, silent = true })
end

local function markdown_files()
  return vim.fn.glob(root .. "/**/*.md", false, true)
end

local function file_picker()
  local ok, builtin = pcall(require, "telescope.builtin")
  if ok then
    builtin.find_files({ cwd = root, hidden = true, no_ignore = true })
    return
  end

  vim.ui.select(markdown_files(), {
    prompt = "Bible file",
    format_item = function(path) return vim.fn.fnamemodify(path, ":~:.") end,
  }, function(path)
    if path then vim.cmd.edit(vim.fn.fnameescape(path)) end
  end)
end

local function search_bible(query)
  query = query or vim.fn.input("Search Bible: ")
  if query == "" then return end

  local ok, builtin = pcall(require, "telescope.builtin")
  if ok then
    builtin.live_grep({ cwd = root, no_ignore = true, hidden = true, default_text = query })
    return
  end

  local pattern = query:gsub("\\", "\\\\"):gsub("/", "\\/")
  vim.cmd("silent! vimgrep /" .. pattern .. "/gj " .. vim.fn.fnameescape(root) .. "/**/*.md")
  vim.cmd.copen()
end

local function chapter_picker()
  local entries = {}
  for idx, book in ipairs(books) do
    for _, file in ipairs(vim.fn.glob(root .. "/" .. book[2] .. "/*.md", false, true)) do
      local chapter = tonumber(vim.fn.fnamemodify(file, ":t:r"))
      table.insert(entries, { label = string.format("%s %d", book[1], chapter), idx = idx, chapter = chapter })
    end
  end

  vim.ui.select(entries, {
    prompt = "Bible chapter",
    format_item = function(entry) return entry.label end,
  }, function(entry)
    if entry then open_chapter(entry.idx, entry.chapter) end
  end)
end

map("<leader>zr", function()
  local ref = current_ref()
  if not ref then return notify("Open a Bible chapter first", vim.log.levels.WARN) end

  if reading then
    reading = false
    open_chapter(ref.idx, ref.chapter, ref.verse)
    return
  end

  reading = true
  open_reader(ref.idx, ref.chapter, ref.verse)
end, "Bible: toggle reading mode")

map("<C-p>", file_picker, "Bible: find files")
map("]C", function() chapter_delta(1) end, "Bible: next chapter")
map("[C", function() chapter_delta(-1) end, "Bible: previous chapter")
map("]v", function() vim.fn.search("^\\*\\*\\d\\+\\*\\*", "W") end, "Bible: next verse")
map("[v", function() vim.fn.search("^\\*\\*\\d\\+\\*\\*", "bW") end, "Bible: previous verse")
map("<leader>zj", chapter_picker, "Bible: jump to chapter")
map("<leader>zs", function() search_bible() end, "Bible: search")
map("<leader>zw", function() search_bible(vim.fn.expand("<cword>")) end, "Bible: search word")

map("<leader>zy", function()
  local ref = current_ref()
  if not ref or not ref.verse then return notify("Put cursor on a verse first", vim.log.levels.WARN) end

  local text = vim.api.nvim_get_current_line():gsub("^%*%*%d+%*%*%s*", "")
  local copied = string.format("%s %d:%d — %s", ref.book, ref.chapter, ref.verse, text)
  vim.fn.setreg('"', copied)
  pcall(vim.fn.setreg, "+", copied)
  notify("Copied " .. ref.book .. " " .. ref.chapter .. ":" .. ref.verse)
end, "Bible: copy verse")

map("<leader>zN", function()
  local ref = current_ref()
  if not ref then return notify("Open a Bible chapter first", vim.log.levels.WARN) end

  vim.fn.mkdir(notes_dir, "p")
  local path = string.format("%s/%s-%03d.md", notes_dir, ref.dir:gsub("^%d%d%-", ""), ref.chapter)
  vim.cmd("rightbelow vsplit " .. vim.fn.fnameescape(path))
end, "Bible: chapter notes")

map("<leader>zn", function()
  local ref = current_ref()
  if not ref or not ref.verse then return notify("Put cursor on a verse first", vim.log.levels.WARN) end

  vim.fn.mkdir(notes_dir, "p")
  vim.cmd.edit(vim.fn.fnameescape(notes_dir .. "/verse-notes.md"))

  local heading = string.format("## %s %d:%d", ref.book, ref.chapter, ref.verse)
  if vim.fn.search("^" .. vim.pesc(heading) .. "$", "W") == 0 then
    vim.api.nvim_buf_set_lines(0, -1, -1, false, { "", heading, "" })
    vim.cmd("normal! G")
  end
end, "Bible: verse note")

map("<leader>zh", function()
  local ref = current_ref()
  if not ref or not ref.verse then return notify("Put cursor on a verse first", vim.log.levels.WARN) end

  local label = string.format("%s %d:%d", ref.book, ref.chapter, ref.verse)
  local file = root .. "/.cache/footnotes.tsv"
  if vim.fn.filereadable(file) == 0 then
    popup("Footnotes", {
      "No footnote cache found.",
      "Expected: .cache/footnotes.tsv",
      "Format: Reference<TAB>Note",
      "Example: " .. label .. "<TAB>note text",
    })
    return
  end

  local lines = {}
  for _, line in ipairs(vim.fn.readfile(file)) do
    local r, note = line:match("^([^\t]+)\t(.+)$")
    if r == label then table.insert(lines, note) end
  end

  if #lines == 0 then lines = { "No footnotes for " .. label } end
  popup("Footnotes: " .. label, lines)
end, "Bible: footnotes")

local function url_encode(str)
  return (str:gsub("([^%w%-%_%.%~])", function(char)
    return string.format("%%%02X", string.byte(char))
  end))
end

map("<leader>zt", function()
  local ref = current_ref()
  if not ref or not ref.verse then return notify("Put cursor on a verse first", vim.log.levels.WARN) end
  if vim.fn.executable("curl") == 0 then return notify("curl is required for translation lookup", vim.log.levels.WARN) end

  local label = string.format("%s %d:%d", ref.book, ref.chapter, ref.verse)
  local decode = vim.json and vim.json.decode or vim.fn.json_decode
  local lines = { label, "" }

  for _, translation in ipairs({ "kjv", "web", "asv" }) do
    local url = "https://bible-api.com/" .. url_encode(label) .. "?translation=" .. translation
    local body = vim.fn.system({ "curl", "-fsSL", url })
    local text = "not found"

    if vim.v.shell_error == 0 and body and body ~= "" then
      local ok, json = pcall(decode, body)
      if ok and json and json.text then
        text = json.text:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
      end
    end

    table.insert(lines, translation:upper() .. ": " .. text)
  end

  popup("Translations", lines)
end, "Bible: translations")
