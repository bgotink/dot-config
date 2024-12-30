import { env } from "node:process";

export const registry = env.DOTCONFIG_TEST
	? "http://localhost:4873/"
	: "https://registry.npmjs.org/";

/** @param {string} pkg */
export async function fetchPackument(pkg) {
	return (await fetch(registry + pkg.replaceAll("/", "%2f"))).json();
}
