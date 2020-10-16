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
export BASEURL=<URL>
export TOKEN=<TOKEN>

glsearch groups testgroup | glsimple
```
- With `json-cache`
```sh
glsearch groups testgroup | glsimple | jq_append
```
- The cached JSON file will be saved at `/tmp/out.json` by default.
