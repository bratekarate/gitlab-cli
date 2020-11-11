# gitlab-cli

Interact with gitlabs REST API via shell. Basically just a wrapper around `curl` and `jq` to save some keystrokes. 

## Concept
This CLI is not meant to abstract away curl or jq implementation details, the goal is rather to make interacting with gitlab through `curl` and `jq` less verbose while allowing and encouraging the use of low-level `curl` tweaks and own `jq` extensions.

One essential idea of this project is to allow tweaking by the user so that unimplemented features still can be achieved by using the "base" command, `glab`, paired with custom curl flags and URIs as well as custom `jq` commands.

This project is not indended for users that don't want to interact with low-level tools such as `curl` or `jq` directly.

## Dependencies:
  - `jq`
  - `curl` 
  - `rofi` (optional)

Works best together with [json-cache](https://github.com/bratekarate/json-cache) to cache and index results for later use.

## Installation

```sh
git clone https://github.com/bratekarate/json-cache.git
```
- Create symbolic links from each script file to any directory that is on the PATH. The link target must not contain any extensions such as `.sh`.

### Linux
- Should be the same for WSL (untested).
- Example using the provided install script:
```sh
./install.sh "$HOME"/.local/bin
```

### Windows (MSYS or CYGWIN)
- Symbolic links can only be created with administrator privileges.
- `curl` is expected to be already installed. The latest `jq` binary must be downloaded from github.
- `jq` does not yet support binary mode, meaning it will always output in `CLRF` line endings. `-b` flag is already supported on master, but unreleased. Nevertheless, this project's programs will not be adapted just to work on windows. Instead, a wrapper script around jq should be put into place.
- Example using the provided install script (`jq` download and creating wrapper script included):
```sh
# Example for MSYS (used by git bash)
./install.sh msys "$HOME"/bin
```
- The `"$HOME"/bin` directory is just an example and may not exist and not be part of the `$PATH` environment variable. Either a `bin` directory must be created at a chosen location and added to `$PATH`, or alternatively, `/usr/bin` may be used as a second parameter for the install script.

## Usage

`$BASEURL` as well as `$TOKEN` or `$TOKEN_CMD` environment variables must be set:
```sh
export BASEURL=https://gitlab.com
export TOKEN=<TOKEN>

glsearch groups testgroup | glsimp
```
- Note: A safer variant is using `TOKEN_CMD`, which provides a command to be executed to retrieve the token. This way the token is not found in the history.

- With `$TOKEN_CMD`:
```sh
export BASEURL=https://gitlab.com
export TOKEN_CMD=$(bw get password https://google.com)

glsearch groups testgroup | glsimp
```
- [Bitwarden CLI](https://bitwarden.com/help/article/cli/#download-and-install) is an option to use for `$TOKEN_CMD`. Alternatively, the password may be saved to a plain text file and encrypted with gpg:
```
# save password to plain text file at /tmp/token before

gpg --encrypt --recipient <KEY_ID> /tmp/token

mv /tmp/token.asc "$HOME/.token.asc"
rm /tmp/token
```
- Then, it can be used with `$TOKEN_CMD` as follows:
```
export TOKEN_CMD='gpg --decrypt "$HOME"/.token.asc'
```

With [json-cache](https://github.com/bratekarate/json-cache):
```sh
glsearch groups testgroup | glsimp | jq_append
```
- The cached JSON file will be saved at `/tmp/out.json` by default.
- Use `jq_show` to show data from the default cache location
- Use `jq_remove [INDEX]` to remove an entry. Default is the last entry. `jq_remove a` to remove all.

## Examples
Search merge requests by project name and assigneename, check diff with vim and
merge. The prompt to merge it will appear after vim is closed:
```
glmergetool -p testproject -a theassignee 
```
This is roughly equivalent (except for some error handling) to:

```
glmergefind -p testproject -a theassignee | glpick M | xargs glmergerev
```
Where `glmergerev` expects project id and MR iid as parameters. The `M`
flag is used with `glpick` to output project id and MR iid of the MR line
by line, so that it can be transformed to two parameters with `xargs`. The
lowercase `m` flag of `glpick` would output the entire JSON of the MR.

For other usages of `glpick`, an uppercase flag is not necessary, as the id
can be extracted easily with ` <COMMAND> | jq '.id'`. However, merge requests
are interacted with through the project resource by project id and merge
request iid, therefore requiring two IDs to interact with. This makes the `M`
flag quite valuable when working with MR.

In turn, `glmergefind` is mainly built upon `glsearch`, but also uses `glpick`
to prompt the user for choices. When the intention is to search by merge
requests by some property, `glmergefind` may not be necessary and `glsearch`
may be used. `glmergefind` is intended for cases where the project or the
assignee is known, but not their ids. `glsearch` is more suitable for script
and `glmergefind` merely a convenience command.

If `glmergefind` is run without arguments, the active MR assigned to the user
will be queried. This is  equivalent to `glmergefind -a me`. `glmergefind -a me
-p project` will query the project by name first and then output all merge
requests belonging to that project which are assigned to the user.


## Low level API
- The `glab` command can be used to create any custom request. It accepts an URL as a parameter and after it **(!)** any curl parameters. Put the following in `.zshrc` for `curl` completion:
```zsh
compdef glab=curl
compder glsearch=curl
```
- Examples:
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

