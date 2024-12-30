#!/usr/bin/env node

import { argv, stdout } from "node:process";
import { fetchPackument } from "../_include/npm.js";

const [name, version] = argv.slice(2);

const packument = await fetchPackument(name.replace(/__/, "/"));

stdout.write((packument["dist-tags"]?.latest === version) + "\n");
