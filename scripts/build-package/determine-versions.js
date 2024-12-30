#!/usr/bin/env node

import { readFile } from "node:fs/promises";
import { registry } from "../_include/npm.js";

const pkgJson = JSON.parse(
	await readFile(new URL("../../package.json", import.meta.url), "utf-8"),
);

console.log(`KDL_VERSION=${pkgJson.dependencies["@bgotink/kdl"]}`);
console.log(`DOTCONFIG_VERSION=${pkgJson.version}`);

console.log(`npm_config_registry=${JSON.stringify(registry)}`);
console.log(`export npm_config_registry`);
