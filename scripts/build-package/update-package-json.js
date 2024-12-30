#!/usr/bin/env node

import { readFile, writeFile } from "node:fs/promises";
import { argv } from "node:process";

const pkgJsonText = await readFile("package.json", "utf-8");
const pkgJson = JSON.parse(pkgJsonText);

const [name, directory, version] = argv.slice(2);

pkgJson.name = name;
pkgJson.version = version;
pkgJson.repository = {
	type: "git",
	url: "https://github.com/bgotink/dotconfig.git",
	directory,
};

await writeFile(
	"package.json",
	JSON.stringify(pkgJson, null, /^\s+/m.exec(pkgJsonText)?.[0] ?? 2),
);
