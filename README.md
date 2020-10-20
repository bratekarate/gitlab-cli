# gitlab-cli

Interact with gitlabs REST API via shell. Basically just a wrapper around `curl` and `jq` to save some keystrokes. 

## Concept
This CLI is not meant to abstract away curl or jq implementation details, the goal is rather to make interacting with gitlab through `curl` and `jq` less verbose while allowing and encouraging the use of low-level `curl` tweaks and own `jq` extensions.

One essential idea of this project is to allow tweaking by the user so that unimplemented features still can be achieved by using the "base" command, `glab`, paired with custom curl flags and URIs as well as custom `jq` commands.

This project is not indended for users that don't want to interact with low-level tools such as `curl` or `jq` directly.

## Dependencies:
  - `jq`
  - `curl` 

Works best together with [json-cache](https://github.com/bratekarate/json-cache) to cache and index results for later use.

## Installation

```sh
git clone https://github.com/bratekarate/json-cache.git
```
- Create symbolic links from each script file to any directory that is on the PATH.
- Example command to link the scripts:
```sh
find "$PWD" -type f -name "*.sh" -exec test -x {} \; -print0 |
  xargs -0 -I {} sh -c 'ln -s "$1" ~/.local/bin/"$(basename "${1%.*}")"' _ {}
```

## Usage

`$BASEURL` as well as `$TOKEN` or `$TOKEN_CMD` environment variables must be set:
```sh
export BASEURL=https://gitlab.com
export TOKEN=<TOKEN>

glsearch groups testgroup | glsimple
```
- Note: A safer variant is using `TOKEN_CMD`, which provides a command to be executed to retrieve the token. This way the token is not found in the history.

With `$TOKEN_CMD`:
```sh
export BASEURL=https://gitlab.com
export TOKEN=$(bw get password https://google.com)

glsearch groups testgroup | glsimple
```
With [json-cache](https://github.com/bratekarate/json-cache):
```sh
glsearch groups testgroup | glsimple | jq_append
```
- The cached JSON file will be saved at `/tmp/out.json` by default.
- Use `jq_show` to show data from the default cache location
- Use `jq_remove [INDEX]` to remove an entry. Default is the last entry. `jq_remove a` to remove all.

## Low level API
The `glab` command can be used to create any custom request. It accepts an URL as a parameter and after it **(!)** any curl parameters. Put the following in `.zshrc` for `curl` completion:
```zsh
compdef glab=curl
compder glsearch=curl
```
Examples:
```sh
glab 'groups/12/projects?search=test&per_page=100' -sfS -H 'Accept: application/json' 
```
```sh

glab 'groups' -sfS -H 'Content-Type: application/json' -X POST --data \
"{ \
    \"name\": \"$NAME>\", \
    \"path\": \"$PATH\" \
}"
```

## Limitations

- `curl` CLI arguments must be placed at the end of the commands. This simplified implementation greatly, but it negatively impacts user experience.
- Read operations on the API are easy to use, but write operations are still a little cumbersome. E.g. `Content-Type` may be set to `application/json` by default in future updates for simplification. Specifying JSON data via shell should be improved as well (too much escaping when using variables).

