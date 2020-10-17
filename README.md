# gitlab-cli

Interact with gitlabs REST API via shell.

Depends on:
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

- `$BASEURL` as well as `$TOKEN` or `$TOKEN_CMD` environment variables must be set.
- Example:
```sh
export BASEURL=https://gitlab.com
export TOKEN=<TOKEN>

glsearch groups testgroup | glsimple
```
- Note: A safer variant is using `TOKEN_CMD`, which provides a command to be executed to retrieve the token. This way the token is not found in the history.
- With `$TOKEN_CMD`:
```sh
export BASEURL=https://gitlab.com
export TOKEN=$(bw get password https://google.com)

glsearch groups testgroup | glsimple
```
- With `json-cache`:
```sh
glsearch groups testgroup | glsimple | jq_append
```
- The cached JSON file will be saved at `/tmp/out.json` by default.
- Use `jq_show` to show data from the default cache location
- Use `jq_remove [INDEX]` to remove an entry. Default is the last entry. `jq_remove a` to remove all.

## Low level API
- The `glab` command can be used to creat any custom request.
- It accepts an URL as a parameter and after it (!) any curl parameters. Put the following in `.zshrc` for `curl` completion:
```zsh
compdef glab=curl
compder glsearch=curl
```
- Example:
```sh
glab 'groups/12/projects?search=test&per_page=100' -sfS -H 'Accept: application/json' 
```
```sh

glab 'groups' -sfS -H 'Content-Type: application/json' -X POST --data \
"{ \
    \"name\": \"<name>\", \
    \"path\": \"<path>\" \
}"
```
