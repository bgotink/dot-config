#!/usr/bin/env node

import { readdirSync } from "node:fs";
import { fetchPackument } from "./_include/npm.js";

const pkgs = await Promise.all(
	readdirSync(new URL("../packages/", import.meta.url)).map(async (pkg) => {
		const originalName = pkg.replace(/__/, "/");
		const packument = await fetchPackument(originalName);

		let dotconfigPackument;
		try {
			dotconfigPackument = await fetchPackument(`@dot-config/${pkg}`);
		} catch {
			dotconfigPackument = null;
		}

		if (dotconfigPackument == null || dotconfigPackument.error) {
			// First publish, only take the latest dist-tag
			return [[pkg, packument["dist-tags"].latest]];
		}

		const times = new Map(
			Object.entries(packument.time).map(([version, time]) => [
				version,
				+new Date(time),
			]),
		);
		times.delete("modified");
		times.delete("created");

		const dotconfigVersions = new Set(
			Object.keys(dotconfigPackument.versions).map(
				(version) => version.split("-", 2)[0],
			),
		);

		let includeAfter = 0;
		for (const [version, date] of times) {
			if (dotconfigVersions.has(version) && date > includeAfter) {
				includeAfter = date;
			}
		}

		if (includeAfter === 0) {
			// No version overlap? Should not be possible
			return [[pkg, packument["dist-tags"].latest]];
		}

		return Array.from(times)
			.filter(([, time]) => time > includeAfter)
			.map(([version]) => [pkg, version]);
	}),
);

console.log(JSON.stringify(pkgs.flat()));
