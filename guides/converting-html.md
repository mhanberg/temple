# Converting HTML

If you want to use something like [TailwindUI](https://tailwindui.com) with Temple, you're going to have to convert a ton of vanilla HTML into Temple syntax.

Luckily, Temple provides a mix task for converting an HTML file into Temple syntax and writes it to stdout.

## Usage

First, we would want to create a temporary HTML file with the HTML we'd like to convert.

> #### Hint {: .tip}
>
> The following examples use the `pbpaste` and `pbcopy` utilities found on macOS. These are used to send your clipboard contents into stdout and put stdout into your clipboard.

```shell
$ pbpaste > temp.html
```

Then, we can convert that file and copy the output into our clipboard.

```shell
$ mix temple.convert temp.html | pbcopy
```

Now, you are free to paste the new temple syntax into your project!
