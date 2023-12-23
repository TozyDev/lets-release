# let's release

🚀 Let's release as soon as possible

## Usage

```yaml
- name: Let's release
  uses: TozyDev/lets-release@v1
```

## Inputs & Outputs

See [action.yml](action.yml) for more details.

## How it works

First, the action will check out the repository with the `fetch-depth: 0` option to fetch all the tags and histories.
Then, it will get the release type from the commit messages.
The commit messages are following the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
specification.
There are four types of release: `major`, `minor`, `patch`, and `none`.
The `none` type means that there is no release.
If the release type is `none`, the action will stop.
Otherwise, it will calculate the next version based on the current version and generate the changelog.
Finally, the action will not create a release by self.
It provides outputs for you to customize the release process.
Maybe it will create a release in the future.

## License

This project is licensed under the [MIT License](LICENSE).
