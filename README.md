# dotconfig

Place workspace configuration in a `.config` folder

## Rationale

Tools often require configuration files added to your repository root, and those files are often committed in the repository.
This leads to bloated repositories, where it's hard to find which files are _content_ and which are _config_.

We therefore propose to place configuration inside a `.config` folder in the repository root, similar to XDG's `~/.config` folder on Linux.

## Extras

Many tools only support [JSON](https://www.json.org/) or [YAML](https://yaml.org/), both of which are problematic in their own way.
JSON is not designed to store configuration, lacking important features like comments and bringing a lot of papercuts like forbidding trailing commas.
YAML solves the issues of JSON but brings a bunch of issues of its own, with its ambiguous syntax (hope you're not in [Norway](https://www.bram.us/2022/01/11/yaml-the-norway-problem/)), whitespace sensitivity (including lack of [tabs](https://blog.lslabs.dev/posts/tabs_vs_spaces)!), and more.

[TOML](https://github.com/toml-lang/toml)&emdash;another format supported by some tools&emdash;is great for small files but quickly becomes unwieldy for larger files or when nesting.

Enter [KDL](https://kdl.dev), a language specifically designed with configuration in mind.
It focuses on being easy to parse for computers while also being easy to read/write for humans.

This repository adds KDL support to tools that don't support any more human-friendly configuration language.

## Usage

Replace any of the supported packages with the `@dot-config` alias.
You can specify an exact version or a tag.

For example, in your `package.json` you can replace

```json
{
	"devDependencies": {
		"prettier": "3.4.2"
	}
}
```

with

```json
{
	"devDependencies": {
		"prettier": "npm:@dot-config/prettier@3.4.2-dotconfig.0.1.0"
	}
}
```

to specify both the prettier version and the dot-config version exactly.
Alternatively, you can use

```json
{
	"devDependencies": {
		"prettier": "npm:@dot-config/prettier@upstream-3.4.2"
	}
}
```

to only define the version of prettier.

### SemVer

Semantic Versioning is great and all, but it cannot handle the scenario where there are two versions: the version of the tool and the version of the patches applied to the tool.
This project therefore uses "pre-release" versions that contain both version numbers: `<tool version>-dotconfig-<dotconfig version>`, e.g. `3.4.2-dotconfig-0.1.0`.

As an alternative the project could decouple its versions from the upstream versions, e.g. 3.4.3 of `@dot-config/prettier` could map to version 3.4.2 of `prettier`.
This can quickly become confusing for the humans managing the versions and problematic for other tools that read these versions.
For example, if the dot-config format should make a breaking change, it would have to be published as a new major version and it would cause all kinds of problems to have `@dot-config/prettier` version 4 map onto `prettier` version 3.x.

To make things easier, aliases are created so developers can only define the tool version if they want to.
Because of limitations in NPM we can't create an alias that could be construed as a version number, so we use `upstream-<tool version>` as alias.

Once this project reaches stability, it is not expected to make any further breaking changes and the `-dotconfig` part of the version numbers can be dropped.

## License

This repository is free and unencumbered software released into the public domain.
The packages published via this repository retain their original licenses.
