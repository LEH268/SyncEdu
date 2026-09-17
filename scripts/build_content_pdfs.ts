const CHROME_CANDIDATES = [
  "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
  "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe",
  "/usr/bin/google-chrome",
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
];

async function findChrome(): Promise<string> {
  for (const path of CHROME_CANDIDATES) {
    try {
      await Deno.stat(path);
      return path;
    } catch { /* keep looking */ }
  }
  throw new Error("Chrome not found; set CHROME_PATH");
}

const chrome = Deno.env.get("CHROME_PATH") ?? await findChrome();
await Deno.mkdir("content/pdf", { recursive: true });

for await (const subject of Deno.readDir("content")) {
  if (!subject.isDirectory || subject.name === "pdf") continue;

  for await (const file of Deno.readDir(`content/${subject.name}`)) {
    if (!file.name.endsWith(".html")) continue;

    const source = await Deno.realPath(`content/${subject.name}/${file.name}`);
    const target = `${Deno.cwd()}/content/pdf/${subject.name}-${
      file.name.replace(".html", ".pdf")
    }`.replace(/\\/g, "/");

    const command = new Deno.Command(chrome, {
      args: [
        "--headless",
        "--disable-gpu",
        "--no-pdf-header-footer",
        `--print-to-pdf=${target}`,
        `file:///${source.replace(/\\/g, "/")}`,
      ],
    });

    const { code, stderr } = await command.output();
    if (code !== 0) {
      throw new Error(
        `Chrome failed on ${file.name}: ${new TextDecoder().decode(stderr)}`,
      );
    }
    console.log(`built ${target}`);
  }
}
