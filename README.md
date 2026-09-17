# SyncEdu

**An offline-first adaptive learning system for under-resourced classrooms.**
A Flutter app for students (Android) and a Flutter web console for teachers and
administrators, over one Supabase backend and one Gemini-powered generation
service.

This README has two halves:

1. **[The problem, and how SyncEdu solves it](#part-1--the-problem-and-how-syncedu-solves-it)**
   — what it does and why it is built this way.
2. **[Setting it up from zero](#part-2--setting-it-up-from-zero)** — a
   click-by-click guide that assumes no prior knowledge of Flutter, Supabase,
   Deno or Gemini.

If you only want to get it running, jump to
[Part 2](#part-2--setting-it-up-from-zero).

---

# Part 1 — The problem, and how SyncEdu solves it

## 1.1 The problem

This project answers a challenge under **UN Sustainable Development Goal 4:
Quality Education**.

> In many classrooms, especially those with limited resources, one lesson plan
> is delivered to a room full of students at very different skill levels.
> Teachers rarely have visibility into which specific concepts each student is
> struggling with until test results come back — often too late to intervene
> meaningfully. This is worsened in low-resource schools, where teachers manage
> large classes with little time or tooling to track individual progress. As a
> result, struggling students fall further behind while faster students
> plateau, and neither gets material matched to their actual level.

**The problem statement:** *teachers lack real-time visibility into where
students are struggling, and practice materials don't adapt to individual skill
levels.*

**Who is affected:** students in under-resourced classrooms; teachers with large
classes and no tracking tooling; administrators who must decide where to spend
limited intervention hours.

**The challenge:** *how might we give every student personalised practice while
showing teachers exactly where the class is struggling?*

Four areas were named as in scope: personalised learning activities, identifying
learning gaps, teacher-friendly progress tracking, and **learning support for
limited connectivity**. SyncEdu addresses all four — the last one is not treated
as a nice-to-have, because in an under-resourced school it is the difference
between a tool that gets used and a tool that does not.

## 1.2 The one idea everything else hangs off: the micro-skill

When a teacher uploads a chapter's notes, the file is analysed **once** into a
*Chapter Knowledge Pack* — concepts, definitions, formulas, worked examples —
plus a closed set of five to eight **micro-skills**, each with a stable
identifier (for example `factorising-quadratics` or `osmosis-direction`).

Every generated question cites **exactly one** micro-skill. Every answer a
student gives is therefore recorded against a micro-skill, not against a vague
"topic" or a bare score.

That single decision is what lets all three audiences read off one column:

| Who | What they see | How it is computed |
|---|---|---|
| Student | "Your top three struggle tags" | Their own accuracy, grouped by micro-skill |
| Teacher | Class mastery heatmap, most-missed concepts | The class's accuracy, grouped by micro-skill |
| Admin | School-wide difficulty ranking, at-risk list | Proportion of students struggling, grouped by micro-skill |

No separate analytics pipeline, no nightly job, no reconciliation between three
different definitions of "struggling". One denormalised column,
`attempt_items.micro_skill_id`, and a `group by`.

## 1.3 How each part of the challenge is met

### Personalised practice, per student

Quizzes are **not** generated per student per request. Ingestion produces a
**shared question pool** (five items per micro-skill per difficulty band) which
syncs to the device. The app then *assembles* a quiz locally:

```
assembleQuiz(chapters, count, student, mode):
  candidates  <- local questions in those chapters, minus recently seen
  rank        <- personalised-for-me before shared-pool,
                 then by this student's weakness weight on the micro-skill
  bands       <- "prep" biases difficulty 1-2; "revise" biases 2-3
  mix         <- 70% target micro-skills, 30% adjacent
  guard       <- never more than two consecutive items on one micro-skill
```

A student who keeps missing `factorising-quadratics` sees more of it, at a band
matched to how they are doing, without anyone pressing a button. All four
post-quiz options — *regenerate*, *practise mistakes*, *new range*, *notes on
mistakes* — are that same function called with different parameters, not four
special cases. On a perfect score, "practise mistakes" relabels itself to
*harder questions* and shifts the band up, so the fast student does not plateau
either.

Because assembly is local and deterministic given a seed, **the adaptive loop is
identical online and offline**.

### Learning gaps, identified as they happen

A wrong answer updates a decayed error rate per micro-skill (14-day half-life)
immediately on the device, so the student gets feedback with no network. The
same arithmetic runs as a database trigger when the attempt syncs, so the
teacher's view agrees with the student's. The two implementations are pinned to
each other by a test (`test/seam/weakness_parity_test.ts`) precisely because a
silently divergent number is the worst possible failure here.

Teachers no longer wait for an exam: the heatmap moves as practice is submitted.

### Progress tracking a busy teacher will actually use

The teacher console opens on a **mastery heatmap** — chapters across the class,
green at ≥ 75% accuracy, amber 50–75%, red below 50% — expandable to the
micro-skills underneath. Alongside it: most-missed concepts, per-student
progress curves with retry chains drawn as connected segments, a class roster
with special-needs labels, and an AI class summary.

The admin console adds KPI cards, the school-wide difficulty ranking, an at-risk
table carrying the *reason* each student was flagged, and a **Resource
Allocation Recommendation**: for each (class, micro-skill), if at least 40% of a
class of five or more is struggling, it names the class, the subject, the
micro-skill and the affected count, ranked by impact.

Two rules make these numbers trustworthy rather than merely plausible:

- **Minimum sample size.** Five items before a concept enters a ranking, three
  before a per-student judgement. Otherwise one wrong answer on an unpractised
  skill tops the chart at 100%.
- **"Struggling" is judged per student, then counted.** "Fractions 43%" means
  43% *of students*, not of answers. Reversing this produces a chart that looks
  right and means something else entirely.

Every threshold that changes what a chart *means* lives in one file,
`packages/syncedu_core/lib/src/analytics/thresholds.dart`, not scattered through
expressions.

**Every number is computed in Dart. Gemini only writes prose about numbers it
was handed.** The AI summary a teacher reads provably describes the chart on
their screen, and the resource-recommendation sentence is rendered from the same
structure the rule fired on — so it survives being questioned.

### Working where the connection does not

This is the constraint that shapes the architecture.

**The UI never touches the network.** Widgets read a local SQLite database
(drift) through streams. Only the sync engine talks to the server. Every write
is applied locally first and queued as a *delta* — `(table, row, field, observed
value, new value, timestamp)` — not as a whole row, so two people editing
different fields of the same student do not overwrite each other.

| Conflict tier | Example | Rule |
|---|---|---|
| T1 append-only | quiz attempts, observations | Idempotent upsert on a client-generated UUID |
| T2 single-owner | `taught_on`, `chapter_count` | Last writer wins; **the loser is written to `sync_conflicts`, never dropped** |
| T3 contended | class assignment, special needs, placement status | Compare-and-set; a stale precondition is rejected and queued for a human |

A student on a bus with no signal can take a quiz, get scored, see which
micro-skills they missed, and read a written explanation of exactly those
micro-skills — because explanations are ingested per micro-skill and synced with
the pool. When the connection returns, the attempts sync and the teacher's
heatmap moves.

The offline payload is roughly **100 KB per chapter, about 1 MB for ten**, which
is what makes this practical on a cheap phone and a metered connection. Students
never download the source PDFs; they consume the Knowledge Pack.

The only place offline degrades is pool exhaustion: connected, the app requests a
top-up; disconnected, it relaxes the recently-seen window and *says so*. It gets
shallower; it never fails.

## 1.4 What you will see once it is running

- **Student (Android):** sign in → a 20-question pre-admission test (VARK +
  personality, scored by tallying on-device, no model call) → Home with an **AI
  Emoji** you talk to by voice or text → pick chapters → quiz → results with
  struggle tags → notes on exactly what you missed. Flashcards and story mode
  read the same pack.
- **Teacher (web):** define chapters, upload notes, record when each chapter is
  taught to each class, then watch the heatmap, most-missed concepts, per-student
  curves and the relationship diagram.
- **Admin (web):** KPI cards, difficulty ranking, at-risk table, resource
  recommendation, class and teacher CRUD, CSV import, and placement preview with
  approve / override / manual assignment.

## 1.5 How the pieces are arranged

```
packages/
  syncedu_core/    pure Dart, no I/O: analytics, quiz assembly, placement,
                   weakness math, tool vocabulary. Everything that decides a number.
  syncedu_local/   drift schema, mirror, outbox, sync engine, Supabase gateways
  syncedu_emoji/   the AI Emoji painter, spring simulation, state machine
                   (zero application dependencies, by design)
apps/
  student/         Flutter, Android only
  console/         Flutter Web, teacher + admin behind a role claim
supabase/
  migrations/      hand-written SQL, pushed to the linked remote project
  functions/       Deno Edge Functions (anything needing a secret or a model call)
content/           authored Form 4 chapter sources (HTML) -> built to PDF
scripts/           Deno operational scripts: build content, seed, ingest, measure
test/seam/         Deno tests that import each Edge Function handler directly
```

Three lanes, and the placement rule for new work is simple: **if it needs a
secret or a model call it is an Edge Function; otherwise it is SQL.**

| Lane | Carries |
|---|---|
| Local (drift) | Every read. Every write, applied locally first |
| PostgREST | Watermark pulls, tier-1 upserts, the `apply_delta` RPC |
| Edge Function | Anything needing a secret or a model call |

The design is specified in `docs/superpowers/specs/2026-09-05-syncedu-design.md`,
which supersedes `PRD.md` wherever they differ. `docs/OPERATIONS.md` is the
runbook for ingestion stalls, key rotation and conflicts.

---

# Part 2 — Setting it up from zero

This half assumes you have never used Flutter, Supabase, Deno or Gemini. Follow
it in order. Expect **45–90 minutes**, most of it spent waiting on downloads and
on content ingestion.

## 2.0 The shape of the setup

You will:

1. Install five tools (Flutter, Android Studio, Deno, Node, Supabase CLI).
2. Create your own free Supabase project and copy four values out of it.
3. Create three free Gemini API keys.
4. Paste all seven values into **one file: `.env`**.
5. Push the database schema and the Edge Functions to your project.
6. Store two secrets inside the database itself (Supabase Vault).
7. Seed a demo school, ingest ten chapters, seed four weeks of history.
8. Run the two apps.

> **There is exactly one file in this repository you edit to configure it:
> `.env`.** Nothing else has a key in it. The apps take their two values on the
> command line instead (`--dart-define`), and the Edge Functions take theirs from
> the Supabase platform. That is deliberate — it means no key can be committed by
> accident.

### Placeholders used throughout

Everywhere you see one of these, substitute your own value. **Never paste a real
key into a file that is tracked by git.**

| Placeholder | What it is | Where you get it | Where it goes |
|---|---|---|---|
| `<YOUR-PROJECT-REF>` | 20-character Supabase project id, e.g. `abcdefghijklmnopqrst` | Supabase dashboard URL, or Project Settings → General | `supabase link` ([Step 7](#step-7--link-the-cli-to-your-project)) |
| `<YOUR-SUPABASE-URL>` | `https://<YOUR-PROJECT-REF>.supabase.co` | Project Settings → Data API | `.env` line 2 ([Step 6](#step-6--create-and-fill-env-the-only-file-you-edit)), Vault ([Step 9](#step-9--store-two-secrets-in-the-database-vault)), app run commands ([Steps 13–14](#step-13--run-the-teacheradmin-console-web)) |
| `<YOUR-SUPABASE-ANON-KEY>` | Public client key, safe to ship in an app | Project Settings → API Keys | `.env` line 3, app run commands |
| `<YOUR-SUPABASE-SERVICE-ROLE-KEY>` | Admin key, **bypasses all security** | Project Settings → API Keys (reveal) | `.env` line 4, Vault |
| `<YOUR-DATABASE-PASSWORD>` | Password you chose when creating the project | You set it in [Step 3](#step-3--create-your-supabase-project) | `.env` line 5, `supabase link` prompt |
| `<YOUR-GEMINI-API-KEY-1>` … `-3` | Three Google AI Studio keys | <https://aistudio.google.com/apikey> | `.env` lines 6–8, `supabase secrets set` ([Step 8](#step-8--push-the-backend-then-give-the-functions-their-keys)) |

> **If you were handed this repository together with a file named
> `API Key Configuration.md`**, that file already holds a working set of these
> values and you can copy from it instead of creating your own project. It is
> gitignored and must never be committed. Everyone else: create your own, below.

---

## Step 1 — Install the toolchain

Install these five. After each one, run its check command in a **new** terminal,
so it picks up the changed `PATH`.

| # | Tool | Why SyncEdu needs it | Version this was built against |
|---|---|---|---|
| 1 | Flutter (includes Dart) | Builds both apps | 3.44.8 stable / Dart 3.12.2 |
| 2 | Android Studio | Android SDK + the emulator the student app runs on | Any current release |
| 3 | Deno | Runs the Edge Functions, the seed scripts and the backend tests | 2.9.1 |
| 4 | Node.js | Deno resolves a few npm packages through it | 24.16.0 LTS |
| 5 | Supabase CLI | Pushes schema, config and functions to your project | 2.109.1 |

Plus **Google Chrome**, used twice: to run the web console, and to render the
course PDFs in [Step 11](#step-11--build-the-course-pdfs).

### 1.1 Flutter

Follow the official installer for your OS:
<https://docs.flutter.dev/get-started/install>. In short:

- **Windows:** download the zip, extract to `C:\src\flutter` (**not** into
  `C:\Program Files` — the path must not contain spaces), then add
  `C:\src\flutter\bin` to your `PATH` via *Settings → System → About → Advanced
  system settings → Environment Variables*.
- **macOS / Linux:** `git clone https://github.com/flutter/flutter.git -b stable ~/flutter`,
  then add `export PATH="$HOME/flutter/bin:$PATH"` to your shell profile.

Check:

```bash
flutter --version     # expect 3.44.x, Dart 3.12.x
flutter doctor        # see 1.2 before worrying about the Android lines
```

### 1.2 Android Studio and an emulator

Install from <https://developer.android.com/studio>. On first launch let it
download the Android SDK, then:

1. **More Actions → SDK Manager → SDK Tools** — tick *Android SDK Command-line
   Tools* and *Android SDK Platform-Tools*, then Apply.
2. Accept the licences:
   ```bash
   flutter doctor --android-licenses     # press y at every prompt
   ```
3. **More Actions → Virtual Device Manager → Create Device** — pick **Pixel 9**,
   a system image of **API 36**, finish, then press ▶ to boot it.

Check, with the emulator running:

```bash
flutter devices       # expect: sdk gphone64 x86 64 (mobile) • emulator-5554 • ...
flutter doctor        # every line a green tick, except (harmlessly) Visual Studio / Xcode
```

A real Android phone works too: enable *Developer options → USB debugging*, plug
it in, accept the prompt on the phone, and it appears in `flutter devices`.

### 1.3 Deno

```powershell
# Windows (PowerShell)
irm https://deno.land/install.ps1 | iex
```

```bash
# macOS / Linux
curl -fsSL https://deno.land/install.sh | sh
```

Check: `deno --version` → expect 2.x.

### 1.4 Node.js

Install the LTS build from <https://nodejs.org>. Check: `node --version`.

### 1.5 Supabase CLI

```powershell
# Windows
winget install --id Supabase.CLI
# or, with Scoop:
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase
```

```bash
# macOS / Linux
brew install supabase/tap/supabase
```

Check: `supabase --version` → expect 2.x.

> `npm install -g supabase` is **not** supported and will fail. Use an installer
> above.

> **Docker is not needed and is not used.** SyncEdu deliberately has no local
> Supabase stack: the database is always your hosted project, and Edge Functions
> are tested by importing their handler directly. If a tutorial tells you to run
> `supabase start`, that is not this project.

---

## Step 2 — Get the code and resolve dependencies

```bash
git clone <this-repository-url> SyncEdu
cd SyncEdu
flutter pub get
```

`flutter pub get` at the root resolves **all five** Dart packages at once —
`pubspec.yaml` declares a pub workspace, so you never run it per package.

Then confirm the code is healthy before configuring anything:

```bash
flutter analyze          # must print "No issues found!"
```

---

## Step 3 — Create your Supabase project

Supabase is the hosted backend: Postgres database, authentication, file storage
and serverless functions. The free tier is enough.

1. Go to <https://supabase.com> and sign up (GitHub sign-in is quickest).
2. Click **New project**.
3. Fill in:
   - **Name:** `syncedu` (anything you like).
   - **Database Password:** click *Generate a password* and **immediately paste
     it somewhere safe** — this is your `<YOUR-DATABASE-PASSWORD>`, and the
     dashboard will not show it again.
   - **Region:** the one closest to you (this project was built against
     `ap-southeast-1`).
4. Click **Create new project** and wait ~2 minutes for provisioning.

**Your project ref** is the 20-character string in the dashboard URL:

```
https://supabase.com/dashboard/project/abcdefghijklmnopqrst
                                       ^^^^^^^^^^^^^^^^^^^^ this is <YOUR-PROJECT-REF>
```

---

## Step 4 — Copy the three Supabase values

In your project's dashboard, open **Project Settings** (the gear icon, bottom
left).

**a. The project URL** — *Project Settings → Data API* (older dashboards:
*Project Settings → API*). Copy **Project URL**:

```
https://<YOUR-PROJECT-REF>.supabase.co
```

Copy the bare origin. If the dashboard shows a trailing `/rest/v1/`, drop it —
the apps and scripts append their own paths.

**b. The anon key** — *Project Settings → API Keys*. Copy the key marked **anon
/ public** (newer projects may label it **publishable**; either works). This key
is safe to ship inside the apps: on its own it grants nothing, because every
table is protected by row-level security.

**c. The service-role key** — same page, the key marked **service_role** or
**secret**. Click reveal, then copy.

> ⚠️ The service-role key **bypasses every security policy in the database**. It
> belongs only in `.env` (gitignored) and in the Vault in
> [Step 9](#step-9--store-two-secrets-in-the-database-vault). Never put it in an
> app, a `--dart-define`, a screenshot, or a commit.

---

## Step 5 — Create three Gemini API keys

Gemini does the generation work: reading an uploaded chapter into a Knowledge
Pack, writing the question pool and the explanations, and writing prose over
numbers SyncEdu has already computed.

1. Go to <https://aistudio.google.com/apikey> and sign in with a Google account.
2. Click **Create API key**, pick or create a Google Cloud project, copy the key.
3. **Repeat twice more** — you want three keys.

Why three: `supabase/functions/_shared/gemini.ts` rotates across the keys in
memory and advances to the next on a `429` (rate limit) or `5xx`. Ingesting ten
chapters is a burst of roughly 55 model calls; one free-tier key will be
throttled partway through, three will not. Failures log the key **index** only,
never the key itself.

Keys look like `AIza…` or `AQ.Ab8…` depending on when they were issued; both
work. If you genuinely have only one key, put the same value on all three lines
of `.env` — everything still runs, just slower and with more retries.

---

## Step 6 — Create and fill `.env` (the only file you edit)

`.env` lives in the repository root, next to `pubspec.yaml`. It is read by every
Deno script and by the backend tests, and it is gitignored.

Copy the template:

```powershell
# Windows (PowerShell)
Copy-Item .env.example .env
```

```bash
# macOS / Linux
cp .env.example .env
```

Now open `.env` in any text editor. It has **eight lines**, and you paste your
values after the `=` on lines 2 through 8. Paste **raw values**: no quotes, no
spaces around the `=`, no trailing spaces.

**File: `.env` — line by line**

```
1  # Copy to .env and fill in your own values. .env is gitignored.
2  SUPABASE_URL=https://<YOUR-PROJECT-REF>.supabase.co
3  SUPABASE_ANON_KEY=<YOUR-SUPABASE-ANON-KEY>
4  SUPABASE_SERVICE_ROLE_KEY=<YOUR-SUPABASE-SERVICE-ROLE-KEY>
5  SUPABASE_DB_PASSWORD=<YOUR-DATABASE-PASSWORD>
6  GEMINI_API_KEY_1=<YOUR-GEMINI-API-KEY-1>
7  GEMINI_API_KEY_2=<YOUR-GEMINI-API-KEY-2>
8  GEMINI_API_KEY_3=<YOUR-GEMINI-API-KEY-3>
```

| Line | Variable | Paste the value from |
|---|---|---|
| 2 | `SUPABASE_URL` | [Step 4a](#step-4--copy-the-three-supabase-values) — no trailing slash, no `/rest/v1` |
| 3 | `SUPABASE_ANON_KEY` | Step 4b |
| 4 | `SUPABASE_SERVICE_ROLE_KEY` | Step 4c |
| 5 | `SUPABASE_DB_PASSWORD` | [Step 3](#step-3--create-your-supabase-project) |
| 6–8 | `GEMINI_API_KEY_1..3` | [Step 5](#step-5--create-three-gemini-api-keys) — one key per line |

A filled line looks like this (illustrative ref, not a real project):

```
SUPABASE_URL=https://abcdefghijklmnopqrst.supabase.co
```

Check that it parses:

```bash
deno eval --env-file=.env "console.log(Deno.env.get('SUPABASE_URL'))"
```

It should print your URL. If it prints `undefined`, the file is not in the
repository root or that line is malformed.

---

## Step 7 — Link the CLI to your project

```bash
supabase login
```

This opens a browser and asks you to authorise the CLI. If the browser cannot
open — a remote machine, say — create a token at
<https://supabase.com/dashboard/account/tokens> and run
`supabase login --token <YOUR-ACCESS-TOKEN>` instead.

Then link this checkout to your project:

```bash
supabase link --project-ref <YOUR-PROJECT-REF>
```

It prompts for the database password from Step 3. Linking writes to
`supabase/.temp/`, which is gitignored — each developer links their own project.

---

## Step 8 — Push the backend, then give the functions their keys

Run these four commands from the repository root, in this order.

```bash
# a. Create every table, policy, trigger, view and cron job.
supabase db push

# b. Ship supabase/config.toml, which switches on the access-token hook.
supabase config push

# c. Deploy all nine Edge Functions.
supabase functions deploy

# d. Give those functions the Gemini keys (values from Step 5).
supabase secrets set \
  GEMINI_API_KEY_1=<YOUR-GEMINI-API-KEY-1> \
  GEMINI_API_KEY_2=<YOUR-GEMINI-API-KEY-2> \
  GEMINI_API_KEY_3=<YOUR-GEMINI-API-KEY-3>
```

On PowerShell, put command **d** on one line — backslash continuation is a bash
thing; PowerShell uses a backtick.

Why each one matters:

- **`db push`** applies `supabase/migrations/*.sql` in timestamp order. Expect it
  to list every file and finish with `Finished supabase db push.`
- **`config push` is not optional.** It installs the
  `[auth.hook.custom_access_token]` block at the end of `supabase/config.toml`,
  which makes Postgres inject each user's `school_id` and `role` into their
  login token. Every row-level security policy reads those claims. Skip it and
  *every* query returns zero rows: the apps look fine but completely empty.
- **`functions deploy`** uploads `ingest-material`, `generate-content`,
  `generate-personalised-pack`, `analyse-exam-paper`, `chat`, `summarise-class`,
  `suggest-placement`, `analyse-fit`, `suggest-teaching` and
  `provision-users`.
- **`secrets set`** is the *only* way the Gemini keys reach runtime. You do not
  set `SUPABASE_URL` or `SUPABASE_SERVICE_ROLE_KEY` as secrets — the platform
  injects those into every function automatically, and it rejects any secret
  whose name starts with `SUPABASE_`.

Verify: `supabase secrets list` shows three `GEMINI_API_KEY_*` entries (hashed,
not readable — that is expected).

---

## Step 9 — Store two secrets in the database Vault

Ingestion is driven by a `pg_cron` job that runs every minute and calls the
`ingest-material` function over HTTP. To do that, the *database* needs to know
its own URL and needs a key to authenticate with. Those two values live in
**Supabase Vault** — encrypted, unreadable by any client — rather than in a
migration or a table.

In the dashboard: **SQL Editor → New query**, paste the following with your own
values substituted, and press **Run**.

```sql
select vault.create_secret(
  'https://<YOUR-PROJECT-REF>.supabase.co', 'project_url');

select vault.create_secret(
  '<YOUR-SUPABASE-SERVICE-ROLE-KEY>', 'service_role_key');
```

The names `project_url` and `service_role_key` are read verbatim by
`public.sweep_pending_ingestions()` and `public.sweep_pending_exam_papers()` —
see `supabase/migrations/20260905170427_0008_ingestion_cron.sql:25-27`. Do not
rename them.

Verify, in the same SQL editor:

```sql
select name from vault.secrets;         -- expect: project_url, service_role_key
select jobname, schedule from cron.job; -- expect: ingest-sweep, exam-paper-sweep, both '* * * * *'
```

If the secrets are missing the sweep does not crash — it logs
`sweep_pending_ingestions: vault secrets missing; skipping` and does nothing,
which looks exactly like ingestion being slow.

---

## Step 10 — Windows only: supply `sqlite3.dll`

Skip this unless you are on Windows **and** intend to run the Flutter tests. It
does not affect running the apps.

`flutter test` does not build package:sqlite3's native-assets hook, so the test
harness loads a SQLite library from disk instead
(`packages/syncedu_local/test/flutter_test_config.dart`).

1. Go to <https://sqlite.org/download.html>.
2. Under *Precompiled Binaries for Windows*, download `sqlite-dll-win-x64-*.zip`.
3. Extract `sqlite3.dll` to exactly this path:

```
packages/syncedu_local/sqlite3.dll
```

It is gitignored — each machine supplies its own copy. Without it, any test that
opens `SyncEduDatabase.forTesting()` fails on `sqlite3_initialize`.

macOS and Linux need nothing: the system library is already discoverable.

---

## Step 11 — Build the course PDFs

The repository tracks the chapter sources as HTML under `content/` (five
Mathematics and five Biology Form 4 chapters). The PDFs are a build artefact and
are gitignored, so you generate them once. Chrome does the rendering — no extra
dependency.

```bash
deno run --allow-all scripts/build_content_pdfs.ts
```

This writes ten files into `content/pdf/`. If it reports `Chrome not found; set
CHROME_PATH`, point it at your browser first:

```powershell
$env:CHROME_PATH = "C:\Program Files\Google\Chrome\Application\chrome.exe"
```

```bash
export CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
```

Check: `ls content/pdf` lists `biology-ch1.pdf` … `mathematics-ch5.pdf`.

---

## Step 12 — Seed a demo school and ingest the chapters

Three scripts, in order. Each reads `.env` through `--env-file`.

### 12a. Create the school and one user per role

```bash
deno run --allow-all --env-file=.env scripts/seed_demo_school.ts
```

It prints the accounts it created. **Write down the school id it prints last.**
The credentials are fixed:

| Account | Password |
|---|---|
| `admin@demo.syncedu.invalid` | `SyncEdu-Demo-1!` |
| `teacher@demo.syncedu.invalid` | `SyncEdu-Demo-1!` |
| `student@demo.syncedu.invalid` | `SyncEdu-Demo-1!` |

### 12b. Ingest the ten chapters

```bash
deno run --allow-all --env-file=.env scripts/ingest_seed_content.ts
```

This is the long one. For each chapter it uploads the PDF to Storage, inserts a
`materials` row, then drives the pipeline stage by stage:

```
pending --> pack_ready --> band 1 --> band 2 --> band 3 --> pool_ready --> ready
   ^            ^                                              ^
 reads the   micro-skills                     one explanation per micro-skill
 PDF once    locked here
```

That is five or six Gemini calls per chapter, ~55 in total. Expect **20–45
minutes** and a lot of progress output. It is **resumable and idempotent**: if it
fails or you interrupt it, re-run the same command — it skips chapters already
`ready` and picks up mid-pipeline.

If a chapter stalls, see `docs/OPERATIONS.md` → *When ingestion stalls*.

> **The micro-skill set is locked on first ingestion.**
> `chapters.micro_skills_locked_at` is stamped by the first successful pack
> stage, and after that there is no insert path for new micro-skills on that
> chapter. Redoing a chapter requires the exact delete order in
> `docs/OPERATIONS.md`, or a second vocabulary accumulates alongside the first.

Confirm every chapter landed:

```bash
deno run --allow-all --env-file=.env scripts/verify_deliverable.ts
```

> Note: this script has the original demo school's id hard-coded at
> `scripts/verify_deliverable.ts:9`. Replace it with the school id printed in
> Step 12a, or expect zero rows.

### 12c. Seed four weeks of history

The analytics need a past before they have anything to say.

```bash
deno run --allow-all --env-file=.env scripts/seed_history.ts
deno run --allow-all --env-file=.env scripts/verify_seed_shape.ts
```

This creates 3 classes, ~36 students and 2 more teachers
(`student1@demo.syncedu.invalid` onwards, `teacher1@…`, same password), plus four
weeks of attempts shaped so the dashboards demonstrate something: one class with
a genuine deficit on a single micro-skill, three at-risk students (one per rule),
and one student visibly improving across a retry chain.

It writes **only** `attempts` and `attempt_items` and lets the database trigger
derive every weakness — nothing is hand-written into a table an aggregate reads,
which is what keeps the charts reproducible from the raw rows. It is idempotent:
re-running clears the previously seeded attempts and rebuilds them.

If you have seeded more than one school, pin the target by adding a line to
`.env`:

```
SEED_SCHOOL_ID=<the school id printed in step 12a>
```

`seed_history.ts`, `verify_seed_shape.ts` and `measure_offline_payload.ts` all
read it.

**Seeded history is disclosed as seeded, never presented as organic.** If
`verify_seed_shape.ts` fails, adjust the seed — never the analytics.

---

## Step 13 — Run the teacher/admin console (web)

Both apps read their two configuration values from `--dart-define` flags rather
than from a file — see `apps/console/lib/main.dart:11-12` and
`apps/student/lib/main.dart:13-14`. Substitute your Step 4 values directly into
the command.

```bash
flutter run -d chrome --target=apps/console/lib/main.dart \
  --dart-define=SUPABASE_URL=https://<YOUR-PROJECT-REF>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<YOUR-SUPABASE-ANON-KEY>
```

PowerShell wants one line, or backticks for continuation:

```powershell
flutter run -d chrome --target=apps/console/lib/main.dart --dart-define=SUPABASE_URL=https://<YOUR-PROJECT-REF>.supabase.co --dart-define=SUPABASE_ANON_KEY=<YOUR-SUPABASE-ANON-KEY>
```

Tired of pasting? Load `.env` into your shell once per session and reference the
variables instead:

```powershell
# PowerShell
Get-Content .env | Where-Object { $_ -match '^\s*[^#].*=' } | ForEach-Object {
  $name, $value = $_ -split '=', 2
  Set-Item -Path "Env:$($name.Trim())" -Value $value.Trim()
}
flutter run -d chrome --target=apps/console/lib/main.dart --dart-define=SUPABASE_URL=$env:SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$env:SUPABASE_ANON_KEY
```

```bash
# bash / zsh
set -a && . ./.env && set +a
flutter run -d chrome --target=apps/console/lib/main.dart \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

Sign in as `teacher@demo.syncedu.invalid` / `SyncEdu-Demo-1!` for the teacher
surfaces, or `admin@demo.syncedu.invalid` for the admin ones. One application
serves both; the role claim in your token decides which routes you can reach.

Only the anon key ever reaches an app. The service-role key never does.

---

## Step 14 — Run the student app (Android)

Start your emulator (or plug in a phone), confirm the device id, then run:

```bash
flutter devices        # note the id, typically emulator-5554

flutter run -d emulator-5554 --target=apps/student/lib/main.dart \
  --dart-define=SUPABASE_URL=https://<YOUR-PROJECT-REF>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<YOUR-SUPABASE-ANON-KEY>
```

The first Android build downloads Gradle dependencies and can take several
minutes; later runs are fast.

Sign in as `student@demo.syncedu.invalid` / `SyncEdu-Demo-1!`. On first launch
the router redirects you into the **pre-admission test** — twenty questions,
scored on-device, no model call. Finish it to reach Home, then talk to the AI
Emoji or use the buttons: pick chapters, take a quiz, read notes on what you
missed.

**To see the offline story**, which is the point of the project: let the first
sync finish (the banner at the top settles), then turn on aeroplane mode in the
emulator and keep using it. Chapter lists, quizzes, scoring, struggle tags and
per-micro-skill explanations all keep working. Turn the network back on and the
attempts sync; refresh the teacher console and the heatmap has moved.

A profile build, for measuring on low-end hardware, adds `--profile`.

---

## Step 15 — Verify the whole thing

```bash
flutter analyze                          # must be clean; this is the CI gate

dart test packages/syncedu_core          # pure Dart: analytics, assembly, placement, tools
flutter test packages/syncedu_local      # drift schema, sync engine, conflict tiers
flutter test packages/syncedu_emoji      # spring simulation, state machine, goldens
flutter test apps/student
flutter test apps/console
deno task test:seam                      # Edge Function handlers, RLS, sync — no model calls
```

The model tier is off by default because it spends Gemini quota:

```bash
RUN_MODEL_TESTS=1 deno test --allow-all --env-file=.env test/seam/
```

A single test:

```bash
dart test packages/syncedu_core/test/analytics/mastery_test.dart -n "green floor"
flutter test packages/syncedu_local/test/sync/pusher_test.dart --plain-name "a delta carries"
deno test --allow-all --env-file=.env test/seam/rls_tenancy_test.ts --filter "teacher"
```

**The seam tests run against your real remote project.** Each mints an ephemeral
school, provisions its own admin/teacher/student under `@test.syncedu.invalid`,
asserts inside it, and deletes it on teardown. Parallel runs are safe, and your
seeded demo school is untouched.

Finally, check the offline payload is still small enough for a cheap phone:

```bash
deno run --allow-all --env-file=.env scripts/measure_offline_payload.ts
```

Target: roughly 100 KB per chapter, about 1 MB for ten.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| App throws `Run with --dart-define=SUPABASE_URL=...` on launch | `flutter run` without the two defines | Use the full command in Steps 13–14 |
| Sign-in works but every list is empty | `supabase config push` skipped, so tokens carry no `school_id`/`role` claim and RLS matches nothing | Run `supabase config push`, then sign out and back in to mint a fresh token |
| `supabase db push` fails immediately | Not linked, or linked to the wrong project | Re-run `supabase link --project-ref <YOUR-PROJECT-REF>` |
| Ingestion never leaves `pending` | Vault secrets missing or misnamed; the sweep logs `vault secrets missing; skipping` | Redo [Step 9](#step-9--store-two-secrets-in-the-database-vault), with the names exactly `project_url` and `service_role_key` |
| Ingestion fails with 429s | One Gemini key doing all the work | Set three distinct keys via `supabase secrets set`, then re-run `ingest_seed_content.ts` |
| A script throws on `Deno.env.get(...)!` | `.env` missing, malformed, or `--env-file=.env` omitted | Re-check [Step 6](#step-6--create-and-fill-env-the-only-file-you-edit); always pass `--env-file=.env` |
| `flutter test` fails on `sqlite3_initialize` (Windows) | `packages/syncedu_local/sqlite3.dll` absent | [Step 10](#step-10--windows-only-supply-sqlite3dll) |
| `run scripts/seed_demo_school.ts first` | Ingest ran before the school existed | Run 12a, then 12b |
| `verify_deliverable.ts` reports zero materials | Its hard-coded school id | Edit `scripts/verify_deliverable.ts:9` to your school id |
| The PDF build fails | Chrome not on a standard path | Set `CHROME_PATH` ([Step 11](#step-11--build-the-course-pdfs)) |

More failure modes, and what to check for each, are in `docs/OPERATIONS.md`.

---

## Working on the code

Regenerate drift code after editing `packages/syncedu_local/lib/src/db/`:

```bash
cd packages/syncedu_local && dart run build_runner build --delete-conflicting-outputs
```

Update the AI Emoji goldens — 20 files, ten states at 200 dp and 28 dp:

```bash
flutter test packages/syncedu_emoji --update-goldens
```

Mirroring a new table is a new entry in `defaultDescriptors`
(`packages/syncedu_local/lib/src/sync/sync_descriptor.dart`), not new engine
code. Making a field editable from the console means adding a row to
`sync_writable_fields` — and every row there is reachable by any authenticated
user through the `apply_delta` RPC, so keep that list minimal.

Rotating a Gemini key, re-ingesting a chapter, reading `sync_conflicts` and
auditing `sync_writable_fields` are all in `docs/OPERATIONS.md`.

---

## What is deliberately not built

The Educational Car Game; a web build of the student app; iOS; a local
development stack; camera/vision input; presentation and word-processor upload
formats; an accessibility rendering layer beyond a dyslexia-friendly typeface
substitution; streaming or bidirectional audio; a multi-school interface;
teacher performance analytics; intervention campaign management; peer
relationship mapping; parent-submitted special-needs declarations;
notification/messaging/scheduling infrastructure.

Each omission is argued in §11–§12 of the design spec rather than left to be
discovered.
